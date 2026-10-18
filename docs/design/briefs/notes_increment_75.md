# Notes: increment 75, the examples package

Rulings made while the user was away on 2026-10-18, each with its reason,
and the open points for the user. Brief: `brief_increment_75_examples.md`,
written at ade420f and launched without the user's review of the brief, as
instructed. Nothing here is pushed.

## Settled with the user before leaving

The examples live in `examples/`, a package in an environment of its own,
a workspace root with `examples/test`, reaching `Redstone` by a `[sources]`
path and never a member of the root workspace. The precompile workload is
decoupled from the examples. The two departures from the first sketch, the
pinned `Source{Bool}` switch and `γ` among the outputs, and the file's
surface of plain functions. A theory companion was asked for.

## Rulings made in the user's absence

1. **The theory companion is `companions/longitudinal_aircraft.md`**, five
   sections, written from the prototype's numbers and registered in the
   three rosters. The examples companion points at it rather than carrying
   the physics twice.
2. **No spec sentence and no log entry.** The spec never names the
   examples, and once they are outside the package nothing on `Redstone`'s
   surface changes. The companion is their record, as `test/`'s placement
   has none. The §13.7 sentence proposed while the submodule stood is moot.
3. **CI is a third workflow, `Examples.yml`, Linux only, through
   `Pkg.test()`.** A separate workflow keeps the gate's badge honest and
   its matrix unchanged; Linux alone, since nothing in the examples touches
   the interrupt machinery the Windows leg exists for.
4. **The examples pin `Dual` readiness with `ProbeDual`, not
   `LinearizeDual`,** and measure allocation through `phase_bodies` alone,
   without `boundary!` and `offtick_boundary!`: the examples import only
   Appendix B's surface, and those are the names it lists.
5. **The work-order bullet retires with the stage's commit**, its harness
   drift sentence moving to the precompile bullet.
6. **The examples package exports nothing and marks nothing `public`**,
   mirroring `Redstone` under D-226 until its own first release decides.
7. **`Redstone`'s gate is not run** for this increment: nothing under
   `src/` or `test/` changes. Both examples runners are.
8. **`ControlSystemsBase` is a dependency of the examples package itself**,
   so `lqr_gains` computes the tracker's gains live from a linearization.
   It loads in 0.5 s.

## The arc

ade420f (docs), e663cf4 (brief and these notes), 3346a6d (stage 1),
99a84f4 and 2821dad (the fixer), 55d2f25 (a last pin and three figures, landed
by me). Nothing pushed.

## Rulings made at the review

9. **The cold review's one defect was real**: `trimmed` seeded two of the
   three integrators whose trim value is not zero, so the cascade started
   2 m off trim. It now seeds the altitude loop too, and an equilibrium pin
   holds both controllers at trim to 1e-6 over 60 s.
10. **Every `Tt` in the closed loop is one period, 0.02 s.** With 0.2 to
    0.5 s the standby tracker sat up to 0.2 rad from the cascade's command
    mid-climb, since a standby's lag grows with `Tt` and with the rate at
    which its own law moves; at one period the tracker and the two outer
    loops stay within 0.015 rad after the pull-up. The pitch-rate and
    attitude loops sit a few hundredths of a radian off whatever `Tt` is,
    which the companion says.
11. **The switch keyword is a predicate**, `cascade = t -> true`, so a run
    can hand command back to the cascade; a hand-back at 10 s is pinned.
    The prototype's `t_switch` only ever handed command to the tracker.
12. **Pins on a rate-limited signal moved upstream.** The two mid-climb
    jumps are pinned on the command before the limiter: the actuator's
    frame-to-frame change is capped at about 5.8e-3, so a pin on it could
    not fail. The steady-flight switch stays on the actuator, where the
    jitter comparison belongs.
13. **Two acceptable survivors are recorded**: the pitch-rate loop's
    tracking input fed a constant alone (its gap 0.0145 against the 0.03
    bound, its hand-back jump 4.05e-3 against 2.26e-3 clean), and the
    attitude loop's fed zero alone (its gap 0.0391 against 0.0374 clean).
    Each is within a factor of two of the clean run, and separating them
    would need a hand-back during the pull-up, where the tracker's own
    slew dominates. A third, the pitch-rate loop's `Tt` alone at 0.2,
    survives because a longer `Tt` worsens nothing pinned.
14. **The bumpless claim is stated with numbers** in the docstring and the
    companion, steady flight and mid-climb apart.
15. **The closed loop's children carry full words** (`select_δe`,
    `command_δe`, `δe_limiter`, `δe_lag`, `tracker`, `free_pair`), since
    the tutorial and the inspector's diagram will name them.
16. **Appendix B's omissions are recorded under the audit bullet** of
    `pending.md`: `AbstractComponent`, `Absolute`, `get_deriv`, `logged`,
    `termination`, `EndTimeReached`, `ModelRequestedStop`, all public by
    their sections and imported by the examples or their tests.

## Open for the user

- Whether the README's installation section should carry the companion's
  two `Pkg` routes now or wait for the tutorial item (left for the tutorial
  item).
