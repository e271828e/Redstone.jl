# Unit H rulings: §14.10

## Corrections proposed

None outside the rulings. Applied as ruled: F53 (R9, fitted, see open
question 1), F59, F60, F64, F65 (R12), F66 (R13), F67, F71 (R14), F72, F74,
F75, F76, F83, and R10's conditional for the two fallback sentences (old
182–184, 233–235).

Wording changes for the reserved words and the glossary, no claim changed:

- Old 16, "one tap per [component]" becomes "one tap per element" (F66). The
  component link moves to its first real use, "`LinearizedSS` the
  *component*".
- Old 16, "a vector or a bundle" becomes "a vector or a struct". *Bundle* is
  reserved for the stage's NamedTuple of views, and the code refuses any
  non-`Real` leaf as `:vector_tap` (`src/linearize.jl` 342, 409).
- Bare *entry* becomes "tap" (old 34–35, two uses; old 46, dropped) or
  "input entry" (old 76, 78, 83, 84, 198–201, 211, 236), by sense. The table
  keeps its "whose entry is declared `Pinned`" verbatim, as the brief orders.
- Old 176, "The honest boundary" becomes "The honest limit" (F66). Old 182,
  "the closed-loop trim door" becomes "extension", and old 189, "Both halves
  of this door" becomes "of non-participation" (R13). "Freeze door" and "FFI
  door" stay as §8.2's names, in pointers.
- Old 106, `FiniteDiff` first occurs in the operating-point paragraph after
  M62, so the clause "the `FiniteDiff` package" lands there.
- Old 107, "the `Model`'s state" in the checkpoint gloss becomes "the
  model's state", so that `Model` is first used where its link and gloss sit.
- Old 13–14, the citations leave the leaf address's gloss.

One stated fact the code does not bear out, left as written:

- Old 47–48, "the default width's scalar type is public". `LinearizeDual`
  (`src/linearize.jl` 64) is named but neither exported nor declared
  `public`; `src/Redstone.jl` has neither statement (survey row 692).
  Proposed: "the default width's scalar type is named", or a `public`
  declaration in the code. The text stays.

## Citations added or replaced

- D-072, ten sites, each for a standing clause only (D-072 bullet 3's
  `capture(sim)` is overtaken by D-274):
  - the tap-set bold: Position, "three selector lists … validated against
    schema, compiled to offsets, relocatable via `at`";
  - "The lists compile to offsets once": the same Position sentence;
  - "no hand-written state-space mapping remains": bullet 1, "The
    `get_*_ss`/`assign_*_ss!` shuttle layer is deleted, discharging §7.1";
  - "Linearization is a pure query": bullet 3, "Linearization is a pure
    query — no commit, no boundary zero, no restore dance";
  - "It then runs the seeded `Dual` evaluation": bullet 2, "Evaluation is one
    chunked Dual pass on per-invocation scratch at the operating point";
  - "Unseeded states sit constant": bullet 2, "unseeded states stay
    constant, the discrete tier frozen-exact";
  - "`linearize` returns a `Linearization` value": bullet 4, "It returns
    labeled data";
  - `LinearizedSS`: bullet 5, "`LinearizedSS` survives as an ordinary
    continuous component";
  - the guidance: bullet 6, "Guidance: surfaces select minimal-coordinate
    mechanizations, the `{NED}` rig practice, now stated";
  - the §7.2 pointer: bullet 2's "the discrete tier frozen-exact", and §7.2's
    own citation of the law.
- D-272: bullet 2 at "A tap names one scalar" ("A tap names one scalar.");
  bullet 4's second sentence at `about` ("`about = <condition>`, with `t0`
  beside it, places it anywhere else"); bullet 5 at the return ("The return
  is a `Linearization` value").
- D-406, bullet 2, at the did-you-mean errors: "The refusals the resolver
  raises are one kind, `ReadResolution` … `TapResolution` keeps §14.10's
  five tap-set reasons alone".
- D-197 at the discrete-store bold: Position, "a tap naming a discrete store
  is a tap-resolution error carrying the offending entry and its tier".
- D-167 dropped at old 36 (D-197 stays), old 79 (replaced by D-295 bullet 3,
  "a `Pinned` one is declaredly unseedable", and D-296 bullet 4, "A `B`-matrix
  tap selecting a root input that a consumer's entry pins is rejected at tap
  resolution, naming the pinning consumer and its entry"), and old 198
  (replaced by D-263 bullet 2, "an unpinned position is tolerant, a `Pinned`
  one demands a frozen arrival. Both wire clauses of §6.1 stand", cited on
  the next sentence). F59.
- D-274 bullet 5 and D-319 bullet 5 at the default-point bold: "`linearize`'s
  default operating point is the checkpoint of the simulation as it stands";
  "its default operating point is `checkpoint(model)`".
- §7.2 and D-297 bullet 2 at the seeding pointer: "Partials enter through
  per-invocation seeding, never through initialization and never through
  typing".
- §8.2 and D-295 bullet 3 at the seedability pointer, and D-295 at "a
  *choice* … a *declaration*": "Seedability is therefore schema-visible".
- D-073 at the sampled-data bold: Position, "sampled-data Dual activation
  recorded unbuilt (§14.10)".
- D-263 at "Both halves of non-participation have a spelling": Rationale
  only (below).
- D-286 at the freeze door: Position, "A pinned leaf is the schema-visible
  freeze", and bullet 3, "declares the leaf `Pinned{Float64}` and strips
  inside the stage"; at the conformance check: Position, "the conformance
  check holds it to its word at every activation".
- D-266 at the local-rule bold, bullet 1: "keeps its entry tolerant and
  supplies its own local derivative inside the stage".
- Pointers added: §8.2 (FFI door, seedability), §9.5 (freeze door), §7.2
  (the law, seeding).

## Rationale-only rulings

- D-263, Rationale (log 10958–10960): "§14.10's freeze door and the FFI door
  survive as declared doors", the only statement behind "Both halves of
  non-participation have a spelling" (F75). Cited, plain. D-286's Rationale
  (log 12613–12615) says the same.
- D-272, annotation of 2026-09-28 (log 11825–11836): two taps at one site
  refused with both labels in hand; the tier-pinned root input's refusal
  naming the tier; `t0` admitted only beside `about`. Cited by adjacency, as
  before. Survey part E, item 1, asks for a Position.
- D-197, Rationale (log 7628–7636): the no-silent-zeros principle at the
  `x` tap and the next-move guidance toward $\Phi$.
- D-266, Rationale (log 11217–11227): the mid-expression stripping, the
  finite-difference quality and the trim fallback's asymmetry.
- D-072, Rejected (log 2361–2367): the four `FiniteDiff` jacobians, the ~150
  lines, the restore dance, the coordinate choice. Uncited history, as before.

## Bold on the same entry elsewhere

- No ruling is bold in two places. Checked against the frozen spec's other
  chapters and units A, B, F and G's `new.md`.
- D-266: its Position headline is bold at §8.2 2551. Bullets 1 and 3 are
  bold here only; old 208's restatement of the headline goes plain.
- D-295 bullet 3 (bold at §8.2 2686), D-168 (§8.2 2691) and D-286 (§9.5
  5018) stay plain here.
- D-274: §11.5, §12 and §13 bold other bullets (spec 7747, 9640, 10457);
  bullet 5 is bold here only.
- D-319: unit A bolds "Each row's service also has a form on a `Model`".
  Here D-319 is cited beside D-274 on D-274 bullet 5's bold. If A's bold is
  read as D-319 bullet 5, the two overlap; I read A's as the Position's
  "doors of the `Model`".
- D-406 (unit B bolds bullet 1), D-276 (unit B) and D-213 (unit F): cited or
  absent here, never bold.
- Rows of q24's list not bolded: D-072 bullet 6, the guidance. It is a
  recommendation ("taps should select"), which `spec_style.md` keeps out of
  bold. Cited plain.
- Bolded beyond q24's rows, by its instruction to bold one clause per ruling
  of each listed entry: D-072 bullet 1 (shuttle), bullet 2's two rulings
  (the pass; unseeded states constant), D-272 bullet 4's standing sentence
  (`about`), D-197's third Position sentence (the `s`-tap list). D-197's
  first Position sentence has two clauses by semicolon, the `x` list's
  continuous target and the refusal of a discrete store; I read them as one
  ruling and bolded the refusal. D-072's Position sentence shares the tap-set
  bold with D-272 bullet 1, and D-072 bullet 4 shares the return's bold with
  D-272 bullet 5. Seventeen bold spans in all.

## Inbound citations affected

- §8.2 2689 ("a `Pinned` root input is *declaredly* unseedable
  ([§14.10])"): holds, the phrase kept plain beside the rejection.
- §8.2 2713–2715 (the rejection naming the pinning consumer): holds.
- §8.2 2764 ("That delivers the recorded freeze door ([§14.10])"), D-263
  and D-286 Rationales, D-079 and D-166 Rationales: hold, on "The output half
  is the freeze door". §14.10 now points back to §8.2 and §9.5 for the
  spelling, so the two ends meet at one sentence each.
- D-197 Rationale (log 7628) and `linearization_walkthrough.md` 608 ("the
  frozen-exact doctrine ([§14.10])"): hold loosely. The doctrine sentence
  stays; the law points to §7.2. Track 2 may add §7.2.
- D-263 Rationale (log 11003) and D-167 Rejected (log 6437), "§14.10's
  sampled-data door"; D-266 Rationale, "the closed-loop sampled-data door":
  the section now says "extension" (R13). The rows still find the passage.
- The glossary's `taps` (14782–14786) and Appendix C's `TapResolution`
  (13661–13665) lack the step limit (F53), and Appendix C's `ArgumentInvalid`
  row does not list §14.10 (F71). Track 2, as the brief rules.
- §9.6 5122–5123 (the `get_x_ss` deletion via §7.1): a landing edit after
  F64, as the brief rules.

## Open questions

1. F53's proposed wording omits the restriction its heading states, that a
   seeded tap's leaf must be exactly `Float64` (`_check_seedable`,
   `src/linearize.jl` 344–345, `:unseedable`). I applied the wording as
   given. Should the sentence add "and its leaf is `Float64`"? Also, F53's
   "a whole cell" is fitted to "a whole state field or root input": an `x`
   seed lands in the state buffer, and bare *cell* is the signal table's.
   Ruled by R24.
2. The default point's bold cites D-274 and D-319, and the code is clear.
   Should D-319 be cited there at all, given unit A's D-319 bold (above)?
   Ruled by R25.
3. The `design_world` gloss copies the glossary's "the shipped thin world".
   Neither Redstone's `src/` nor Flight.jl's source has a `design_world`.
   "Shipped" is §14.9's word (unit G's); I left it.
   Ruled by R26.
4. M65 keeps "The frozen discrete cell is not an AD limitation on the signal
   path. It is the true zero of an instantaneous dependence that the hybrid
   semantics never had." plain, since §7.2 holds only "not a limitation but
   the exact answer". Trim them to the pointer as well?
   Ruled by R26.
