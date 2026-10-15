# Unit A verify

Counts at first pass: 136 claims. MATCH 132, DRIFT 4, LOST 0. ADDED 34 (glosses, roadmaps, labels, F21), none beyond its ruling. Splits are appended to verify_phase1.md.

## DRIFT (first pass; all four fixed, see Re-check)

- **C-020 (V20).** The tail's new gloss left "It" pointing at the tail. "As its `ControlRequestedStop`" also made the issuer the source itself, not its payload (§13.5 10444, D-203).
- **C-016 (V14).** The §12.4 citation stopped covering "sets exactly this stop, with no separate entry point".
- **C-085 (V95).** The added D-136 also covered the `Task` handles, which are D-193's.
- **C-111 (V124).** The snapshot gloss defined a *stale* snapshot.

## Citations

Every old citation survives (link counts compared). I checked each added entry against the log, and each carries its claim: D-022, D-021, D-132, D-203 b3, D-106, D-268 b1, D-133, D-317 b6, D-027, D-270 (annotation), D-028, D-114, D-128, D-310 b1, D-256 b3 and D-136. D-310 on the issuer list and the front end follows R2's dictated citation.

## Bold

14 spans, each a ruling with its D-entry. D-022's bold is gone. D-027 ×3, D-028 ×2 and D-268 ×2 each bold separate semicolon items or bullets. Nothing is bold twice, here or elsewhere in the spec.

## Moves

M1–M6 are done. The extra move of the pause-block sentence (C-027, old 8635–8636) is acceptable. M1 lifts rows 19–22 only, which strands the sentence, and F8's "below" needs it inside the pause paragraph. As a result, "`step!` … blocks the same way" now points at the condition variable. That is still true under D-268 b1.

## Reader-cold names

- `Control`: now introduced (see Re-check).
- "the bridge": now points at §11.7.
- FlightCore's `nthreads` error is class 3, which is fine. There are no class 1 or class 2 names.

## Other

- The calling-task gloss says "invoked `run!`" in a sentence about `run!` or `replay!`. It matches the glossary, so this is for track 2 only.
- The E2 passages are verbatim apart from F16 and a paragraph break before "Undersized sessions".

## Re-check

I re-checked every changed sentence and re-ran build_inventory: 136 claims, 34 added, 0 checks failed. The four DRIFT fixes, R15 ("stop command … holding its issuer"), the §11.7 bridge pointer and the plain D-027 and D-028 clauses all hold. "The issuer lands" has a clear antecedent.

- **V7.** D-256 says "the periphery's own types", plural: `Control` and the plane. "The periphery's own type" can read as its only type. D-256 also never says `Control` holds the control plane. That comes from the glossary. Fix: "`Control`, one of the periphery's own types (D-256), the one that holds the control plane".
- **V95.** The new cell gloss, "a writer's own holding place for runtime diagnostics", drops liveness (glossary: "runtime diagnostics and liveness"). The next sentence restores it. Optional fix: add "and liveness".

Second re-check: V7 and V95 are fixed, and their neighbours read correctly. build_inventory: 136 claims, 34 added, 0 failed. Clean.
