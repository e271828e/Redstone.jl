# Unit B verify (§2, §2.1, §2.2)

## Counts

63 inventory claims: 63 MATCH (3 headings and the rule are framing), 0 DRIFT, 0 LOST. Phase 1 found 86 assertions. All map to a claim or to `added`. 11 ADDED: one needs a fix and two are placement nits. The R16 sentence is not counted.

## ADDED needing a fix

- R4 (ii), §2 continuous bullet. "the composite map from `x` to $\dot{x}$ is mathematically identical ([§5.3])". "Identical" has nothing to compare against. §5.3 956–958 compares it with the textbook form. Fix: "…is mathematically identical to the textbook form's ([§5.3])", or use the brief's word, "unchanged".
- "The two policies follow." sits between the D-179 sentence and the §10.4 pointer. Fix: move it after the §10.4 sentence, where the bullets start.
- The tick gloss is given twice, in the §2 bullet and again as a sentence in §2.1. Fix: drop the §2.1 sentence and keep the link.

## Rulings checked

R5 F1, F2 and F4 and the D-180 sentence each match the brief word for word. Their sources hold:
- F1: `landinggear.jl`, `!strut.y.wow && f_init!(contact.frc)` inside `f_step!`; D-141 4737–4738.
- F2: §5.3 1019–1021.
- F4: §10.6 6093–6099.

R4 (ii) quotes §5.3's words. R9 (i) matches D-001 Rejected, log 370. The "so" link from the hook exclusion to `f_step!` survives as "So there is…".

## Order (M3)

M3's order is applied exactly. Every moved claim keeps its citation (§10.6, §10.4, §10.5, §8.2, §10.7, D-179). Two define-before-use slips:
- The prior's gloss says "previous boundary" before *boundary* is glossed in the bullet below. Fix: link and gloss *boundary* in the prior's gloss.
- `#g-boundary-detected` and `#g-localized` are used one paragraph before their bullets. The text says "The two policies follow", so this is acceptable.

## Citations

The added citations below each carry their claim:
- D-019 ("ZOH by construction")
- D-022 ("staged inputs drained")
- D-018 (root-finding)
- D-080
- D-179 at B-013 ("`Event(guard, handler)` loses the `localize` keyword")
- D-082 at B-035 and B-038
- D-082 Rationale at B-041
- D-180
- D-220 (Position bullet 4, Rationale 8248–8253)
- D-141 ("the touchdown edge")
- D-001 for the exclusions
- D-002, which R16 confirms

Two citations are weak:
- D-179 at B-034 ("Detection resolution is an execution-policy detail"). D-179 carries only that de-localization is "semantics-preserving by construction". Acceptable, or move it to "The crossing defines the transition".
- D-231 at B-054. It carries "RNG state lives in `s`" ("the values that determine its next draw are the state"). It does not carry "never in ambient globals" or "same seed gives a bit-identical trajectory". Note the narrower scope or accept it.

Every old citation survives.

## Bold (7)

- "Both policies share one declaration" (D-001, D-179) is not the headline of D-001's "two-tier events" ruling. That ruling says events have two detection tiers. "One declaration" is D-179's content (the `localize` keyword is gone), and §10.4 5415 already bolds D-179. Fix: bold a context sentence opening §2.1, "**Events have two detection policies** ([D-001])". Then state "Both share one declaration…" plain with [D-179].
- "An event fires when its predicate transitions…" (D-082) duplicates the base spec's §10.4 5492 bold, "A localized event triggers when its predicate was not-holding at tₙ's quiescence and is holding at tₙ₊₁" ([D-082]). Both bold D-082's edge clause, and 5492 itself says "This is the directional edge of §2.1". Fix at landing: make 5492 plain. §10.6 6192 bolds the boundary-zero Rationale, a separate ruling, so it is not a duplicate. 5622 and 5649 are not duplicates either.
- "The formalism deliberately excludes three constructs" (D-001) is an acceptable home: one bold for one ruling, versus three bolds on the bullet heads. Optional: name the three in the bold so that skimming the bolds tells the reader what is excluded.
- The rest are fine: B-002, B-007, B-035, and B-024 (Rationale-only, listed). No other unit bolds these entries.

## Moves

Only R3, R4 (i) and (ii), R5 and R9 (i) were applied.

## Reader-cold names

- Category 3, fine: FlightCore (`f_step!`, "FlightCore's per-step hook"); Flight.jl, which unit A introduces.
- Introduced: DCM, DAE, SDE, `!wow`.
- Not introduced, but each has a pointer, so acceptable: "published table" (§5.3) and "iteration round" (§10.6).
- *tier* is linked without a gloss.
- No category 1 or 2 names remain, apart from R16's.

## Other

R16 deletes the whole RNG and Dryden sentence. The fix round must keep the spelling of RNG ("random number generator") at its first use. The brief requires it.

## Re-check (after R16, R17 and the fixes)

Verdict: pass, with one wording nit. The checker prints `checks failed: 0`. Nothing changed outside the items listed below; I compared every other line with the first pass.

- **R17.** "**Events have two detection policies** ([D-001])" is the headline of D-001's "two-tier events", the second of the four rulings that semicolons separate in its Position. It passes the one-bold test. D-001's four rulings now each have one bold: §2 lead, the §2.1 lead, projection and §2.2's lead. The shared declaration is plain with [D-179], whose Position carries it (`Event(guard, handler)` loses `localize`). §10.4 5492 goes plain at landing, as R17 records.
- **R16.** "Noise processes, such as sensor noise and turbulence from Dryden/von Kármán turbulence models, are modeled as shaping filters ([D-001]), that is, as ordinary discrete processes driven by a random number generator (RNG)." This matches R16, and there is no introducing sentence. D-001 now sits on "shaping filters", which its Rejected list carries ("shaping filters suffice"). RNG is spelled out at its first use, before "RNG state". The "that is" equivalence is inverted but keeps its meaning. The commas make "such as" non-restrictive. That reading fits the SDE exclusion, so I accept it. "That modeling" and "the noise processes" still resolve.
- **R4 (ii).** "identical to the textbook form's ([§5.3])" now has a comparand, but it dropped "mathematically", which is §5.3's word (956–958). The brief says to quote it. Fix: "is mathematically identical to the textbook form's".
- **"The two policies follow."** now comes after the §10.4 pointer and leads into the bullets. OK.
- **The §2.1 tick sentence** is dropped. *tick* is glossed in §2's bullet and linked again in the D-220 bold. OK.
- ***boundary*** is linked and glossed in the prior's sentence. "the prior, each event's predicate sample stored at the previous boundary (a published consistency point)" reads cleanly as an appositive. The boundary-detected bullet's later link and gloss are gone ("at step boundaries only"). This fixes the define-before-use slip, and *boundary* is linked once in §2.1.
- **D-179** has moved to "The crossing defines the transition". D-179 carries it: de-localization casts the guard to its predicate, "semantics-preserving by construction". "Detection resolution is an execution-policy detail" is plain, as in the old text, and is covered by adjacency.
- **`rulings.md` and `inventory.json`** record R16, R17 and each fix.
