# Unit B (§11.2) cold verification

**Counts.** 178 inventory claims: 177 MATCH, 1 DRIFT (mapped, harmless), 0 LOST. 24 ADDED, none changes meaning. Phase 1 found 79 assertions. `check_unit.py`: 0 failed. The chart is byte-identical to old 157–159. The R18 block matches `src/sim.jl` 591–592 and Appendix B 12684–12685. Leaving out `t0` is fine, and the text does not say only `init!` takes the four keywords.

## DRIFT

- **C-028 (mapped to J).** Old: "the liveness timestamps the loop takes at frame top". J's span says the heartbeat is acquire-loaded "at publication" (D-240). So the home does not say the same thing. J is right. D-240's Position supersedes D-136's "at the drain" and says "The drain does not touch it." Fix: none in new.md. Close the rulings.md item "heartbeat's timing" by citing D-240.

## R5 homes

- C-027 (pacer diagnostics, §10.7) and C-136 ("complete to the final frame top", D-201) exist in J/old.md 81–82 and 101–102 and say the same thing.
- C-152 ("keyed by the names `reads` declared") exists in G2/old.md 46–47 and says the same thing.
- §11.2 still keeps the binding-rule consequence, "It also carries the framework status" (the 6903 Rule that §13.2 cites), the endpoint reason, "compiled to one gather", the attach-time failure, and the `totals` composition with re-decimation.

## Rulings checked

- **F5, F6, F7.** All three are applied word for word. F7 stays uncited. F5's ruled text is wrong for `log_max = Inf`: `src/dataplane.jl` 750 gives no hint in that case. The rewriter's proposal, "A finite `log_max` is the log's `sizehint!`", is correct. Escalate it.
- **F14.** The ruling is moot, as the rewriter says. The only "batch" left is "the batches (§11.5)", which means the trace's staged writes. That is the reserved sense.
- **R11.** C172X, `XPlane12Control`, `VelocityData` and `SavingCallback` each get exactly the dictated clause and claim nothing more. D-083's Rationale names `VelocityData`, so "illustrative" is accurate.
- **R12.** D-130's Position covers it: "*inspection* (device read bindings …) … drift still loud at attach (`ReadBindingUnresolved`)".
- **M3.** Done. "The endpoints below are kept" now sits directly above the endpoints paragraph, so "below" still points the right way. The reorder of "They are two extra references" makes "They" refer to the two endpoints, which is clearer. "it" still means the first snapshot. No other moves were made besides M4, M5 and M6, which were ordered.

## Citations

Every added citation is carried by the field the rulings name: D-023, D-293, D-038, D-047, D-083 (Position and Rationale), D-129, D-045 b2, D-252, D-136 (Rationale 4407–4411, Rejected 4439), D-194 (Rationale 7135–7137) and D-137 (Position and Rationale). §10.7 and D-201 moved to J with their claims.

There is one scope problem. The D-023 citation at the publication bold, the D-047 citation at the root inputs and the D-038 citation at log retention each sit inside a term's gloss. So each reads as the source of the gloss, not of the ruling. Fix: move each citation out of its gloss parentheses.

## Bold

There are 15 bold headlines, each with its D-entry, plus "**full**" twice inside the chart. None marks mechanism, and no ruling is bold twice. D-137's seven bolds match its Position and its six bold Rationale clauses. D-129 is also bold at §8.6 (3461), but that bold is the structure/contract ruling, a different clause. The rulings.md list leaves this out.

## *binding*

It needs the link. The convention is one link per term per section, and the brief's G1 note only covers how §11.6 is split. Units C, F, G1 and H each link *binding* in their own sections. §11.2 uses the term about 12 times and never defines it. Fix: link the first "bindings" with C's gloss "(the value passed at `attach!` that makes a device framework-legible)". That also separates it from "binding rule" and "non-binding".

## Reader-cold names

- (2) "CG velocity": CG is never spelled out.
- (1) `v_eb_b` is Flight.jl notation. "defined at the type as body-origin velocity" mitigates it.
- (3) `SavingCallback`: fine.
- "the door" (line 183) is a spec idiom that the text never defines. §12.6 sits next to it.

## Other

- The `latest` gloss repeats the next sentence ("Readers acquire-load that reference").
- "port class" is verbatim and untouched, so it is acceptable.

## Re-check (after the rewriter's fixes)

`check_unit.py ch11 check B`: 0 failed. All six fixes hold. One antecedent is ambiguous.

- **Decimation (C-082).** "The log takes the same plain on/off switch the trace has. Decimation is its additional keep-every-kth retention policy". Here "its" can bind to "the trace", the nearer noun. That reading contradicts D-029. "Additional" is faithful to the old "additionally", and the identity with `log_every` matches the glossary. Fix: "Decimation is the log's additional keep-every-kth retention policy, `log_every`".
- **Root inputs.** "Root inputs are the root component's own input faces" matches the glossary word for word. The next sentence's "They" binds correctly.
- **Binding.** "A binding is the value passed at `attach!` that makes a device framework-legible" matches the glossary and units C and F. No antecedent breaks.
- **`latest`.** "(the single handout point for published snapshots)" restates the intro's "single atomic reference" and claims nothing new. D-023 now sits on the bold.
- **R29.** Applied (C-145).
- **CG.** Spelled out. The claim is unchanged.
- **Heartbeat.** Closed with D-240.
- **R30.** B keeps one pointer sentence on `totals` (§11.8), and re-decimation stays in B. Bookkeeping: inventory C-140 is still tagged `R5`; it should be `R30`.
