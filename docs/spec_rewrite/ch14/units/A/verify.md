# Unit A verification

Read against the frozen spec and log (base c3d29fb), `src/conditions.jl` and Flight.jl.

## Counts

171 inventory claims: MATCH 170, DRIFT 1, LOST 0. ADDED: 9 inventory items plus the glosses. None changes meaning. Citation findings: 2 weak carriers. Bold findings: 1.

## DRIFT

- **C-072/C-073.** Old: "No shadowing check covers it: a method written to a foreign `condition` fails loudly …". The colon said why no check is needed (D-316: "`condition` stays outside the family because a foreign `condition` fails loudly"). New: two separate sentences, so that reason is gone. Fix: "No shadowing check covers it, because a method written to a foreign `condition` fails loudly at the owner's pull, as a `MethodError` naming the child ([D-316][d-316])."

## Hazards checked

- **R1.** M1 order holds: rule and pause, table, `errored`, kind with `CheckpointMidFrame`, then `Model` forms. The cut "Everything they share reduces to" also said the condition was all that the three services share. That was false anyway, since trim and linearization also share the activation (§9.6). Nothing true is lost.
- **R4.** The cut claims match the brief's list. The new paragraph agrees with §13.5 (10755–10766): "reads only what the model declared for it", and "conditions already address state by path (§14.1)".
- **R27.** Agrees with B's §14.4, which also says "compiles two ways" and places converted values in the dynamic walk. No contradiction. But both sections state the per-leaf triple "a lens (gloss), a destination and a converter", with `lens` glossed twice. That double falls under R6. One should point to the other.
- **F8, F9, F11, F13** match the code. The checks are `_payload` at 82–83, `isempty(prefix)` at 92–94, and the non-node operand methods. The specialized `apply!` has no allocation (738–739), while the dynamic walk is "allocation permitted" (529). The key is `_key` at 175–176. Names come from `act.decls` (353) and chains from `structure`. F15 matches `StoreWrite` (595–619).
- **R12/R23.** Spot-checked `assign!`: it is defined in FlightPhysics `aircraftbase.jl` 94 and called at `c172.jl` 876. Also checked `C172X.Systems` (FlightApps `c172x.jl` 1, 207), `RQuat` (FlightPhysics `attitude.jl` 66), `PistonEngine` (FlightPhysics `piston.jl` 18) and `f_init!` (FlightCore `modeling.jl` 201). All hold.
- **R2.** The `errored` sentence is plain.

## Citations

All added and replaced citations were read. Each named field carries its claim, with two weak cases:
- D-274 at "It may not become a checkpoint". Bullet 2 implies it only by listing the legal states. D-108's Rationale says it in words ("never as condition values", `capture(errored)` rejected). Consider citing D-108 here too.
- D-064 at "Delegation runs by dispatch at every genericity seam". The Position says "dispatched on component types" but does not mention seams.

## Bold

There are 18 bolds. Each is one ruling's headline with its D-entry, and no ruling is bolded twice. Neither the frozen spec nor the sibling drafts bold these entries. D-065's six bolds fall on six semicolon-separated rulings.
- **Inconsistency.** rulings.md says "D-063's first ruling is bold at the overlay base, not at the earlier sentences on what a condition may specify". But new.md also bolds "**It never specifies outputs**" (D-063). Under R7's semicolon test this is a separate ruling, so the bold is defensible. Either update rulings.md or drop that bold.

## Reader-cold names

- (1) None. Every Flight.jl name gets its owner clause at first use.
- (2) `α_filt = α_a`, `n_eng`, `ω_rated`, `β_a`, "pwp/engine", "aero": aerospace example symbols (angle of attack, sideslip, engine speed). Each could take one clause. They are unchanged from the old text.
- (3) `f_init!` as FlightCore's hook: fine.

## Other

- F8's dictated "`at` and `combine` build the tree's inner nodes" leaves out `override`, which also builds a node (`Override`, §14.6). F8 itself faulted the old count for this. Needs a ruling: add "(and `override`, [§14.6][s14-6])"?
- C-011: "no condition algebra" (R1's wording) is narrower than D-273's "no algebra", which §14.1 keeps. This is harmless.
- V149: "Its message names the layering combinator, "`combine` is …"". After the comma, the quote reads as the combinator's name. Fix: "Its message names the layering combinator. It reads "…"."

## Re-check

`checks/build_inventory.py ch14 A`: 171 claims, 11 added, 0 checks failed. The citation, code-span and link differences all trace to rulings: the D-059 swap (R2), and the second `#g-seam` link and the second `local_wires`, both cut with R4's paragraph.

- **C-072/C-073.** OK. The "because" restores D-316's link, and the D-316 citation stays.
- **C-025.** OK. D-108 now sits beside D-274, and the Rationale carries the claim.
- **C-103.** OK. Old 182 cited nothing at "Delegation runs by dispatch", so dropping D-064 loses no claim. The `#g-seam` link stays.
- **C-118.** OK. "It reads" now introduces the quote, and "Its message names the layering combinator" still holds, since the quote names `override`.
- **R35 (C-093).** OK. "with literal prefixes" scopes the construction half only, which agrees with C-090 and with F9.
- **R36 (C-086).** The content is OK: `Override` is the fourth node type. New issue: "a fourth *kind*" uses a glossary word in another sense. `#g-kind` means a diagnostic kind, and §14.2 links it eight paragraphs later ("carries a [kind](#g-kind)"). Fix: "and `override` builds a fourth node type ([§14.6][s14-6])". This needs a ruling, since R36 dictated "kind".
- **R37 (C-149).** OK for §14.3 alone. "The dynamic walk's plan holds the converted values themselves" matches `ConditionPlan` (`src/conditions.jl` 270–325). "The lens is …" still has its antecedent. The `lens` gloss is the only one in A.
- **D-063 bold.** It passes the one-bold test. "never outputs or workspace" is a semicolon clause of its own, it is bolded once, and its workspace half is plain under D-306. rulings.md now agrees.
- **Format.** Lines 193, 227 and 315 of new.md run past the wrap width. Reflow them.
- **R38.** Both edits are OK. "and `override` builds a fourth node type ([§14.6][s14-6])" is now correct. "the node types in hand" matches the code's payload, `in_hand = nameof(typeof(n))`. Appendix C's `ConditionNodeMisuse` row and D-113 still say "node kinds". Change the row at landing; the log keeps its wording. No *kind* outside the diagnostic sense remains in A.
- **Reflow.** OK. Lines 189–194, 224–230 and 310–316 keep every word. The only lines over 80 columns are the table, the code block, and lines 133 and 252, which count multibyte characters (`→`, `·`, `—`). The rerun gives 171 claims, 11 added, 0 checks failed.
