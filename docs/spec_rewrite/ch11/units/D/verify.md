# Unit D (§11.4): cold verification

**Counts.** 139 inventory claims: 136 MATCH, 2 minor DRIFT, 0 LOST, 1 deleted by ruling (C-106 → `deleted.md`, R19). Phase 1 found 101 assertions. ADDED: 39 items, all glosses, transitions or ruled text, none meaning-changing. `check_unit.py`: 0 failed.

**DRIFT**
- C-060. Old: "One representation, one mechanism." New: "Every staging cell has one representation and one mechanism." The old line says all cells share one. The new one can read as each cell having its own. Fix: "All staging cells share one representation and one mechanism."
- C-066 (borderline). Old: "follow the compilation, all of them to staging." New: "follow the compilation, so every one of them moves to staging." Adds a "so". The meaning holds. Fix if wanted: "follow the compilation, every one of them to staging".

**Rulings.**
- R4: both sentences are scoped to "a device's staging cell". The added sentence matches the brief's text. D-200 Rationale (log 7364, "several tasks may stage concurrently") and the `StagingCell` docstring ("merged past by another stager … the retry re-reads") carry it. It is not called bounded. Leftover, not in R4's scope: line 149 "conversion on the device task" and line 183 "on the writer's own task" read loosely for the harness shim, whose `stage!` runs on any calling task. Propose "on the staging task".
- R7: the framing matches the dictated text. A diff of the example shows every word kept. Only links moved, bold became italics, and four glosses were added (boundary, peek in the scope note, port, component). The R7 scope note keeps its wording but gains the peek gloss. That is the link-at-first-use rule, not a claim.
- R19: only the "Alternatively" sentence was deleted, and `deleted.md` holds it verbatim. D-045 is cited at "must *not* ride along" and listed as Rationale-only (Rejected, log 1448–1449, "aircraft semantics duplicated per device"). Correct.
- R5, R6, R10 F15, R11 and R13 were applied. M9 merges 7461–7463 with 7515–7516 and keeps both "levels doctrine" and "levels, never deltas". M10 moves 7489–7514 up. No other moves. "The levels doctrine is untouched" now comes after the definition. One new forward use: "not mapping state" (line 55) comes before the mappings subsection. It is plain English, so this is minor.
- The sketch is byte-identical.

**Citations.** Every old citation survives. Each added one checks out: D-024 (four Position clauses), D-104 (policy, per-attachment shape, roster schema, scatter, shim, all of which stand per D-202), D-202, D-044 (both clauses survive D-174), D-045 bullets 2, 3 and 4, D-174 (Position for the greedy claim, Rationale for the harness), D-105 Rationale, D-106 Rationale, D-026 Rejected, D-200 Rationale.

**Bold.** There are 9 bolds, all ruling headlines with their entries. D-024 has 4, each a separate semicolon clause. D-104 has 2, split by a semicolon. D-045 has 2, bullets 2 and 3. D-202 has 1. No bold is on a mechanism, lead-in or consequence. The other units' new.md files bold none of these rulings. In the frozen spec, D-045 is bold only at §4.3 (old 931), which is a different ruling. Appendix A's "**Levels, never deltas**" (old 12352) is an index label pointing at §11.4, not a D-cited bold. Note it for landing.

**Glossary links.** Six terms were doubled: batch (3 links), device, staging cell, coalescing, root input and drain. That makes seven extra links, likely the brief's "seven". Each now has one link at its first use. Two small gaps: *port* and *component* first appear inside the face and root-input glosses (lines 22 and 27), but their links come at 229 and 285.

**Reader-cold names.** (3) FlightCore with `assign_input!`: fine. (2) `flaps`/`gear`, "trim offsets, flap detents", "expo strength" and "avionics" each need one introducing clause. *CAS* is never spelled out anywhere in the spec. ZOH is defined at §3.

**Other.** The rewriter's open point stands. "The worked example … works that hazard through" points at `flaps`/`gear`, which the example does not contain.

## Re-check

`check_unit.py ch11 check D`: 0 failed. The bold count is still 9 and the sketch is unchanged.
- C-060 ("All staging cells share one…") and C-066 (no "so") now match.
- C-007, the coalescing gloss: "(the merge by compare-and-swap, or CAS, keeping one pending set of writes per device)". The gloss is accurate, but its commas make "CAS, keeping…" read as a new clause. The fix keeps one parenthetical: "(the CAS merge, CAS being compare-and-swap, that keeps one pending set of writes per device)". You could also drop the gloss's "the merge by" and write "a compare-and-swap (CAS) merge" in the prose before the link.
- C-049, "on the staging task": this term appears nowhere else in the frozen spec or in any unit. It is accurate, since D-200 calls harness writers "the staging tasks". R4's text does not name this sentence, so the R4 tag rests on the coordinator's approval. Gloss it once, or write "on the task that stages".
- Inventory and rulings.md agree with new.md. Nothing else broke.

## Re-check 2

`check_unit.py ch11 check D`: 0 failed. The coalescing gloss ("the CAS merge, CAS being compare-and-swap, that keeps…") and "on the task that stages" appear the same way in new.md (lines 12 and 149), inventory.json (C-007, C-049, added) and rulings.md. Both read cleanly. Nothing else broke.
