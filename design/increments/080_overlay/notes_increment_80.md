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

## The arc

Run on 2026-10-20 with the user away. The docs commit is 4f922f7, the brief
c97b1ea, the code bc46043; the gate green at 6621 against 6550 before the
new tests, the examples green at 73. Nothing was pushed.

### The cold review

Nothing blocking. The gate green at 6621 in the real tree on 1.13.1, the
examples green. The brief's ten mutants and two extra ones (the periphery
reset dropped, `_store_values` pairing each tag with the other store) all
died on a scratch worktree. D-429's Position and every spec passage the
brief names were probed and hold; the five choices were confirmed from the
code, with `_settle!(fresh = true)` the old `boundary_zero!` body statement
for statement. Edge cases probed and found sound: an overlay at frame 0, two
in a row, overlay then checkpoint then restore on a twin, `log = false`,
root inputs alone with no totality asked, a `Bool` root input, `trim!` and
`linearize` after an overlay, a device across the door.

Three findings ruled "fix", landed as 28b0031 (docs) and the fix commit
after it:

1. Appendix C's `StepError` row named two hosts; it names `:overlay` now.
2. D-429's Rationale said the last three choices live in the settling
   routine; the priors reset is at the doors, so it reads "the first three
   … the last two", the notes' ruling above.
3. `boundary_zero!`'s docstring said `init!` hosts it while `init!` called
   `_settle!` directly; `init!` calls `boundary_zero!` again, the primitive
   being the one-liner over `_settle!(fresh = true)`.

Two informational items, both landed as docstring or comment edits: the plan
form `overlay!(model, plan)` merges onto the base the plan was resolved with,
which its docstring now says; and `showerror`'s recipe comment names the
third host. `CheckpointMidFrame`'s message speaks of a checkpoint when
`overlay!` raises it, a reuse the spec ruled; no change.

### What the user should diff-verify

The arc is 4f922f7, c97b1ea, bc46043, 28b0031 and the fix commit, unpushed,
with another session's Appendix A commits interleaved above bc46043.

- `git show bc46043 -- src/model.jl`: `_settle!` against the old
  `boundary_zero!`, and `overlay!`'s two methods against `init!`'s.
- `git show bc46043 -- src/sim.jl`: the door's order of checks and the
  ordinal step-back, against `_enter_checkpoint!`.
- `git show bc46043 -- src/conditions.jl`: the `bases` keyword.
- The rulings above, the priors' placement and the stepper first.
