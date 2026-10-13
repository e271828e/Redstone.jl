# Orchestrator touches to chapter 11's units

Each edit the orchestrator made by hand, in order, with old and new text.

1. Unit B, `new.md` line 118 (verifier B's re-check): "Decimation is its
   additional keep-every-kth retention policy" → "Decimation is the log's
   additional keep-every-kth retention policy". Same change in
   `inventory.json` and `rulings.md`. `inventory.json` was rewritten with
   one-space indentation, contents otherwise unchanged.
2. Unit B, `inventory.json` C-140: `"ruling": "R5"` → `"ruling": "R30"`.
3. Unit C (final verifier 1, P1-25 entry 38): "the interrupted
   [boundary](#g-boundary), a published consistency point ([§12.7][s12-7])."
   → "the interrupted [boundary](#g-boundary) ([§12.7][s12-7]), a published
   consistency point." Rewrapped with the next line. Inventory span changed to
   match.
4. Unit A (final verifier 1, same pattern): "[buffers](#g-buffer) (the
   framework-owned vectors backing continuous state, [§9.4][s9-4])" →
   "[buffers](#g-buffer) (the framework-owned vectors backing continuous
   state) ([§9.4][s9-4])". Inventory claim and `added` span changed to match.
5. Unit F (final verifier 2, optional note on P2-7): "is a fact about one
   [binding](#g-binding), the value passed at `attach!` that makes a device
   framework-legible, not about a category of writers." → "is a fact about one
   [binding](#g-binding), not about a category of writers. A binding is the
   value passed at `attach!` that makes a device framework-legible."
   Rewrapped. Inventory span changed to match.
6. Unit H (final verifier 2, optional note on P2-20): "[D-310][d-310] leaves
   its design open" → "[D-310][d-310] leaves the bridge's design open", and the
   paragraph's next three lines rewrapped. Inventory span changed to match.
7. `rulings_batch.md`: the status script had joined 52 `### B-n` headings
   onto the preceding Status lines. Newlines restored; item text unchanged.
8. Units A, C, F and H (both final verifiers' re-checks): reflowed with the
   editorial fixer's `wrap.py apply <file> all` (scratchpad copy, identical
   to the one embedded in `chapter_fixes_1.md` entry 51). Line breaks only:
   each unit's `show-new` normalized text is byte-identical before and after,
   and every checker passes. Changed lines: A 11, C 10, F 25, H 14.
