# Unit C verify

**Counts.** 56 inventory claims: 56 MATCH, 0 DRIFT, 0 LOST. C-017 ("therefore" gone, R6), C-037 ("So they are spelled differently" gone, M4) and C-044 ("Why." label) are ordered edits. 58 phase-1 assertions. 10 ADDED: the roadmap (R3), six glosses, one topic sentence, the D-141 sentence (R7) and the FSM expansion. `check_unit.py`: 0 failures.

**Meaning-changing ADDED (minor)**
- V29 (R7). New: "a commanded reset of state still arrives as an input and lands through an event whose guard reads that input". D-141 (log 4729–4732) says the *condition* arrives as an ordinary `Bool` input. §5.3 (old 1091–1092) says the same: "whose condition arrives as an ordinary `Bool` input". The new sentence makes the reset itself the input. Fix: "a commanded reset of state, whose condition arrives as an input, still lands through an event whose guard reads that input". Otherwise the sentence matches word by word: "On the continuous tier"/"continuous", "still"/"Even", "lands through"/"is spelled as", "whose guard reads that input" verbatim.
- V24, the port gloss. "the addressable unit through which components exchange values" goes beyond the glossary's "the addressable unit of the model". It is true, but unquoted. Optional fix: "the addressable unit of wiring", or leave it.

**Rule of meaning.** The three old sentences survive verbatim with their claims. The italics stay. The bold on *input* and *event* goes, which is correct. The added topic sentence ("separates a command from a detection") restates them and claims nothing new. A cold reader now meets "do not overlap" and then, at once, a case where both mechanisms take part. This is rulings.md's open question. It stays with the owner.

**"three classes" → "The taxonomy has three categories of component".** The count (3) and members (two leaves plus one composition, named in the roadmap) are the same. The glossary's *component* covers leaves and assemblies, so the scope is right. No *class* remains in the unit, and no other reserved word either.

**Citations.** Every old citation survives. [§7] is replaced by R5. [D-195] moved to the rule (M4).
- D-090 Position carries "update `m`, reset `x`" (`(; m = …)`, `(; x = …)`). "Own" comes from D-141's Rationale, not D-090. This is acceptable.
- D-154 Position's epoch rule carries "fresh table" (the firing round's sweep). D-181's amendment leaves this clause standing.
- D-056 Position ("cross-tier coupling always routes through table cells") carries "only through signals".
- D-019 Position carries ZOH ("ZOH by construction"), flattening ("virtual for execution") and rate scopes ("for declaration"). Its annotation touches none of these.
- D-003 Rejected ("loses reset maps") carries "enable reset maps" but not "preserve cohesion". It is correctly listed as rationale-only.
- D-094 and D-231 carry the leaf and field rules. Neither says NamedTuple: D-247 does, and §7.1 cites it. R5 fixed the citation text, so this is a note only. The owner may add [D-247].
- D-141 carries V29, with the caveat above.

**Bold.** There are four bolds. Each is a headline with its D-citation: D-003 (taxonomy), D-003 (both factorings), D-195, and D-231's annotation with D-249. There is no bold on a mechanism, a lead-in or a definition. Bold 4 does not double §8.2's (old 2932). §8.2 bolds the agreement rule (D-112, D-249). §3.2 bolds the absence of a mode store, ruled by D-231's annotation. They share D-249 bullet 1 only as a cited source, and §8.2 states "`m_init` … continuous-only" in plain text. No ruling is bold twice.

**Moves.** R3's roadmap and M4 are done. No other move.

**Verbatim.** "external FSM component" is kept. "Externalized FSM" never appeared in §3.1, so there is nothing to keep. The formulas are unchanged.

**Reader-cold names.**
- (2) "stall hysteresis inside the aero component" has no introducing clause. Rulings.md notes that no source describes it.
- (1) none.
- `SArray` and `Symbol` are ordinary Julia names.
- "integrate-and-dump challenge" points at §3.4.

**Other.**
- FSM is spelled out at first use in §3.1 ("finite-state machine (FSM)"). In §3.2 the order is reversed ("FSM (finite-state machine)"). This is cosmetic.
- The extra glossary links (*component* in §3's lead, *tier* in §3.1) each sit at the first use in their section. They are fine.

## Re-check

Compared against the text verified above. Only lines 14, 37–38, 43–45, 52 and 70 changed, and only as follows. No sentence was split, merged or moved, and every antecedent is unchanged. `check_unit.py`: `checks failed: 0`, with 4 bolds.

1. R7 now reads "a commanded reset of state, whose condition arrives as an input, still lands through an event whose guard reads that input". This matches D-141's Position (log 4729–4732, "the condition arriving as an ordinary `Bool` input … spelled as an event whose guard reads that input") and §5.3 (old 1091–1092). "that input" points back to "an input" in the same sentence. MATCH.
2. The port gloss now reads "(the addressable unit of the model)", verbatim from the glossary (spec 13030). Lowercase "model" here means the modeled system, which spec_style.md allows. The line break after "gives maximal" is cosmetic. MATCH.
3. [D-247] now sits beside [D-094] and beside [D-231]. Its Position (log 9373–9374) says every by-value store declaration "returns a `NamedTuple` with one named field per leaf". That carries the NamedTuple claim for both `x` and `s`. No log vocabulary (`init_*`) was imported. MATCH.
4. §3.2's first use is now "finite-state machine (FSM)", which matches §3.1. MATCH.

Verdict: all four fixes are correct. Nothing else changed. Unit C passes.
