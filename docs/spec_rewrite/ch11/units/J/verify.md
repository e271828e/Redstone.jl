# Unit J (§11.8) verify report

**Counts.** 82 phase-1 assertions. 91 inventory claims: 88 MATCH, 3 DRIFT (all minor), 0 LOST. 1 meaning-changing ADDED. C-091 is cut by R6. D-136's Rejected list (log 4435, 4439, 4442, 4446) carries all four items.

## DRIFT

- **C-005.** Old: "…through the harness writer, [D-200])". New: "(the framework-owned write path `stage!(sim, …)`, [D-200])". The citation now sits inside the gloss, so it reads as citing the gloss. C-015 has the same problem with D-136 and D-200 inside the diagnostic-cell gloss. Fix: put each citation after the gloss's closing parenthesis.
- **C-038.** Old: "The batch is exclusively the loop's …, so the binding rule … holds by construction." New: three sentences, with "That rule therefore holds" placed straight after the rule is stated. The reason is now two sentences back. Fix: "Because the taken ring is exclusively the loop's …, the binding rule holds by construction."
- **C-089.** Old: "Because the log retains snapshot references ([§11.2])". The new text moves §11.2 to the decimation sentence, so the claim that the log retains references loses its citation. Fix: cite §11.2 on both sentences.

## ADDED

- "`DiagValue` is any value of the closed kind set." Appendix C's closed set includes error kinds. `DiagValue` is `Union{KINDS...}`, the 13 kinds the channel carries (`src/dataplane.jl` 170–176). Fix: "`DiagValue` is any value of the kinds the channel carries."
- The new display block shows six fields, but the text just above it says "Per writer it carries four things". Pre-existing count, not a drift. Consider adding "beside `who`".

## Hazards

- **R5.** J holds every claim that B maps to J's old.md: B C-027 → C-053, C-028 → C-048–052, C-136 → C-065. B's dropped "timestamps the loop takes at frame top" was out of date. D-240 says publication, and J says so too. The status keeps its bold here with D-136. B states it plain. The terminal snapshot's home is whole here. `totals`: J keeps two sentences plus a pointer, and nothing is lost. But the two units point at each other. B's new.md 210 cites §11.8 for the monotonicity, and J cites §11.2. B never states the reason (the log retains references). So J is the real home, against R5's wording. Settle this at merge.
- **F72/F65.** The new wording is as dictated. "At most sixteen values" keeps the old per-record scope. "Values" means the same as the old "entries". The loop's record can hold 32 (rulings Q1). That is still open.
- **F65.** Every change keeps its sense: diagnostic cell ×13, value ×3. "The taken ring" for "the batch" is dictated. It is narrower than src's batch (ring plus suppressed counts), but the ownership claim still holds.
- **F52.** As dictated. D-305 bullet 1 carries it.
- **R18.** `src/dataplane.jl` 429–436 matches field by field: `who::String`, `recent::Vector{DiagValue}`, `suppressed::KindCounts`, `totals::KindCounts`, `heartbeat::Union{Nothing,Float64}`, `task_state::Union{Nothing,Symbol}`. The frozen spec uses `WriterStatus`, `DiagValue` and `KindCounts` nowhere else, and no other unit's new.md does either. In the log, only D-270 (11173) names `WriterStatus`.
- **`maxlog`.** The old text did not introduce it either. It appears nowhere else in the spec. It is an ordinary Julia name (the logging keyword), but it is opaque here. Suggest one clause: "Julia logging's per-site cap".

## Citations added

Each one checked in the log. The named field carries the claim:

| Entry | Field (log lines) |
|---|---|
| D-136 | Position (4389–4393); Rationale (4398, 4402–4405, 4407–4408, 4414–4419, 4421–4423) |
| D-200 | Position (7360); Rationale (7364), for the CAS |
| D-317 | frame bullet (13616–13618) |
| D-193 | Position (7074–7077) |
| D-241 | Rationale (9172–9174) |
| D-305 | bullet 1 (12943) |

Every old citation survives or moved with its claim.

## Bold

There are 8 bolds: 7 on D-136 (1 from its Position, 6 from its Rationale) and 1 on D-241 (Rationale). None is stated twice. A grep over the other units' new.md files and the frozen spec finds no other bold on D-136, D-193, D-200, D-240 or D-241. §11.2 6920 is now plain in B, and §12.2's "**Liveness heartbeat.**" is a ch12 label. One flag: "Presentation is where `maxlog` lives" is closer to a lead-in than a headline clause. The decision is "That threshold is presentation policy, not channel policy." Consider moving the bold there.

## Moves and names

There are no unruled moves. Order is unchanged. The new labels split the survey's "Published status" and "Allocation". Reader-cold names: none in class 1 or 2. `UDPInput` is introduced in §11.6.

## Re-check (after the fixes and R30)

- **Citations out of glosses** (C-005, C-015). The citation scope is now right. The back-to-back parentheses "(gloss) ([D-…])" are the frozen spec's own pattern (50 instances), so they are acceptable. The roster and framework-status glosses still hold §11.3 and §11.2 inside them. These are section pointers that fit their glosses, so they are fine.
- **C-038.** The rule is stated first, then "Because the taken ring …, the binding rule holds by construction." The cause and its direction are restored, and the antecedent is clear.
- **R30/C-089.** J states the claim with its reason, "retains snapshot references ([§11.2]), so `totals` is monotone", and the decimation consequence follows. §11.2 now supports only the log's retention. J's pointer for the claim is gone. B's new.md line 210 cites §11.8 for the monotonicity and keeps re-decimation, so the pointers no longer go in a circle.
- **`DiagValue`.** Matches `src/dataplane.jl` 176.
- **Bold.** "That threshold is presentation policy, not channel policy" is the decision. D-136 carries it in its Rationale (4414) and its Rejected list (4455–4456). "Presentation is where `maxlog` lives" is now a plain topic sentence. There are still 8 bolds, none doubled.
- **Wrap (cosmetic).** Three lines now run past 80 rendered columns: "policy** ([D-136]). Counts keep accumulating …", "`DiagValue` is any value … `KindCounts` is the", and the ragged "snapshots. So / `log_every`" break. They need re-wrapping.
- **check_unit.py ch11 check J.** 0 checks failed. No old words are uncovered, and no new words are uncovered.
