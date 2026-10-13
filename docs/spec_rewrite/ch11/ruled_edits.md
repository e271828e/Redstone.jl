# Chapter 11: the ruled edits of the rulings batch (checkpoint 3)

Items B-15, B-16, B-18 to B-24 of `rulings_batch.md`, and RP-14 of
`chapter_rulings.md`. Each entry gives the unit's `new.md` source lines
before and after, verbatim. Each "old" block occurs once in the file as
committed at `c3d69f1`, and no two blocks overlap, so the entries replay in
any order. Rewrapped lines are part of the block. `inventory.json` and
`rulings.md` changed with each edit, as noted per entry.

## 1. B-15, unit A

Inventory C-041, tag R.

```text
and each `Simulation` owns its own [buffers](#g-buffer) (the framework-owned vectors backing
continuous state, [§9.4][s9-4]). Pre-materializing the sweep's [activations](#g-activation) (the build's
```

```text
and each `Simulation` owns its own `Model`, and with it the `Model`'s
[buffers](#g-buffer) (the framework-owned vectors backing continuous state,
[§9.4][s9-4]). Pre-materializing the sweep's [activations](#g-activation) (the build's
```

## 2. B-16, unit A

No edit. The text already reads "which makes lock-free handoffs hard in
non-GC languages", applied by the chapter fixes (P1-5).

## 3. B-18 and B-24 (third bullet), unit J

One paragraph, rewrapped once. Inventory C-048 (B-24) and C-049 (B-18),
tag R. B-24's third bullet was not applied before.

```text
writer it carries four things. `recent` is the ring the frame's drain took,
carried by the first publication after that drain, at most sixteen values.
`suppressed` is the per-kind counts the ring refused in that drain. `totals` is
the cumulative per-writer × per-kind counts since the run began, owned privately
by the loop and *copied* into each status. And `heartbeat` rides beside the
`task_state` the loop reads off its own device `Task` handle at publication
([§12.2][s12-2], [D-193][d-193]). Beside the per-writer records ride the pacer diagnostics
([§10.7][s10-7]).
```

```text
writer it carries four things beside `who`. `recent` is the ring the frame's
drain took, carried by the first publication after that drain, at most sixteen
values per diagnostic cell it takes. The loop's record folds two, its own and
the `Model`'s ([D-317][d-317]). `suppressed` is the per-kind counts the ring refused in
that drain. `totals` is the cumulative per-writer × per-kind counts since the
run began, owned privately by the loop and *copied* into each status. And
`heartbeat` rides beside the `task_state` the loop reads off its own device
`Task` handle at publication ([§12.2][s12-2], [D-193][d-193]). Beside the per-writer records ride
the pacer diagnostics ([§10.7][s10-7]).
```

## 4. B-18, unit J

Inventory C-085, tag R.

```text
values per writer per boundary is the worst case, and everything past it is an
integer increment. The zero-allocation invariant, scoped to the stepping loop
([§9.8][s9-8], [D-305][d-305]), is untouched. The diagnostic cells sit on the framework side of
that scope with publication and logging.
```

```text
values per diagnostic cell per frame is the worst case, and everything past it
is an integer increment. The zero-allocation invariant, scoped to the stepping
loop ([§9.8][s9-8], [D-305][d-305]), is untouched. The diagnostic cells sit on the framework side
of that scope with publication and logging.
```

## 5. B-19, unit J

Inventory C-022, tag R.

```text
dead.
```

```text
dead. The loop's own record carries neither, for the same reason ([D-240][d-240], [D-193][d-193]).
```

The old block is the line after "status record no `task_state`, because it
has no task of its own to be alive or".

## 6. B-20, unit J (D-200's second ruling)

The grep of `scratch_survey/spec.md` and every unit's `new.md` found no bold
citing D-240, D-241 or D-200's second ruling. J's "Each writer has one
diagnostic cell" bold is D-200's first ruling. Inventory C-021, tag R.

```text
and no new primitive ([D-136][d-136]). The harness writer's diagnostic cell is written
from whichever task stages, exactly as its staging cell is, and the same CAS
```

```text
and no new primitive ([D-136][d-136]). **The harness writer's diagnostic cell is written
from whichever task stages**, exactly as its staging cell is, and the same CAS
```

## 7. B-20, unit J (D-240)

Inventory C-042, tag R.

```text
body ([§11.6][s11-6]). The loop acquire-loads the heartbeat at publication, when it
```

```text
body ([§11.6][s11-6]). **The loop acquire-loads the heartbeat at publication**, when it
```

## 8. B-20, unit J (D-241)

The sentence carried no D-citation, so the bold gains "([D-241][d-241])" in
its own sentence. The next sentence keeps its D-241. Inventory C-077, tag R.

```text
The sentinel swap allocates nothing. The per-writer status costs one small
vector of records per publication, beside the snapshot allocation per [boundary](#g-boundary)
(a published consistency point) that [§11.2][s11-2] already accepts. That is the same
GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
```

```text
The sentinel swap allocates nothing. **The per-writer status costs one small
vector of records per publication** ([D-241][d-241]), beside the snapshot allocation per
[boundary](#g-boundary) (a published consistency point) that [§11.2][s11-2] already accepts. That is the
same GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
```

## 9. B-21, unit C

Inventory C-072, tag R.

```text
**The harness cell drains last**, by convention ([D-174][d-174]). With every surface
disjoint the order is unobservable, so the rule exists to make the trace read
the same way every time, not to arbitrate anything.
```

```text
**The harness cell drains last**, by convention ([D-096][d-096], [D-174][d-174]). With
every surface disjoint the order is unobservable, so the rule exists to make the
trace read the same way every time, not to arbitrate anything.
```

## 10. B-22, unit G1

Inventory G1-014, tag R.

```text
**`should_abort` is an `attach!` keyword**, defaulting to `false` ([D-138][d-138]). It is
per-attachment, never a device property. The same joystick is advisory in one
deployment and decisive in another. With `should_abort` clear, a device's
departure is reported and the run continues without it. With it set, that
departure also requests a sim stop ([§12.4][s12-4]). A departure is the loop body
```

```text
**`should_abort` is an `attach!` keyword**, defaulting to `false` ([D-138][d-138],
[D-177][d-177]). It is per-attachment, never a device property. The same joystick is
advisory in one deployment and decisive in another. With `should_abort` clear, a
device's departure is reported and the run continues without it. With it set,
that departure also requests a sim stop ([§12.4][s12-4]). A departure is the loop body
```

## 11. B-23, unit H

Inventory C-026, tag R.

```text
state at render.
```

```text
state at render ([D-270][d-270]).
```

The old block is the line after "port resolution, when the run starts, and
never consulted against mutable claim".

## 12. B-24 (first bullet), unit G1

Inventory G1-069, ruling "R21, B-24".

```text
`task_state` says so at the next publication, and its heartbeat goes stale
([§12.2][s12-2]). A device's [claim](#g-claim) is the set of [faces](#g-face) (the names ports wear on their
component's boundary) it *may* write. Claims and the roster entry persist to run
end (the freeze, [§11.3][s11-3], [D-106][d-106]). The GUI implements the same authoring contract.
```

```text
`task_state` ([§11.8][s11-8]) says so at the next publication, and its heartbeat goes
stale ([§12.2][s12-2]). A device's [claim](#g-claim) is the set of [faces](#g-face) (the names ports wear on
their component's boundary) it *may* write. Claims and the roster entry persist
to run end (the freeze, [§11.3][s11-3], [D-106][d-106]). The GUI implements the same authoring
contract.
```

## 13. B-24 (second bullet), unit C

Inventory C-107, tag R.

```text
the [§12.2][s12-2] heartbeat shows the death by name, and the roster entry, claims
```

```text
the heartbeat ([§12.2][s12-2]) shows the death by name, and the roster entry, claims
```

## 14. RP-14, unit C

Inventory C-060, tag R. The `added` entry "(the framework-owned writer beside
the roster)." becomes "(the framework-owned write path `stage!(sim, …)`).".

```text
framework-owned writer beside the roster). It is an entry point with no task of
its own, the harness/REPL write path ([§12.6][s12-6], [D-096][d-096]), called as follows.
```

```text
framework-owned write path `stage!(sim, …)`). It is an entry point with no task
of its own, the harness/REPL write path ([§12.6][s12-6], [D-096][d-096]), called as follows.
```
