# Notes: increment 80, the rulings made while the user was away

Written on 2026-10-20 from the design record in
`companions/store_at_rest_walkthrough.md` section 7, which the user settled
before leaving with "prepare and launch". Each ruling below is mine, with
its reason, for the user's review. Nothing was pushed.

## The docs commit, 4f922f7

- **D-429's Position has three bullets**, the settling, the header with the
  failure disposition, and the merge base. The name, the sugar on
  `restore!` and the pre-overlay checkpoint are Rejected items, and the
  root-input entries and the model form are clauses of the headline, so the
  spec carries five bolds for the entry: four in §12.6's paragraph and the
  base sentence in §14.1.
- **§14.1's second bold reads "A condition describes a starting state and
  nothing else"** (D-273, D-429), since "an initial condition and nothing
  else" became false. The sentence after it says which state under which
  door.
- **§14.5 is untouched.** The record plans the rest-reading sentence with
  Appendix A's rewrite, and the parallel session on Appendix A took it.
- **§11.5 and §13.4 gained one sentence each**, the header `overlay!` takes
  and the `:overlay` host, pointers to §12.6 with no bold of their own.
- **D-273's annotation records that the checkpoint's read-only view was
  never built**, the companion's section 6 loose end.

## The code

- **The priors reset stays in `init!`'s body**, not in `_settle!` as the
  record's sketch has it. `boundary_zero!` is a spec-named stepping
  primitive (Appendix B), so it keeps its name and its exact meaning as a
  one-liner over `_settle!(fresh = true)`; the flag carries the two choices
  inside the boundary, the sweep's gate and the updates.
- **No stepper reset.** The seam's only hook is `restore_stepper!(stepper,
  state)`, boundary zero never ran a reset, and both backends hold nothing
  across a frame top; a backend with carried state adds the hook with the
  backend.
- **The merge base is a `resolve_condition` keyword, `bases`**, baked at
  resolution as §14.3's "application decides nothing" says, with
  `_store_values(exec)` reading the stores at rest in `_store_bases`' order.
  The plan's shape, `apply!` and `init!`'s plan path are untouched, so the
  factoring is the only change to existing behaviour.
- **The sim door is legal where `checkpoint` is**, and the gate is
  `_assert_at_rest`, factored from `checkpoint` at both levels. `built` is
  refused since it has no base to overlay, and a `t*` stop is refused
  before any write because the header taken after the settling would
  otherwise fail on a half-written state.
- **The host is `:overlay`, the pointer the frame the clock sits at**, and
  the rendered recipe reads "overlay!(sim2, condition) on the same stopped
  state reproduces it".
- **The settling publishes under the stopped run's last ordinal**: the door
  opens the run at the stopped run's counters and steps the ordinal back as
  `_enter_checkpoint!` does, so the header's ordinal is one past the
  published one, as `checkpoint(sim)`'s is.
- **The tests sit by property** in `discrete`, `events`, `trace`,
  `lifecycle` and `failures`, no new fixture, so `test_build.jl`'s Dual
  sweep count is untouched.
