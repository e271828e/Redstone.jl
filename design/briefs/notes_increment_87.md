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
