# Unit H: cold verification of §14.10

Read against the frozen spec and log (c3d29fb) and `src/linearize.jl`.

## Counts

135 inventory claims: 132 MATCH, 2 DRIFT, 0 LOST, 1 deleted by ruling (C-077). `deleted.md` lists it with its F74 reason, which holds at §7.2 1900–1904 and §9.6 5121–5126. ADDED: 7 items plus C-030's `t0` sentence. Each traces to R8, F53/R24 or F71/R14.

## DRIFT

- **C-128 (R10).** Old: "exists for problems with no Jacobian columns". New: "is designed for …". It is not in the conditional, so it can read as shipped. Fix: "The derivative-free trim fallback ([§14.8]) would serve problems with no Jacobian columns, a case linearization does not have."
- **C-081 (M65), minor.** Old: "works the three-component chain through". §7.2 1905 says "the chain", so "three-component" is lost. Accept, or add it to §7.2 at landing.

## Code checks

- V13 and V14 match `_check_seedable` (336–347). A `.name` step or a second step is `:unseedable`, a non-`Real` leaf `:vector_tap`, a non-`Float64` `Real` `:unseedable`. V15 matches 405–413. V17 matches 308–313. V36 matches 156–157.
- R14 gap: V13 and V14 never say what a violation does. Fix: add "; any other is rejected as a `TapResolution`". V17 could add "as a `TapResolution`" too.

## Citations

- F59: each replacement carries its claim. D-197 has the rejection in its Position and the no-silent-zeros link in its Rationale. D-295 bullet 3 and D-296 bullet 4 carry the unseedable root input and its rejection. D-263 bullet 2 carries "enforced at the wire".
- The other added citations hold at the fields `rulings.md` names: D-072 Position and bullets 1–6, D-272 bullets 1–5, D-274 bullet 5, D-319 bullet 5, D-297 bullet 2, D-406 bullet 2, D-073, D-286 and D-266 bullets 1 and 3. V121's D-263 rests on its Rationale only, as declared.
- Every old citation survives or moves with its claim. M63–M65's cut claims are held at §8.2 2545–2547, 2684–2689 and 2760–2766, §9.5 5018–5020 and §7.2 1903–1914.

## Bold

17 spans, each one ruling's headline with its entry. D-197 and D-266 each bold two separate rulings. No ruling is bold twice, in the spec or in units A, B, F and G.

## Moves and pointers

M61–M65 are done, and no others. After M62, "(above)" (line 89) and both "below"s (56–57, 135) are right. *Door* appears only as §8.2's "freeze door" and "FFI door", in pointers.

## Reader-cold names

- Class 1: `assign!`, acceptable because the sentence names Flight.jl.
- Class 2, one clause each, all inherited from the old text: ZOH, Tustin, FMU, saltation corrections, LQR.
- Class 3: none.

## Other

`rulings.md` open questions 1, 3 and 4 are stale, since R24 and R26 settled them. "The default width's scalar type is public" is still unruled. `LinearizeDual` (`src/linearize.jl` 64) is neither exported nor `public`.

## Re-check

- C-128 is OK. "would serve problems with no Jacobian columns" is in the conditional, as R10 asks, and keeps old 233–235's claim and its §14.8 citation. D-266's Rationale backs the asymmetry. The next sentence (`handle_walk_walkthrough.md`, C-129) is unaffected.
- C-081 is OK. The sentence matches old verbatim and ends the paragraph after the temporal-flow sentence, with no antecedent at stake. §7.2 1905 still links the same file, so the section now points to it twice. That is a pointer, not a doubled fact, so it is acceptable.
- `build_inventory.py ch14 H`: 135 claims, 7 added, 0 checks failed. Both claims map to `new.md`. The citation diff is unchanged: only D-167 drops out, as F59 requires. The code-span diff is backtick-pairing noise. There are 17 bold spans and the headings are unchanged.
- Nothing new.
