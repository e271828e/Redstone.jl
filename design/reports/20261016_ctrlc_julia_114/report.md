# Ctrl-C on Julia 1.14, 2026-10-16

Julia's master branch (1.14.0-DEV) no longer delivers Ctrl-C as an
`InterruptException`. The operator interrupt of §12.4 (D-132, D-394) rests on
that delivery. This report records the change, where Redstone would break,
and a candidate design. A Windows crash on 1.13, found while setting up CI,
closes it.

Sources are pinned: master at `54d14c8eb9` (2026-10-16) and v1.13.1. Nothing
was run on master. Every claim about it comes from reading the source.

## Summary

**On 1.14, Ctrl-C is a cancellation, observed only at cancellation points.**
Compiled code is never interrupted asynchronously. `sigatomic_begin`/`end`
no longer affect Ctrl-C.

**Redstone's contract survives and its mechanism does not.** The run would
still need to end `stopped`, boundary-consistent, with its devices named.
None of the code that gets it there today would run as intended.

**A candidate design reads Ctrl-C as a flag at the frame top**, beside the
stop word, and shields the run from cancellation. It needs names Julia has
not made public yet. Nothing changes in `src/` until 1.14 branches or those
names become public.

## 1. Ctrl-C on 1.13

The terminal turns Ctrl-C into SIGINT. A listener thread (Unix) or a console
handler (Windows) sets `jl_signal_pending` and protects a safepoint page. The
main thread faults at its next safepoint and throws `InterruptException` into
its running task. Only thread 0 receives it. While the sigatomic counter is
nonzero the fault only records the signal, and `sigatomic_end` throws it. A
script's default, `exit_on_sigint(true)`, exits instead. Repeated presses in
a short window force the throw through the mask.

§12.4 masks each boundary with that counter, so the interrupt lands only
between boundaries:

```julia
Base.sigatomic_begin()        # Ctrl-C from here on is only recorded
frame!(sim.model, k, hooks)   # a whole boundary
Base.sigatomic_end()          # a recorded Ctrl-C throws here
```

## 2. What 1.14 changes

The change landed as #62655 (2026-08-08) with the split PRs of #60281.

- **A cancellation token** is a level-triggered flag. Once set it stays set.
  The current one rides in the scoped value `Base.CANCEL_TOKEN`, and spawned
  tasks inherit it. The REPL gives each evaluation its own token. A script
  runs under one root token.
- **Ctrl-C sets the current token** and throws nothing. Code finds out at a
  cancellation point, which throws `Base.CancellationRequest <: Exception`,
  not a subtype of `InterruptException`. The cancellation points are `wait`,
  `fetch`, `sleep`, a contended `lock`, `Channel` operations, I/O and
  `Base.@cancel_check`. `yield()` is not one, and plain computation never is.
- **The runtime never throws `InterruptException` on Ctrl-C.** The forced
  throw is gone. `jl_signal_pending` no longer exists.
- **`sigatomic_end` raises nothing.** `disable_sigint` emits a depwarn that
  points to `Base.CANCEL_TOKEN => nothing` as the shield. A nonzero counter
  still makes the runtime refuse to abandon a task.
- **`exit_on_sigint(true)` behaves as before** for a script.
- **The read side:** `Base.iscancelled(tok)` is one relaxed atomic load and
  reads the C side's state directly, so it needs no scheduled task. Blocking
  calls take a `cancel` keyword. None of these names is exported or public.

Still open on master: #62663 (an escalation ladder for repeated presses, up
to freezing tasks), #62814 (SIGTERM through cancellation) and #63344
(`SignalCondition`). No `release-1.14` branch exists. The cancellation work
will not be backported to 1.13 (#62665).

## 3. Where Redstone breaks on 1.14

In the REPL, most severe first:

1. **An unpaced deviceless run cannot be stopped.** Its loop has no
   cancellation point: no pacer `sleep`, and no `yield()` without devices.
   §12.4 names Ctrl-C as that run's only escape.
2. **A paced or paused run ends `errored`.** The pacer's `sleep`
   (`src/control.jl`, `wait_deadline!`) or the pause block's `wait`
   (`wait_resume!`) throws a `CancellationRequest`. The catch arms test
   `err isa InterruptException`, so `run!` stores it as the cause and ends
   under `LoopError`.
3. **The tail fails.** The token stays set, so the join waits and any
   `shutdown!` doing I/O throw at once.
4. **Devices are reported as crashed.** Device tasks inherit the token. A
   blocking read throws `CancellationRequest`, and the wrapper reports a
   `DeviceCrash`, which D-132 rules out.
5. **The 1.13 machinery goes dead.** The frame mask, the forced-throw arm,
   the retry loops in `run!`'s catch and the second-press collapse never
   run. The suite's real-signal tests read `cglobal(:jl_signal_pending)` and
   would error.

One change helps. A frame is no longer interrupted mid-sweep, so the mask's
purpose holds by itself, except at a cancellation point inside a frame: a
component that logs, does I/O or takes a contended lock.

## 4. A candidate design

Read Ctrl-C as a flag where the loop already reads the stop word, and let
nothing inside the run be cancelled. The interrupt becomes literally what
D-132 calls it, a control-plane stop issued by hand.

```julia
interrupted(tok) = tok !== nothing && Base.iscancelled(tok)

function run!(sim; ...)
    outer = Base.CANCEL_TOKEN[]                    # read once per run
    @with Base.CANCEL_TOKEN => nothing begin       # the run is shielded; devices inherit it
        while true
            interrupted(outer) && _request_stop!(control, :interrupt)   # frame top
            wait_resume!(control; cancel = outer)  # the pause block wakes on Ctrl-C
            frame!(sim.model, k, hooks)            # unmasked: nothing can interrupt it
            ...
        end
        _tail!(...)                                # shielded joins and shutdown!
    end
end
```

The poll covers the deviceless run. The stop word gives `stopped` and the
existing source logic. The pacer's `sleep` lasts at most one frame budget, so
the next frame top's poll catches it. Devices end through the ordinary stop
and `unblock!`. The shield keeps the tail working and covers a component
that blocks inside a frame. Most of §12.4's 1.13 edge cases disappear.

Open questions:

- **The second press.** Public code cannot see a press on a token already
  set. Either the tail relies on `join_timeout` alone, a change to D-394's
  second bullet, or Redstone arms a fresh token for the tail with the
  internal `sigint_new_episode!`.
- **A token set before the run.** In a script with `exit_on_sigint(false)`,
  the root token stays set after the first Ctrl-C, so a later `run!` stops
  at once. That needs a rule.
- **Allocations.** The per-frame poll must not allocate. Nobody has measured
  it on nightly.
- **The escalation ladder.** If #62663 merges, its task-freezing severities
  may cut through a shield. The sigatomic counter's remaining role, refusing
  abandonment, may give the mask a new purpose.
- **Both versions or a switch.** Keeping 1.13's mechanism beside this one
  means two code paths selected at load time by
  `isdefined(Base, :CancellationRequest)`. Switching when Redstone moves to
  1.14 is simpler.

The spec edit would touch §12.4's masking and second-interrupt rulings,
D-132's `InterruptException` wording, D-394, the device wrapper in §11.6 and
the glossary's *operator interrupt*.

## 5. The Windows crash on 1.13

Setting up CI found a segfault in Julia 1.13.2 on Windows. A thread sends
itself SIGINT with the C runtime's `raise`, which arms the signal at once.
If the code then throws before any safepoint, the process dies with an
access violation and Julia prints nothing. A sigatomic mask makes no
difference. One `GC.safepoint()` between `raise` and the throw avoids it, so
the signal is deferred first. On Unix, `kill` returns with the signal already
deferred, and the case never arises.

`probes/sigint_probe.jl` reproduces it in plain Julia:

| case | `-t auto` | `-t 1` |
| --- | --- | --- |
| `masked_throw` | segfault | segfault |
| `masked_safepoint_throw` | fine | fine |
| `unmasked_throw` | segfault | segfault |

`test/fixtures.jl`'s `interrupt_self` takes the safepoint on Windows. No
Julia issue covers the crash, and none was filed. The code path no longer
exists on master, so a report would ask only for a 1.13.x fix. #62434 (a
first-chance handler for safepoint faults) may be related. A real Ctrl-C may
open the same window through the console handler. That is untested and would
be rare.
