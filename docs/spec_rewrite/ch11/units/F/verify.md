# Unit F (§11.5): cold verification

**Counts.** 132 phase-1 assertions. 82 inventory claims: 80 MATCH (the R6, R10 F57/F59/F65, R13 and R17 edits are applied as dictated), 2 DRIFT, 0 LOST. 30 ADDED items: 26 glosses and definitions, 4 `####` labels. None changes meaning; one gloss reads circular.

## DRIFT

- **C-054 (antecedent).** Old: "is this count". New: "is this value". The nearest "value" is now the previous sentence's "the value `trace(sim)` hands back", which is the frozen `Trace`, not the length. Fix: "is the length" or "is this frame index".
- **C-040 (seam, R17).** Old bullet label: "The run's `Deployment` and the structural layout." New: "The header also carries the run's `Deployment` and the structural layout." This follows R17's sentence, which already names the fingerprint (the structural layout) and the deployment as header parts. "also" makes them sound like two more items, so the layout reads as something other than the fingerprint. Fix: drop "also".

## ADDED, minor

- C-064's gloss: "what the artifact's run metadata (the header's `Deployment` and `t₀`) names" says the header is what the header's fields name, which is circular. The claim is unchanged. Fix: "...run metadata names, its `Deployment` and `t₀`".
- All other glosses stay within their glossary entries: device, batch, frame, replay (§2.4's own gloss), staging cell, face, binding, claim, greedy claim, contract, component, boundary, snapshot, log, trace header, checkpoint, boundary zero, signal table, prior, executor, root input, deployment, `Build`, termination record, roster and harness writer. No antecedent changes: "It is enumerated" still means the greedy claim, and "it is smaller" still means the allocation.
- The §2.4 pointers at old 7677 and 7700–7702 add no claim. §2.4 (frozen 546–554 and 567–569) lists the deployment and the initial state, and gives replay's bit-for-bit promise.

## Hazards checked

- F57: "the edited-inputs what-if (replay with edited inputs)", unlinked, with no glossary gloss. Correct. F59 wording is correct.
- "fingerprint" appears twice (lines 74 and 87), both times in R17's sense, the layout (D-319's `layout`). The first use comes before R17's gloss. That is optional to fix, since R17's sentence is dictated.
- M51, M52 and M53: nothing lost and nothing doubled beyond what old.md already doubled. The length is stated once, and the bold sentence covers "the trace also carries its length". One soft seam: "the other half of what … requires" (line 115) has lost its old follow-on, "Header plus batches…". The quoted phrase still names both halves, so no fix is needed.
- "per-record": supported. D-176 Rejected (log 6462–6463) puts "a format flag on every entry" under per-batch density, and the glossary's trace record is "the retained form of a drained batch".

## Citations

Every old citation survives with its claim. Each added citation was checked against its log entry and is carried: D-176 Position; D-047 ("trace header extends to initial slot values"); D-254 bullet 1; D-316 (`ignore_stop_requests` on `run!`/`replay!`/`step!`); D-255 bullet 3; D-274 Position; D-038; D-029; D-261 bullet 7; §2.4. Caveats:
- D-319 bullet 1 lists `deployment` among the nine fields, and the cited list omits it (correction 3). The citation now makes the omission visible. Adopt correction 3.
- D-217 bullet 1 says "the number of drains since the capture", not a frame index. old 7688 has the same citation, and it is flagged for track 2 (correction 6).
- D-254 shares a parenthetical with §10.6 at `firing_budget`, so it can read as scoped to that one parameter. This is acceptable by adjacency.

## Bold

There are five bolds: D-176, D-274 bullet 4, D-255 bullet 3, D-217 bullet 2 ("The list only grows", plain in old) and D-029. Each is a ruling headline followed by its entry. None is bold elsewhere in the frozen spec or the other units. The old bolds on a term, a lead-in, "about 2×" and "reversible" are gone.

## Moves

M51, M52, M53 and the bullet-to-paragraph change are done. The deployment gloss moved to R17's sentence (coordinator answer 5). There are no other moves.

## Reader-cold names

- `mixture = 0.5` (line 84) is class 2. It is an aerospace example, an engine's mixture input, and it gets no introducing clause in §11.5 or nearby. Proposal: "an unfed root input such as an illustrative `mixture = 0.5`".
- No Flight.jl machinery is used. "staging shim" is never defined in the spec (old has it too).

## Re-check (after the fixes and R26–R28)

`check_unit.py ch11 check F` reports `checks failed: 0`.

**Fixed:**
- C-054 now reads "this frame index".
- C-040 drops "also".
- C-064 now reads "names, its `Deployment` and `t₀`".
- `mixture` is introduced as illustrative.
- R27 matches the brief. D-218 bullet 1 carries it: live staging is discarded, and devices run as readers.
- R28's cap wording matches the brief and D-218 bullet 2.
- R26 matches the brief and D-319 bullet 1.

**New breakage:**
- **R26, link placement.** The deployment's first use is now line 76, in the checkpoint list, but its glossary link and gloss sit at line 90. Fix: move the link to line 76, with the gloss as its own sentence.
- **R28, antecedent.** In "one small allocation per drained batch, plus the values boxed into it", the nearest noun for "it" is "batch". `src/trace.jl` 94–99 boxes the values into the allocated `entries` vector. Fix: "...plus the values boxed into that allocation".

**Minor:** The header now names the deployment three times in a row: the list at 76, R17 at 90 and line 94. It is redundant, not wrong.

## Re-check 2

`check_unit.py ch11 check F` reports `checks failed: 0`. The deployment is linked once, at its first use on line 76. Its gloss is a sentence of its own and matches the glossary. Line 90 is unlinked, and no antecedent shifts. R32's "boxed into that allocation" matches the brief and `src/trace.jl` 94–99. Line 94's repetition stays as the rewriter chose. It is redundant, not wrong.
