# Unit F: cold verification

Read against the frozen h1 spec and log and `src/sim.jl` at 1fee0fc.

## Counts

179 claims: MATCH 177, DRIFT 2, LOST 0. Three matches are held in `deleted.md` and two in §12.6, checked at 9584–9588. ADDED: 0 that change meaning, and 1 open question.

## DRIFT

- **C-043, citation scope.** Old: "… or of the execution cursor (D-261, D-317)." New: the citation sits after "`frame!`'s return value", which leaves the cursor clause uncited. Fix: move the citation to the sentence end, after the gloss.
- **C-046, citation scope.** "boundary zero ([§14.5])" became "… all count ([§14.5])". Minor. Fix: cite it right after the boundary-zero gloss.

## Hazards checked

- **R4.** §13.5 keeps what §12.6 cites it for: the build, the validation and the mask. Every claim of the cut is held in §12.6 or listed in `deleted.md`.
- **R9.** All seven mechanisms are named, closures and observation-by-path among them.
- **R12.** Clean. The bare "roster operations" in §13.6 is §11.3's device roster.
- **F51, F54 and F67.** Each matches the code. `_advance!` calls `_stop_hit` before its loop. `_t_bound` runs before the ignore list is read. `run!` raises `UnboundedRun` before `_run_body!`.
- **F57.** The in-frame scope matches survey part E.
- **R23.** No drift.
- **Code blocks.** They differ only by F52 and F56.
- **Define-before-use.** Correct overall, with two slips:
  - The trace-header gloss uses "boundary zero" before that term's gloss. Fix: "(the trace's fixed preamble)".
  - `t*` first appears at line 65, before its §10.4 pointer. Fix: cite §10.4 there.

## Citations

All added or replaced citations hold, with one exception. D-030's Position carries only the bold's "rejoins" clause. The discard and promote clauses rest on its Rejected entry, as `rulings.md` already notes. Replacing D-261 with D-316 at the mask is right.

## Bold

There are 15 bold spans. Each heads one ruling with its entry, and none repeats.

## Reader-cold names

- (2) "Touchdown overload … `m.crashed`" has no component. Fix: "A landing-gear strut's touchdown overload …", as at spec 4717.
- (1) `robot2d` and FlightApps take R10's clause. Fine.
- (3) FlightCore is named as the predecessor. Fine.

## Open question

The new §13.3 pointer says "the same line … client by client". The doctrine calls output-device reads "inspection bindings" that see "every public cell". Unit B's §13.3 puts bindings in the strict service row. Read together, these imply a binding takes the instance walk, which R2 forbids. Should the "Output devices" sentence or the pointer change, or should a landing edit fix it?

## Other

- The opening sentence, "how a model ends its own run", understates the section.
- "The rule authors are taught is this" is hard to parse.

## Re-check

I re-read `new.md` and `claims.md` after the fixes and R29. Counts: MATCH 179, DRIFT 0, LOST 0, ADDED 0 that change meaning.

- **C-043.** The citation is now at the sentence end, after the cursor's gloss, so it covers the cursor clause again.
- **C-046.** §14.5 now follows the boundary-zero gloss, so it covers boundary zero only.
- **`t*`.** Line 67 now cites §10.4 at the first use.
- **Trace-header gloss.** "(the trace's fixed preamble)" is the first clause of the glossary's `#g-trace-header` entry word for word. Boundary zero no longer appears before its own gloss.
- **Touchdown.** The new clause "A landing-gear strut's touchdown overload" follows spec 4717 and claims nothing more.
- **"Authors are taught this rule."** It parses, and it still leads into the rule.
- **The opening.** It now names three topics: how a model ends its own run, how an advance chooses which requests to honour, and what the run records. Each matches a label (detection, the policy and scan, the termination record). It claims nothing the section does not state.
- **R29.** Both sentences match the dictation, with §13.3 linked. No sentence now implies a binding takes the instance walk. "Sees every public cell" applies to inspection. The output-device sentence then qualifies it with strict resolution at attach. The front end's panels are not bindings.
- **D-406.** Its Position carries "attach resolves a binding's reads through the one collecting resolver". "Strictly" rests on R2's code evidence (`_rebase`, `:past_generic`), not on the Position's wording. Acceptable.
- **Neighbours.** Every edit leaves the surrounding sentences intact. The pointer sits between the stop-scan sentences and the ignore-list sentences, and "It binds at an advance" still refers to the ignore list.
- **Code blocks.** They still differ only by F52 and F56.

No open questions.
