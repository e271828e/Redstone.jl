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

## Open for the user

- Whether the README's installation section should carry the companion's
  two `Pkg` routes now or wait for the tutorial item (left for the tutorial
  item).
