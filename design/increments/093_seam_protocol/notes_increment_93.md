# Notes: increment 93, rulings made while the user was away

The user stepped away on 2026-11-11 after the code commit e7dacf9, with the
cold review running, and asked the coordinator to proceed alone unless a
finding raised a significant design question. These are the rulings the
coordinator made on the review's findings, each with its reason and what it
costs to reverse. Nothing was pushed. The findings are the reviewer's F1 to
F15, summarized in the brief's record.

## Rulings that changed the design

1. **F2: `init!` hands the backend the carried state it was bound with.**
   The review showed that a second `init!` under the same condition
   continued the first run's proposal: a proposing stub gave a different
   state and a header of `(8, 7)` where a fresh run gave `(1, 0)`. §2.4 makes
   a run a function of its condition, so the carried state cannot survive
   `init!`. The `Model` reads `checkpoint_stepper` once when it is built,
   keeps the value as `stepper_bound`, and `init!` passes it to
   `restore_stepper!` before boundary zero. Reason for this mechanism: it
   uses the pair every backend already states, so no backend can forget a
   reset. Rejected: a `reset` call each backend states, and the state
   surviving `init!`; both are in D-452's Rejected list. Cost: `Model` gains
   a seventh field, typed `Any`. To reverse: drop the field and the one
   line in `init!`, and add the generic.
   This is the one ruling that adds to the seam's contract. It follows from
   an existing law, so the coordinator did not hold it for the user, but it
   is the first to look at.

2. **F12: a model with no continuous state asks its stepper for no
   proposal.** `_frame_steps!` called `propose` on a stateless model, whose
   boundaries then followed the proposal, though D-156 says the stepper is
   never called there. The loop now reads the proposal as `nothing` when the
   state buffer is empty. Reason: the code conforms to a standing ruling.
   No alternative was weighed.

## Rulings that left the design alone

3. **F1: a proposal that does not advance the clock is left to increment
   4.** Reversed by ruling 9 after the delta review. As first ruled: a stub
   that proposes zero, a negative length or one below the
   clock's resolution never ends its span, with every attempt accepted. The
   reviewer recommended refusing a non-positive proposal now. The
   coordinator did not: a refusal needs an error kind, and the roadmap's
   open decision on the floor, degrade or throw at `h_min`, decides what
   that kind is. A floor also covers the whole family, since a proposal at
   or below zero is below any `h_min`. No backend in `src/` proposes. The
   gap is named on the `pending.md` bullet and under the roadmap's "The
   floor". To reverse: one comparison in `_clamped` and a diagnostic kind.

4. **F3: the remainder after a `t*` is offered whole, and the spec now says
   so.** §10.2 said the `Model` asks `propose` before each step, and the
   localization loop offers each remainder without asking. The reviewer's
   other option was to ask before each remainder. That is the roadmap's open
   decision "What the notice does to the proposal", which is increment 4's,
   so the coordinator amended the sentence to match the code and added the
   point to that decision. Fixed-step trajectories are the same either way.

5. **F15, projection and the notice: recorded as an open decision.**
   `x_projection` writes the state at every boundary and raises no notice.
   Neither the spec nor D-452 says so. It is a new entry in the roadmap's
   open decisions for increment 4. No sentence was added to the spec.

6. **F15, a hook that returns `nothing`: left as it is.** A hand-written
   hook under the old contract now fails as a `StepError` wrapping a
   `TypeError`. It fails at once and names the frame. A check with a
   message of its own would be error handling for a contract violation, and
   no test pins the accident.

7. **M20 accepted as a survivor**, on the reviewer's judgement: the clock
   written after the nonfinite check is equivalent for every backend in the
   tree, since each leaves the clock at the step's end.

8. **`CursorFrame` has `==` and no `hash`.** It predates the increment. Not
   touched.

## After the delta review, on 2026-11-12

The reviewer verified 2db7ae1 and agreed with every ruling above but the
third.

9. **D1: the `Model` refuses a length that does not advance the clock.**
   This reverses ruling 3. The reviewer showed the hang cannot be
   interrupted: the frame runs inside the advance's interrupt mask (§12.4),
   and a SIGINT sent into a stuck frame was never delivered. Ruling 3's
   reason was that a refusal needs an error kind the floor decision will
   shape. It does not: `InternalInvariant` is the exception a framework
   self-check raises, outside the kind set (D-215), and a backend is
   framework code. The check is one comparison in `_clamped`, where a
   proposal becomes a length, so it covers first offers and retries. D-452
   gains the bullet, a Rationale paragraph and one rejection, and §10.2
   states it. What it does not cover is named on the `pending.md` bullet: a
   proposal that advances by almost nothing, and a backend that keeps
   rejecting. To reverse: drop the comparison and the helper.
   This is the second ruling that adds to the seam's contract, after ruling
   1.

10. **D4, a survivor accepted.** `init!`'s reset moved after boundary zero
    survives, because the test stub's notice edits no carried state. D-452
    says "before boundary zero", which matters once a backend's
    `discontinuity!` edits what it carries. Increment 4's controller does,
    and its re-initialization test will pin the order. Changing the stub's
    carried tuple now would touch five existing pins for no backend in the
    tree.

11. **The recording test stub throws past 10 000 attempts.** A mutant that
    makes a loop run without end now fails its test where it filled 25 GB
    during the review. Test code only.

12. **E1 and E2, from the reviewer's check of ruling 9.** The refusal named
    the last component the previous boundary dispatched, so `_stalled` now
    sets the cursor to integration with no component, as the nonfinite
    check does. A proposal that is not a number passed the comparison, since
    the clamp reads it as the whole remainder; it is refused with the rest.
    An infinite proposal stays legal and takes the span: the reviewer's
    `isfinite` would have refused it. A controller's proposal goes `NaN`
    when its error estimate does, so the case is one increment 4 can reach.

## Corrections with no ruling in them

- **F5.** The "ulp edge" the coordinator told the user about cannot happen.
  A proposed length is below the float distance to the span's end, so the
  sum cannot pass it. What can happen is a sliver: a step that ends just
  short and leaves a last step of about an ulp. `pending.md` and the
  roadmap now say that.
- **F4.** D-452's Rationale misstated the trial buffer's cost for a model
  with localized events. Edited in place, since the entry is this
  increment's.
- **F6 to F11.** Missing tests, added. Every mutant the reviewer left alive
  now dies, M20 excepted.
- **F13, F14.** A local renamed, a comment's count, a walkthrough sentence
  and one qualifier in §10.2.
- **D2.** Two rulings of D-452 stood unbolded in §10.2, and one of its
  bullets held three rulings. Bolded and split. §2.4 left its Spec field,
  which lists where the mechanism lives.
- **D3.** The cost sentence again: a localized step pays no extra copy where
  its arrival raises a trigger the budget still admits, validated or not.
- **D4.** A comment that overstated D-156, and an assertion moved to a
  testset whose name states it.

## The user's rulings on return, on 2026-11-12

- **Ruling 1, the mechanism, is reversed.** The user kept the requirement
  and chose the explicit call: `reset_stepper!(stepper)`, a seventh call of
  the protocol with no default, which `init!` makes before boundary zero.
  `Model` loses `stepper_bound`. The coordinator had argued for the field
  because no backend could then forget a reset. The user's ruling that the
  protocol has no defaults already makes a forgotten call a `MethodError` at
  the first `init!`, so that argument did not hold, and the notes above
  overstate it. What remains is a field on the `Model` against a call in
  the protocol, and the user prefers the call. D-452's bullet and the
  rejected alternative are swapped.
- **Ruling 9 stands.** The user agreed to the refusal of a length that does
  not advance the clock.
