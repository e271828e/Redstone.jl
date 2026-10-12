# Final verify: chapters 1 to 4 (step 6b)

Base: commit f8afe64 (the seven units as verified alone). Log:
`chapter_fixes.md`, entries E1 to E71. Scratch: `final_verifier/`
(`replay.py`, the replayed files under `replayed/`, a fresh assembly).

## Counts

- Edits checked: 71 log entries. 64 touch a `new.md` (34 text edits, 30
  rewraps or blank-line trims); 7 touch a `rulings.md` (E50 to E54 in E, E66
  and E67 in G).
- Hunks: 21 in `git diff f8afe64 -- units/*/new.md` (A 1, B 5, C 2, D 2, E 6,
  F 3, G 2), plus 7 in the two `rulings.md` files. Every hunk is explained by
  the log.
- Problems: 3, all small. One is a citation placement under R23. The other
  two are a gloss lost under R19 and a citation whose reach grew under F26.
  No edit changes a claim's strength, scope or causal direction.

## 1. Replay

Each entry's Old block was applied in log order to
`git show f8afe64:docs/spec_rewrite/ch01-04/units/<U>/{new,rulings}.md`. Each
Old block occurs exactly once in the text at its turn. E24's `<end of file>`
marker is anchored at the file's end. The result matches the current
`units/{A..G}/new.md`, `units/E/rulings.md` and `units/G/rulings.md` byte for
byte. Units B, C, D and F `rulings.md` are untouched since f8afe64, and the
log claims no edit to them.

Hunks against entries: A E1. B: E2 to E6; E7 to E9; E10 and E11; E12 to
E14; E15, E16, E70 and E71. C: E17 to E23; E24. D: E25 to E29; E30 to E38.
E: E39 to E43; E49; E44; E47; E48; E45 and E46. F: E55 to E57, E68 and E69;
E58 and E59; E60 and E61. G: E62 and E63; E64 and E65. No hunk is unlogged.

The 30 entries logged as rewraps or trims change whitespace only. Every
non-code line renders at 80 columns or less, with link, bold and code markup
removed. No rewrapped line starts with a list marker. `chapter_new.md`
matches a fresh assembly of the seven units.

## 2. Each edit against its source

Every applied EDITORIAL finding (1 to 8, 10 to 20, 23 to 28, 32 to 34) and
every ruling (R18, R19, R20, R22, R23) has its entry. R21 needed no edit.
Glosses checked against the frozen glossary: tick (13278, verbatim), prior
(13243), guarded addition (13892), tier (13288), assembly (12835), cell
(12985), activation (13302, plus spec 1268 for `Dual`), port (13030),
abstract entry (12829) and stop request (13852 and D-316's Position). Each
claims nothing beyond its entry or source. Other sources checked: §10.6 base
6091–6099 for E10's "round of the boundary's event iteration"; §5.3 base 954
for E2; D-141's Position (log 4729–4732) for E21; D-019's Position for E4's
moved citation; D-056 bullet 4 (log 1693) for E36; D-180's Position for E8;
D-316's Position (13399–13401) for E68; D-101's Position (3063–3067) for
E70; FlightPhysics `geodesy.jl` 162–164 and 226–228 for E66.

Antecedents: every inserted or moved clause was re-read in place (E4, E7, E8,
E13, E26, E28, E32, E41, E58, E62, E64). Each pronoun and "That" still points
where it did. E64's gloss sits after "That is structural substitutability",
so the later "That preserves…" keeps its referent.

Glossary links: no anchor is linked twice in any section (checked by script
on the assembled chapter, with §4.3 spanning E and F). Bold: `boldcheck.py
ch01-04 E` passes. The text is unchanged apart from the bold markers, and
the 4 bolds left all carry a D-citation. Splits leave no citation covering
half a sentence. E4, E7, E13, E62 and E64 each split off a gloss sentence,
which needs no citation.

### Problems

**P1. E70 and E71 (R23, unit B): D-101 backs the seed sentence, not the
replay guarantee.**
Old: `ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231]).`
New: `… a bit-identical trajectory ([D-231][d-231], [D-101][d-101]).`
The chapters cite by adjacency, so D-101 now backs "RNG state lives in `s`,
never in ambient globals, so the same seed gives a bit-identical trajectory".
D-101's Position says nothing about RNG state or seeds. The sentence before
it, "One consequence is elevated to a framework guarantee, deterministic
replay (re-running the ordinary loop on a recorded input trace)", is D-101's
Position almost word for word ("the ordinary loop with two substitutions …
exact"), and it stays uncited. C9 asked that "D-101 carries the guarantee and
D-231 its RNG half". R23's "beside D-231" and "at the deterministic-replay
sentence" pull different ways, because D-231 sits on the RNG sentence. The
fixer followed the first.
Fix, if the orchestrator agrees: put the citation inside the replay gloss, in
the pattern §3.4 and §4.2 already use ("(a published consistency point,
[§10.6][s10-6])"). Write "deterministic [replay](#g-replay) (re-running the
ordinary loop on a recorded input trace, [D-101][d-101])", and return the RNG
sentence to "([D-231][d-231])". Move D-101 in B-054's inventory to the
guarantee's claim, and rewrap.

**P2. E41 (R19, unit E): §4.1's first *tier* lost its gloss.**
Old (f8afe64): `on either [tier](#g-tier) (the continuous or discrete side of the hybrid formalism).`
New: `(`y_state`/`y_direct`, the two output stages every [component](#g-component) provides, on either [tier](#g-tier))`
Since this edit, *tier* is linked in §4.1 with no gloss. The brief's link
rule and `spec_style.md` want a gloss at first use per section. The fixer
dropped it to avoid a nested parenthetical, since old 444–445 had none. A
gloss without parentheses fits, and it is the wording §4.3's "Scatter and
gather" already uses.
Fix: "…every [component](#g-component) provides, on either [tier](#g-tier),
continuous or discrete)". This adds three words to R19's "worded as at old
444–445", so the orchestrator rules it. The alternative is to accept the old
text's bare link, on chapter pass finding 8's reasoning that §3.4 glosses
*tier* nearby.

**P3. E58 (F26, unit F): D-036 now reaches "its shape is obvious".**
Old: `addition](#g-guarded-addition) (a capability the design admits but does not build) ([D-036][d-036]). Its shape is obvious, and it is not built.`
New: `A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build), and its shape is obvious ([D-036][d-036]).`
D-036 says only "field-projection connector kept as guarded addition" (log
1183–1184). "Its shape is obvious" was the old text's own claim, uncited. The
merge puts it under D-036's citation, so the sentence now claims more for
D-036 than the entry rules. Severity is low, and the chapter pass proposed
this exact text.
Fix: "A field-projection connector is a [guarded
addition](#g-guarded-addition) ([D-036][d-036]), a capability the design
admits but does not build. Its shape is obvious." This keeps one
parenthetical per sentence, keeps the gloss and the citation apart, and
leaves "not built" carried by the gloss.

## 3. Findings 9 and 29, declined

**Finding 29 (§4.4's component gloss): declining was right.** §4.1, §4.2 and
§4.3 link *component* with no gloss, so §4.4's "(the unit of modeling, leaf
or assembly)" is chapter 4's only gloss of the term. The fixer's own premise,
an earlier gloss in the same section or the one before, fails because §4.3
has none. `spec_style.md` asks for a gloss at first use in every section. If
anything, the bare links in §4.1 to §4.3 are the gap, not §4.4's gloss.

**Finding 9 (§2.2's projection appositive): declining was right in outcome,
but the stated rule does not fit it.** Finding 9 did not cut the gloss. It
swapped the verbatim repeat of §2's bold for a shorter gloss, "(the post-step
manifold hook)". The per-section rule is met either way, and the current
gloss is accurate. Keeping it costs a few repeated words, so declining is
harmless. The governing rule is `spec_style.md`'s: every section's first use
takes a gloss. The fixer's "same section or the one just before" rule is
looser than that, since it would let a section go without its gloss. E56
(finding 24) relied on it to drop §4.3's leaf-address gloss. That edit
stands, because the example `"pose.q_eb"` and "a nested field" say what a
leaf address is. A future fixer should not reuse the rule for a section with
no such example.

## 4. Unit checkers

From `docs/spec_rewrite/`, `python3 checks/check_unit.py ch01-04 check <U>`:

- A: checks failed: 0
- B: checks failed: 0
- C: checks failed: 0
- D: checks failed: 0
- E: checks failed: 0
- F: checks failed: 0
- G: checks failed: 0

`python3 checks/boldcheck.py ch01-04 E`: bold words: 36 | checks failed: 0.

## Anything else

- **Stale records after R18.** These do not affect the spec text. In
  `units/E/rulings.md`, line 16 (the R6 bullet) still lists "row 99" among the
  bolds, and line 99 says "not at row 99's bold". In `units/F/rulings.md`,
  lines 97–99 say "Unit E is to bold row 99". Fix: amend each to say that
  row 99 is plain since R18.
- `units/E/rulings.md` line 84 runs to 95 columns after E52. This is
  cosmetic. The file's other long lines predate f8afe64.
- Inventory updates are not replayed text. They were spot-checked for the
  four ruled claims: B-054 (R23), E C-006 (R19), E C-019 (R18) and F C-012
  (R22) carry their tags. All seven checkers pass.
- The logged variances from the chapter pass's proposed wording are each
  sound: finding 10 kept the old text's "Dryden/von Kármán turbulence",
  finding 24 kept "through the port's", and finding 32 used a sentence, not a
  parenthetical, with its reason logged.

## Re-check (after R24, entries E72 to E83)

Verdict: R24 is applied as ruled and as proposed. P1 to P3 are closed, and
the re-check finds no new problem. One check artifact remains, below.

- **Replay.** All 83 entries replay in order on f8afe64. Each Old block
  occurs exactly once at its turn. The result matches every current
  `new.md`, plus `units/E/rulings.md`, `units/F/rulings.md` and
  `units/G/rulings.md`, byte for byte. The `new.md` diff still has 21 hunks,
  and the log explains all of them.
- **E72 to E74 (P1, unit B).** D-101 now sits inside the replay gloss, "(re-running
  the ordinary loop on a recorded input trace, [D-101][d-101])". This is the
  pattern §3.4 and §4.2 use, and it is R24's text. The RNG sentence cites
  D-231 alone. Each citation now covers only what its entry rules. The next
  sentence opens on "RNG state", not a pronoun, so no antecedent moved. E74
  changes whitespace only.
- **E75 and E76 (P2, unit E).** §4.1's *tier* reads "on either
  [tier](#g-tier), continuous or discrete" inside R19's parenthetical. This
  is §4.3's wording and the glossary's sense (13288). There is still one
  parenthetical, with nothing nested. E76 changes whitespace only.
- **E77 and E78 (P3, unit F).** The text now reads "A field-projection
  connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036]), a
  capability the design admits but does not build. Its shape is obvious."
  D-036 covers only the guarded-addition claim, which its Rejected item
  states (log 1183–1184). "Its shape is obvious" is uncited, as in the old
  text. "Its" points at the connector. E78 changes whitespace only.
- **E79 to E83 (records).** Row 99 now reads as plain since R18 everywhere
  in `units/E/rulings.md` and `units/F/rulings.md`. E80 and E83 change
  whitespace only. The remaining lines over 80 columns in both files predate
  f8afe64.
- **Checks.** All seven `check_unit.py ch01-04 check <U>` runs print `checks
  failed: 0`. `chapter_new.md` matches a fresh assembly of the seven units.
  No glossary link appears twice in a section. Every changed line renders at
  80 columns or less.
- **Check artifact.** `boldcheck.py ch01-04 E` now prints `checks failed: 1`
  ("TEXT CHANGED beyond bold markers"). `new_pretrim.md` predates E75. The
  only difference between it and `new.md`, apart from bold markers, is E75's
  ", continuous or discrete". All four bolds still pass their D-citation
  test. Fix: apply E75 and E76 to `units/E/new_pretrim.md`, so the bold-only
  check passes again before landing.
