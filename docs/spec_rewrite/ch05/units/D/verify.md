# Unit D, cold verification

**Counts.** 71 phase-1 assertions. 55 inventory claims: 54 MATCH, 1 DRIFT (a gloss), 0 LOST. 12 declared additions, none unlisted. `check_unit.py ch05 check D` reports 0 failures.

**DRIFT**
- C-033, the replay gloss. Old: "[replay](#g-replay)", with no gloss. New: "replay (the session's recorded inputs, and the loop re-driven from them)". The glossary (13523) defines replay as "the ordinary loop with one substitution: the drain reads the trace". Replay is not the recorded inputs, and the trace is the record. Fix: "(the ordinary loop re-driven from a recorded trace)".

**ADDED.** None claims more than its source.
- Touchdown sentence: the brief orders it, and D-141 (log 4701–4702) carries it.
- C172X clause: R5 F3 as worded. The *Mode engage* item sits under "Frame anatomies" in section 3 (companion 332, 349–350).
- ZOH gloss: it matches §10.5 (5633–5636).
- "Gain scheduling and resets are both": an antecedent fix.

**Citations.** Every old citation survives with its claim. §11.7 is removed by R5. Of the citations rulings.md adds:
- D-020, D-154 (three times), D-089 (four times), D-141, D-067 and §10.5: the named field carries the claim.
- D-016 is weak. Its standing clause says only "`project` is the sole raw-state function (schedule-structural)". The write-then-decode position appears only in the superseded parenthetical "(handler → project → h_x → h_xu)". The next spec sentence also denies the clause's literal "sole". The survey's bold table, adopted by R9, chose this citation. The orchestrator should confirm it or find a better source. D-111 does not carry it either.

**Bold.** Four bold headlines, each followed by its entry: D-016, D-089 (twice, Position and Rationale), and D-141. No bold falls on a mechanism, a consequence or a lead-in. D-020, D-154 and D-191 are plain. The blockquote lost its bold. That departs from the brief's "as written", but `spec_style` and `check_bold` support it, and §10.6's blockquote at 6189 has no bold either. I agree with the change. No other unit bolds these entries.

**Moves.** The R4 merge keeps every fact of 926–931 and 939–944. The `x_projection` paragraph now follows the blockquote. There are no other moves.

**Rulings.**
- R4 is applied as worded. The epoch rule is one plain sentence with no label and no "Hence", cites D-154, points at §10.6, and keeps "a handler executes against exactly the world its guard fired on" word for word.
- R5 F3 and R9 (row 75) are applied as worded.
- No correction was made that the brief does not order.

**Hazards. All checks hold.**
- "Two rules from §10.6" still introduces exactly the two rules at §10.6 5939 and 6072.
- Spec 312, 2720, 5929 and 11681 each keep their sentence.
- The `PI` block matches spec 988–992 byte for byte.

**"Execution order" at old 934–935.** I agree with the rewriter's "boundary sequence". The glossary's *execution order* (12934) is the flat list of stage functions: stage 1, stage 2, then `x_deriv`. Integration and handler resets are not in it, and `x_projection` runs outside it. The spec already uses "boundary sequence" at 5100, 5227 and 6378, and the blockquote shows both positions. Change both sentences. The `#g-execution-order` link should then go to unit C's first use.

**Reader-cold names.**
- (2) `strut.wow`, `frc.reset`: Flight.jl gear names. The text never ties `frc` to the friction regulator, and `reset` is used one sentence before the reset face is introduced. Fix: "the regulator `frc`".
- C172X and Flight.jl are introduced. FlightCore is not used.

**Other, minor.**
- `trace` is linked with no gloss. The sentence already holds the replay gloss, and the style allows one parenthetical per sentence.
- The face gloss drops "boundary" from "on its component's boundary".
- Splitting the ZOH sentence leaves "that stale command" pointing back to "the output … from the stale state" across a sentence boundary. It still reads correctly.

## Re-check (R13, R16, R17 and the verifier fixes)

All five items hold. `check_unit.py ch05 check D` reports 0 failures. The inventory tags C-009 and C-011 R16, and the additions list matches the text. No antecedent or citation scope moved, and nothing else changed.

1. **Trace and replay gloss.** It holds, with one blemish. "The session's recorded inputs" fits *trace* (13534: drained, device-tagged batches per frame). "The ordinary loop re-driven from that recorded trace" fits *replay* (13523). But the gloss sits after "replay", so a reader may take all of it as replay's. Optional fix: "(a trace records the session's inputs, and replay re-drives the ordinary loop from it)". Lines 3 and 58 are left unwrapped.
2. **R16.** Both sentences now say "boundary sequence", and `#g-execution-order` is gone. R13's premise is wrong, though. Unit C's new.md line 77 uses "execution order" in prose ("one pass through the execution order"). By R16, that line should take the link and its gloss. That is unit C's edit.
3. **R13.** The guard, sweep and store links are gone, and so are the guard and store glosses. The plain gloss on "boundary sweep" stays. It names the variant, so it does not duplicate unit C's *sweep* gloss.
4. **Gear sentence.** It holds against D-141 (log 4692–4702). `reset = true` "adds a `Bool` input face", the policy is "rising edge", and the log has "the gear wires `strut.wow → frc.reset` (the touchdown edge)".
5. **Face gloss.** It now matches the glossary (12843).
