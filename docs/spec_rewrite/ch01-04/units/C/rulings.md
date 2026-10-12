# Unit C rulings: §3 lead, §3.1, §3.2, §3.3

Old lines are `spec.md` lines at `d3af35a`. Log lines are `decisions.md` at
`d3af35a` (`scratch_survey/`). Word count 519 old, 636 new.

Rulings applied: R3 (§3's roadmap sentence), R5 (F7, both bullets; no other
instance of "isbits struct" or "any isbits value" in the unit), R6 (four bolds:
D-003 at rows 48 and 56 with "therefore" removed, D-195 at row 63, row 66 with
D-231 and D-249), R7 (the rule of meaning). M4 applied: the D-195 ruling opens
§3.2's letter paragraph, and "So they are spelled differently" goes, its
citation moving to the rule. "Nothing is lost by the split" became "Nothing is
lost by splitting the letter", so it cannot be read as the two-leaf split.
"submodels" became "child components". "There are three classes" became "The
taxonomy has three categories of component", in neither glossary sense of
*class*. FSM is spelled "finite-state machine (FSM)" at first use in §3.1 and §3.2.
The *port* gloss quotes the glossary entry's words, "the addressable unit of
the model".

## Corrections proposed

None beyond R5's F7. See "Open questions" for one scope question.

## Citations added or replaced

- [D-003] at §3 lead, bold (old 298). Position log 389–390, "Taxonomy: hybrid
  continuous primitive + periodic discrete + assemblies".
- [D-003] at §3.1, bold (old 317). Position log 390, "both mode factorings".
- [D-003] at §3.1's internal-modes bullet (old 320). Rejected log 395–396,
  "*Strict purity/no modes:* loses reset maps". Rationale-only, below.
- [§7.1], [D-094] replace [§7] at old 305 (R5, F7). D-094 Position log
  2852–2853, "`init_x` leaves are plain real scalars and `SArray`s at the
  common eltype". §7.1 old 1687–1691.
- [D-247] beside D-094 at old 305 and beside D-231 at old 332. Position log
  9373–9374, "Every by-value store declaration, `init_x`, `init_s` and
  `init_m`, returns a `NamedTuple` with one named field per leaf". §7.1 old
  1688 cites it for "The declaration is a NamedTuple".
- [§7.3], [D-231] replace [§7] at old 332 (R5, F7). D-231 Position log
  8689–8690, "Every field of a store value — a discrete leaf's `s`, and any
  leaf's `m` — is isbits or a `Symbol`". §7.3 old 1880.
- [D-090] at old 310–311 (a handler may update `m` and reset `x`). Position log
  2750–2752, "`(; x, m)` … a pure FSM returns `(; m = …)`, a reset map
  `(; x = …)`".
- [D-154] beside [§5.3] at old 311–312 (guard and handler read the fresh
  table). Position log 5457–5459, "a handler executes against exactly the world
  its guard fired on — own `y`, foreign `u` and own `x`/`m` are all the firing
  round's sweep". Survey part E prefers it to D-016's half-superseded clause
  (log 625).
- [§5.3], [D-141] on R7's added sentence. D-141 Position log 4729–4732, "Even a
  commanded continuous reset — the condition arriving as an ordinary `Bool`
  input … — is spelled as an event whose guard reads that input; the discrete
  tier's input answer does not transfer". §5.3 old 1090–1093.
- [D-195] moves from old 341 ("So they are spelled differently") to the rule
  that now opens the paragraph. Position log 7135, "The discrete state
  un-fuses from `x` into its own letter `s`".
- [D-056] at old 342–343 ("only through signals"). Position log 1683–1684,
  "cross-tier coupling always routes through table cells". Plain: unit D bolds
  this sentence in §3.4.
- [D-019] at old 343–344 (held zero-order between ticks). Position log 715–716,
  "discrete stages gated to own tick instants (ZOH by construction)".
- [D-019] at old 360 (flattened away for ordering) and beside [§10.5] at old
  360–362 (rate scopes). Position log 716–717, "assemblies virtual for
  execution, rate scopes for declaration". Its annotation (log 725–727) amends
  phases and rate compilation, not these clauses. Plain: §10.5 bolds it.
- [D-231], [D-249] at old 346, bold. D-231 annotation log 8724–8725, "`m` is
  continuous-only, since a discrete component has no mode store"; D-249 bullet
  1 log 9494–9496, "`DeclarationOnWrongTier` keeps … `init_m`".
- [§3.1] to [§3.4] in R3's roadmap sentence.

## Rationale-only rulings

- `m` is continuous-only; a discrete component has no mode store (old 346,
  bold). D-231, annotation, log 8724–8725. D-249 bullet 1 implies it for
  `m_init` only. The log owes a Position stating it.
- Internal modes enable reset maps (old 320, plain). D-003, Rejected, log
  395–396. The log owes a Position stating it.

## Bold on the same entry elsewhere

- D-003: bold twice in this unit, once per semicolon ruling (taxonomy; both
  mode factorings). Bold nowhere else in the spec or the other units.
- D-195: bold only here.
- D-231: this unit bolds its annotation (no mode store). Other bolds cite other
  rulings of D-231: §7.3 old 1880 (Position sentence 1, the isbits rule), 1892
  (sentence 2, the frozen-reference latitude), 1975 (the PRNG sentences), old
  3975 (the check); unit E's "the signal requirement is immutability plus
  frozen references" cites D-231 beside D-243. No ruling of D-231 is bold
  twice.
- D-249: §8.2 old 2932 bolds "The remaining tier-implying declarations must
  agree" ([D-112], [D-249]), which rests on D-249 bullet 1. This unit cites
  D-249 bullet 1 beside D-231 in its bold, as R6 orders, for a different claim
  (no mode store). If the verifier reads the bold as D-249 bullet 1, that
  bullet is bold in two places. The bold's own ruling is D-231's annotation.

## Inbound citations affected

- Spec 10664 (§14.4) and log 11603 (D-276 annotation) say "a discrete `s`
  field is any isbits value ([§3.2])". After F7, §3.2 says "a NamedTuple whose
  fields are each isbits or a `Symbol`". Chapter 14's rewrite takes 10664
  (README); the log line is track 2.
- Spec 1091 (§5.3) cites §3.1 for "only handlers write `x`"; R9 (ii) retargets
  it to §3.4 at landing. `companions/flight_case_studies.md` 187 carries the
  same sentence with the same §3.1 citation, and R9 (ii) does not name it. It
  needs the same retarget.
- Spec 6123 (§10.6) and log 772 (D-020) quote "Externalized FSM components
  ([§3.1])". "external FSM component" is kept.
- Spec 2482, glossary 12864, log 10489 (D-263) and `extensions.md` 50 rely on
  "Any facet may be empty" and the FSM sentence. Both kept.
- Glossary 12938 and `extensions.md` 125 rely on "only through signals" and "no
  component ever reads another's state" (§3.2). Both kept.
- Glossary 12840 and `extensions.md` 47 rely on §3.3's flattening and retained
  hierarchy. Kept.
- Spec 10370 (§14.1) cites §3.2 for modes being continuous-only. Kept, and now
  bold.
- Spec 2934 (§8.2) and log 3462 (D-112) cite §3.2 for "the event system is
  continuous-side only". §3.2 still implies it and does not state it
  (unchanged).
- Log 4747 and 4793 (D-141) cite "[§3.1]'s immutable stage views", which §3.1
  did not and does not state (unchanged; track 2).
- Glossary 13103 cites §3.1 for "no incremental `x_deriv`-only
  re-evaluation", which §3.1 does not state (owner's open item; unchanged).
- D-172 Position (log 6220) says "face" is "defined at first use" in §3.3.
  §3.3 now glosses *face* at its first use, which makes that true.

## Open questions

- R7: whether "The two mechanisms carry two meanings and do not overlap" is a
  ruling the owner wants recorded. It stays plain and uncited. The added
  sentence from D-141 says a commanded continuous reset, whose condition
  arrives as an input, lands through an event, so both mechanisms take part
  in it.
- Old 306–307, mode variables "change *only* through event handlers" (no
  entry; survey row 51). §14.1 old 10368–10370 lets a condition specify modes
  (`m`), so a condition also sets `m`, outside the run. If "only" is meant
  during a run, the owner may want that scope stated. Left as written.
- "stall hysteresis inside the aero component" (old 319) is reader-cold. No
  source in the spec or the log describes it, so it has no introducing clause.
