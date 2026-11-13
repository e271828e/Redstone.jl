# Notes: increment 95, the coordinator's record

What the coordinating session settled with the user that the brief and the
roadmap do not carry, and the state a successor needs. The user was present
throughout, on 2026-11-12 and 2026-11-13.

## State at c58ce63

- The docs commit is 46b7674, the brief with the patch b8dd909, the code
  commit c58ce63. Nothing is pushed.
- The gate read 9870 of 9870 in the prototype's worktree on the tree the
  code commit holds, and four routed runners read 1279 of 1279 on the real
  tree before the commit.
- Next: the cold review, the coordinator's adjudication, the fixer's commit,
  the reviewer's delta check, the review's record in the brief, the user's
  diff of the arc, and the push on the user's word.

## Where each ruling lives

- The cut of the roadmap's increment 4 and its ten decisions: the roadmap's
  section "Ruled on 2026-11-12", commit 2804435.
- The float distance everywhere, the nearest clock and the exact origin, with
  the evidence weighed: the same section, commits 84379eb and 46b7674.
- The eight readings and their outcomes, ratified on 2026-11-13: the brief's
  "Readings the prototype took".

## Rulings recorded nowhere else

1. **A fixer agent lands the review's fixes.** `increment_rules.md` has the
   coordinator land them when the prototype is the implementation. The user
   consented to a fixer, to spare the coordinator's context.
2. **The coordinator's context.** The user asked that the increment finish
   before the coordinator passed 500k tokens. The rule agreed: under 430k
   when the build lands, the coordinator runs the review, and over it a
   fresh session does, from the brief, these notes and the `pending.md`
   bullet. It read 422k at c58ce63, so the same session went on.
3. **The door check stays.** The user asked whether the check of the clock's
   integers at the origin's door could go too, the case being so rare. It
   stays, since unchecked integer arithmetic wraps without an error and the
   clock would be wrong in silence. The form built is the lightest: the
   loop's formula evaluated once with checked operators at the run's two
   ends.
4. **A loose fix is queued.** `bind_schedule`'s `anchor.T / Δt_base` is the
   last site that raises a raw `OverflowError` on periods of extreme
   magnitude. The user ruled on 2026-11-13 to fix it after the increment, as
   its own commit: the division in `Int128`, `_as_int` returning `nothing`
   for a quotient past `Int`, the existing `:anchor_period` refusal, one
   test, and the retired sentence in `pending.md`.

## Open, to carry forward

- D-457's reason for rejecting a cached limit folded into `_last_frame` is
  the tidy agent's wording. The user and the coordinator stated none.
- The `t*` clock is written as `t_seg + θ★·h′` with no guard. Late in a long
  run the product could round to nothing and give two boundaries one clock,
  where §10.4 says `t* = tₙ` is structurally impossible. This is an
  inference from the code, not probed. It is outside the increment.
- The roadmap's item 4 lists "the descriptor format bump and the inspector's
  pin". The descriptor's deployment body is the build's alone, so nothing in
  it changes when `BS3` or `h_min` arrive. Check the line when increment 4's
  brief is drafted.
- A `Δt_base` spelled two ways in a model with no discrete component takes
  one trajectory and compares unequal under D-454.

## Scratch

The session's scratchpad holds the worktrees `wt_inc95`, the prototype's,
and `wt_inc95_fd`, the coordinator's two measurements, with their gate logs
and the prototype's notes. Both worktrees can be removed after the push.

## 2026-11-13: the review and the fixer's commit

- The cold review ran at 290801c: the gate 9870 of 9870, ten findings. The
  coordinator adjudicated them, and a fixer landed the fixes as one commit,
  "Fix increment 95's review findings", recorded in the brief's "The
  review's record". F1's ruling stands as worded: a float origin is taken
  at its exact value or refused, with no round-trip rule. F8's check stays
  and its comment says what it guards.
- The loose fix of ruling 4, `bind_schedule`'s division in `Int128`, lands
  as its own commit after it.
- Still open: the reviewer's delta check, the user's diff of the arc and
  the push. The `t*` clock that rounds onto its segment's start is
  confirmed by the reviewer's probe and stays outside the increment.
- Later the same day: the delta check ran at a7df733, and the user ruled
  the `t*` clock. A loose commit fixes it: the localization loop decides the
  degenerate case on the clock, at least `nextfloat(t_seg)`, and a clock
  that reaches the step's end folds into that boundary (§10.4). The
  other items under "Open, to carry forward" stand, except the `Δt_base`
  one, which D-454's Rationale now states.
