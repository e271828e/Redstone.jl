# Notes: increment 87, the limited double integrator

The user delegated the increment on 2026-11-04 and was away. These are the
coordinator's rulings, each with its reason, for the user to reverse at the
arc's review. Nothing was pushed.

1. **The keyword `x0` became `q0`.** The prototype read the row's `x0`
   beside the leaves `q` and `v` as a mismatch: `v0` names its leaf and
   `x0` does not, and in the library `x0` means the whole initial state,
   which here is the pair. Ruled for the leaf-naming rule, `q0 → q` and
   `v0 → v`, as `x0` and `s0` name a bare store's one leaf. The cost of
   reversing is the field, the constructor, the docstring and three test
   rows.
2. **`signal(u)` was dropped from the block.** The coordinator first asked
   the prototype to mirror increment 86's coda, which reads
   `LimitedIntegrator`'s input through `signal(u)` because its reset form
   names the input side. The block has no reset form, so the indirection
   read as a path that does not exist; the derivative and the leave guards
   read `u` directly. The four event tuples stay grouped under
   `limit_events`, so a reset form splits `state_events` on `R` as
   `LimitedIntegrator`'s does and brings `signal` back.
3. **Promotion left as it is.** A scalar `q0` beside vector limits throws
   from `promote`, an `ErrorException`, not an `ArgumentError`;
   `LimitedIntegrator` behaves the same. Out of scope; a loose fix would
   refuse on both blocks.
4. **The row's "first handler" claim corrected** in the docs commit: the
   reset handlers of increment 86 already write a value other than a limit.
   What is new is a hit handler writing a second leaf its guard does not
   read.
5. **No reset form.** Not in the row. The prototype's reading on its cost
   and the two questions it needs ruled, the `v` a reset writes and a
   reset onto a limit with `v0` pointing inward, are in the brief's
   "Readings", item 5.
6. **The prototype did not re-run its mutant sweep after the rename.** The
   assertion count held at 2837; the cold review re-runs the list against
   the landed code.
7. **The review's findings, adjudicated.** Two medium and four low.
   - *A return past the stop after the arrival cascade* (medium). After
     the hit and the leave fire in successive rounds of one boundary, the
     block rests free on the limit with the hit predicate holding, so an
     input turning outward within the rest of that step carries `q` back
     past the limit as two crossings §2.3 cannot see. Accepted as a defect
     and landed as documentation only, in the docstring and the row. The
     fix the reviewer sketched, a hit guard that reads `u` while the block
     rests exactly on the limit, `x.q == c.upper && x.v == 0 ? u : x.q -
     c.upper`, re-saturates the probe's scenario under both policies and
     passes the increment's pins, but it changes the guard form the
     companion weighed for the single integrator and it was not run on
     the vector form, the full suite or the exact-zero corner. That is
     the user's ruling. The coordinator recommends adopting it as a
     loose fix after those three checks: the branch is taken only at the
     exact rest the handler writes, so no localization bracket ever sees
     it, and the hit's root-finding stays on `q - upper`.
   - *No lower-side leave test and the vector `hit_lower` pinned on
     component 1 only* (medium): seven survivors, landed as the mirrored
     scalar and vector tests.
   - A `q0` on a limit with an inward `v0` loses `v0` at boundary zero
     (low): documented; the same rule reading 5 recommends for a reset.
   - The docstring's vector-handler sentence, the boundary-detected
     departure's "at the first boundary after", and the row's offset
     bound (low): corrected. The inherited `Float64` wording shared by
     four docstrings and `LimitedIntegrator`'s departure sentence stay.
   - Three over-long lines (low): rewrapped.
