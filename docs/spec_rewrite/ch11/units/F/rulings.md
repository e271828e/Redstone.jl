# Unit F (§11.5): rulings

Rulings applied: R6 (the claim-source rejection kept as a one-clause verdict
with D-176), R10 F57, F59 and F65, R13, R17. R12 names nothing new in §11.5.
Moves: M51 (the length merged into the `Trace` paragraph), M52 (why the header
holds the deployment and the clock, up after the header's contents), M53
(primary record into the default paragraph). The one-item bullet list became a
paragraph whose topic sentence is its old lead-in. Four `####` labels.

R10 grep follow-up. F59: "this count" (old 7667) became "this value", since
the length is now a frame index; "the number of drains since the header was
taken" stays, as it holds under `init!`. F57: no other "what-if" in the unit.
F65: no other bare "cell" for a staging or diagnostic cell.

Reserved-word rewordings in touched sentences: "masked (touched) entries"
became "masked (touched) batch entries" (the glossary compound; §12.7 9465
uses it); "a class of writers" became "a category of writers"; "in-class
with what the retention carve-out already admits" became "of the same sort
the retention carve-out already admits".

## Corrections applied by later rulings

Corrections 1 to 4 below were proposed here and adopted as R26 to R28
(brief.md). Each claim is tagged R with its ruling id.

1. R27 (old 7584–7585). "with staging fed from the recording and no devices
   or mappings present" became "with staging fed from the recording, so no
   device or mapping feeds the inputs ([D-218][d-218])". D-218 Position
   bullet 1 (log 8132–8134) runs devices as readers under replay.
2. R28 (old 7592). "one small allocation per drained batch" became "one small
   allocation per drained batch, plus the values boxed into it"
   (`src/trace.jl` 94–120 at `f61b1af`). R32 then changed "into it" to
   "into that allocation", since "it" read as the batch.
3. R26 (old 7629–7632). The checkpoint's list ends "and the fingerprint and
   the deployment ([D-319][d-319])". Source: D-319 bullet 1 (log 13838–13840).
4. R28 (old 7692–7694). "capped at that frame" became "capped at the
   recording's last frame", D-218 bullet 2's words (log 8135–8136).

Verifier fixes (`verify.md`), applied at the coordinator's direction:

- C-054: "is this value" became "is this frame index". "value" had picked up
  the previous sentence's "the value `trace(sim)` hands back".
- C-040: "The header also carries the run's `Deployment` and the structural
  layout" lost "also". It now reads as describing the two parts R17's
  sentence names, the deployment and the structural layout (the
  fingerprint), and not as two more items.
- C-064: "run metadata (the header's `Deployment` and `t₀`) names" became
  "run metadata names, its `Deployment` and `t₀`". The old gloss was
  circular.
- `mixture = 0.5` became "an illustrative unfed root input such as
  `mixture = 0.5`". It is a reader-cold aerospace example.
- "fingerprint" is still used once before R17's gloss, as directed.
- Re-check: R26 made the checkpoint list the deployment's first use. Its
  glossary link moved there, and its gloss became its own sentence after the
  list ("The deployment is the scalar-free artifact the grid parameters
  fix."). R17's sentence no longer carries either. The header now names the
  deployment three times in a row: the list, R17's sentence, and "The header
  carries the run's `Deployment` and the structural layout". The third only
  repeats the first two, but it opens the paragraph of the deployment's
  parameters, so it stays.

## Corrections proposed

5. The glossary's *trace record* (14195) points at §11.5, which never uses the
   phrase. `check_glossary.jl`'s WHITELIST lists `g-trace-record` as
   legitimately unlinked, so no link is proposed. The entry's §11.5 pointer
   is track 2's.
6. Log, track 2: D-217 bullet 1 (log 8073–8074) and D-255 bullet 3 (log 9903)
   give the length as "the drains since the capture", wrong under `restore!`
   (F59; `src/trace.jl` 43–49 says "the frame ordinal of the last drain").
   §11.5 cites D-217 for the frame-index wording, as the old 7688 did.

## Citations added or replaced

- [§2.4][s2-4], at the bit-identity sentence (brief, unit F: "The bit-identity
  law points at §2.4"). §2.4 frozen 567–569: replay "reproduces a run bit for
  bit from its initial state and its recorded inputs".
- D-218, at the replay sentence (R27). Position bullet 1: "`step!` and
  `run!` consume it frame by frame from there, live staging taken and
  discarded (`ReplayDiscardedStaging`), devices running as readers."
- D-176, repeated at the bold sentence (it sat three sentences later, at the
  rejection, which keeps it). Position: "every writer's drained batch is
  sparse-converted at the drain ... so the trace has one consumer-facing
  record format".
- D-319, at the checkpoint's contents. Position bullet 1: "`ModelState{T}`
  holds ... `x`, `s`, `m`, `table`, `prior`, `t`, `t₀`, `deployment` and
  `layout`. `Checkpoint` holds `state::ModelState{Float64}`, `frame::Int` and
  `boundary::Int`". See correction 3.
- D-047, at "replay is broken without the root inputs". Position: "trace
  header extends to initial slot values". Not imported: "slot".
- D-254, at the deployment's parameter list. Position bullet 1: "`Deployment`
  is the build plus `h`, `N_base`, `Δt_base`, the algorithm and the three
  event parameters. It is scalar-free."
- D-316, at "`t_end` and `ignore_stop_requests` are keywords of each advance".
  Position: "`run!`, `replay!` and `step!` take `ignore_stop_requests = ()`".
- D-217, moved with M51 to the merged length sentence. Bullet 1: "The trace
  carries its length beside the header and the batches". See correction 6.
- D-255, at "`attach!` and `detach!` push the current writer set onto it in
  place". Position bullet 3: "`attach!` and `detach!` push onto the list in
  place."
- D-274, at "A checkpoint is the one full-state capture". Position: "taken by
  `checkpoint(sim)` and by `init!`".
- D-038, at "Everything else, the state trajectory included, is derived".
  Position: "trace header = full `(x, m, z)` at `init!` (primary data); state
  trajectory = derived". Not imported: `z`.
- D-029, repeated at the bold "Trace recording is on by default" (it sat at the
  paragraph after, which keeps it). Position: "Input trace on by default ...
  plain kill switch."
- D-261, at "`init!` builds a fresh trace with the run under its `trace`
  keyword". Position: "`trace`, `log`, `log_every` and `log_max` are keywords
  of `init!` and `replay!`, the doors that build a run".

## Rationale-only rulings

- D-176, Rejected (log 6459–6461): "Keying retention by claim source", the
  verdict R6 keeps with its citation.
- D-029, Rejected (log 1002): "Rolling window/sampling", cited at "There is no
  sampling and no rolling window" (old citation, unchanged).

## Bold on the same entry elsewhere

None for the four rulings bold here: D-176's Position, D-255 bullet 3,
D-217 bullet 2 and D-029's Position. D-274 bullet 4 (the header bold) is bold
nowhere else. Same entries, other rulings, bold elsewhere: D-254 bullet 1 in
§12.7 (frozen 9493, "The checkpoint check compares two deployments as
values"), which §11.5 cites plain for the parameter list; D-319's Position
in §12.6 (frozen 9220), cited plain here for bullet 1; D-255's `Run` and
`ControlRequestedStop` bullets in §12.6; D-047 in units B (snapshot includes
root inputs) and C (services own initial values), cited plain here for the
header's initial values; D-038 in unit B (retention); D-261 in unit C. §12.7's
old-style lead-in "**Restore from the header.**" (frozen 9305) carries no
citation; it is chapter 12's.

## Inbound citations affected

- Appendix C 13194 (`CheckpointMismatch`) and 13221 (`ReplaySchemaMismatch`)
  cite §11.5, which names neither (R12: retargeted at landing).
- Log 14546 (D-364 Rationale), "decoded for replay and what-if replay
  ([§11.5])". §11.5 now names the edited-inputs what-if (R10 F57), not the
  glossary's parametric one.
- Spec 9497 (§12.7), "on the *structural* side of that line ([§11.5])":
  already wrong before the rewrite. R17's sentence says the fingerprint and the
  deployment are compared but draws no structural/parametric line.
- Frame walkthrough 55 ("the ordinal the trace will file this frame's batches
  under (§11.5)") stays true. No move leaves the section.

## Glosses and coordinator answers

Every glossary link at a term's first use in §11.5 now has a 5–10 word gloss
taken from its glossary entry, and each gloss is declared in `inventory.json`'s
"added" list. Where a sentence already had a parenthetical, the gloss is its
own sentence (device, batch, frame, replay, staging cell, face, claim, greedy
claim, checkpoint, prior, executor, log, trace header). *trace* is defined by
its own sentence. *snapshot* takes an appositive.

Coordinator answers applied:

1. "no devices or mappings present" was first held for the batch. R27 has
   since replaced it (see "Corrections applied by later rulings").
2. *batch*, *binding*, *log*, *roster*, *harness writer*, *executor*, *signal
   table* and `Build` are now linked at their first use in §11.5, with
   glosses. None is on the WHITELIST. `g-trace-record` is on it.
3. "schema entry" stays. Both "per-entry" became "per-record", since each
   trace record is the entry meant: "no per-record format flag" and "a
   per-record storage optimization". D-176 Rejected (log 6462–6463) speaks of
   per-batch record formats.
4. Pointers to [§2.4][s2-4] were added at old 7677 ("The trajectory depends on
   the deployment exactly as it depends on the stores") and old 7700–7702
   ("which is what bit-identical replay means"). Both restate §2.4's law (§2.4
   frozen 546–554 and 567–569). The pointers add no claim.
5. The deployment's gloss moved to its first use, R17's sentence. The later
   sentence reads "The deployment comes from [§9.2][s9-2]."

## Open questions

None. The replay-devices question was settled by R27.
