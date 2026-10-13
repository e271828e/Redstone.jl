# Unit G2 rulings

Rulings applied: R5 (claim mechanism to one sentence and a pointer at §11.3;
`EmptyGreedyClaim` warning, second-greedy case and diagnostic cell kept here;
`map_output`'s labeled NamedTuple kept here as home; `TableBinding` kept here
as home), R6 (old 7973–7979 cut to one sentence naming the three rejected
alternatives, "are rejected", citing D-177; 7948–7953 kept), R10 (F51, F61), R12
(`gather` without an output side, `DeviceContractMismatch`; malformed
`TableBinding` table, `ArgumentInvalid`; both D-216), R23 (the standard GUI
binding; old 8013–8016 deleted into `deleted.md`). R15's hold on F71 is
replaced by R23. R11: `T16000M` is introduced by G1 earlier in §11.6 (G1's
loop sketches), so G2 adds no clause. Survey moves M55 (roots paragraph up,
after the `reads` rule) and M56 (orthogonality paragraph into the greedy
group) applied.

Labels: "The binding", "The conformance check", "Greedy claims", "The empty
enumeration", "`TableBinding`". The old heading's claim "One shipped binding
type" is kept in the text ("`TableBinding` is the one shipped binding type").

## Corrections proposed

- Verifier fix (V106): "There is no privileged class for it to promote into"
  becomes "privileged category", since *class* is linked in §11.6 in its
  glossary sense. "Enumeration contract" left as written.

- None beyond the rulings. Two notes:
  - "`TableBinding` is the one shipped binding type" (old heading 8039) sits
    beside "The standard GUI binding is a greedy one". Under R23 `src` ships no
    GUI binding, so the two now agree. If the standard GUI binding is later
    shipped, the heading's claim needs revisiting.
  - The M56 paragraph carries "The binding stays an `attach!` argument, never
    a device field ... narrowing the binding narrows the claim", which is
    about bindings in general, not greediness. Proposal: move those two
    sentences back into "The binding", after the roots paragraph. Not applied.

## Citations added or replaced

- D-177 at "The root carries `is_greedy(::AbstractBinding) = false` ...":
  Rationale, "framework defaults on the root — `is_input`/`is_output` false,
  `is_greedy` false".
- D-177 at the bold "`map_input`/`map_output` are, precisely, conventions of
  the author-owned loop idiom": Rationale, "`map_input`/`map_output` remain
  conventions of the author-owned loop idiom the framework never calls —
  taught in Appendix A, never checked".
- D-199 repeated in the bold `reads` sentence (the old cited it at the
  paragraph's end, kept there too): Position, "`reads(b)` returns a
  NamedTuple of §14.4 selectors".
- D-177 at the roots paragraph (M55 split it from its adjacent citation):
  Position, "§8.5's one-root rejection does not transfer, the periphery's
  single-inheritance slot being vacant ... and a binding's sidedness being its
  public contract".
- D-177 at the bold "Sides are declared, and the obligations they create are
  enforced both ways": Rationale, "Binding sides are declared by Bool traits
  ... enforced by error fallbacks ... plus a bidirectional conformance check
  at attach".
- D-216 at the `gather` sentence: Position, "`DeviceContractMismatch` joins
  the set: the device twin of `BindingContractMismatch` (no `loop` method;
  `gather` against a binding with no output side)".
- D-177 replaces "Rejected, correspondingly (D-177): ..." with the
  one-sentence form: Rejected, "Optional, unenforced supertypes",
  "Side-encoding supertypes"; Rationale, "The `sides(b)` rejection is answered
  rather than ignored". The dropped argument ("redundancy with a cross-check
  is drift detection") is in D-177's Rationale, log 6501–6504; the inventory
  maps it there.
- D-174 at "`is_greedy` is a claim source, not a device class" (plain):
  Position, "greediness is a claim source, not a device class".
- D-174 at the bold "A second greedy attach stakes the empty remainder":
  Rationale, "A second greedy attach finds an empty complement and stakes an
  empty claim".
- D-174 at the bold "Several interactive front ends may be rostered at once":
  Rationale, "multiple interactive front ends with explicit disjoint claims
  become legal (a web console claiming the autopilot faces beside a local GUI
  claiming the stick faces)".
- D-177 at the bold "`is_input(b) = true` with `claims(b) = ()` stays an
  honest degenerate": Rationale, "`is_input(b) = true` + `claims(b) = ()` is
  the honest may-write-nothing degenerate".
- D-044 at "Its writes are still binding-bounded ... `OutOfClaimEntry`":
  Position, "enumerated surfaces (a device's claim set — binding-bounded even
  on unclaimed faces, `OutOfClaimEntry`)". This clause is in the half D-174
  did not supersede.
- D-045 at "and it is *data-driven*" (`TableBinding`): Position bullet 3,
  "Mappings are declarative binding data with per-axis conditioning params".
  Moved there from the per-pairing clause at the verifier's request (C-090),
  since the bullet says nothing about per-pairing construction.
- D-216 at the `ArgumentInvalid` sentence: Position bullet 1,
  "`ArgumentInvalid` collects over a `TableBinding`'s entry table".
- D-044 kept after R5's pointer (verifier fix, C-059): "The standing
  rejection of opportunistic writing to unclaimed faces "for any device" is
  untouched ([D-044][d-044])". Rejected, "Unclaimed-surface opportunism "for
  any device"". Rejected-list only; listed below.

## Rationale-only rulings

- D-177, Rationale (log 6481–6496): the side defaults on the root, the error
  fallbacks, the bidirectional conformance check and every bullet, the
  `BindingContractMismatch` report, `map_input`/`map_output` as conventions.
  Bold on two of them, cited to D-177. D-177's Position states only the
  roots and the `attach!` signature.
- D-177, Rationale (log 6505–6508): the empty enumeration as the honest
  may-write-nothing degenerate. Bold, cited.
- D-177, Rationale and Rejected (log 6497–6504, 6519–6527): the shadowing
  hole and the three rejected alternatives.
- D-174, Rationale (log 6363–6368): the empty remainder and several
  interactive front ends. Both bold, cited.
- D-044, Rejected (log 1418–1419): opportunistic writing "for any device".
- D-216 is a Position; not rationale-only.

## Bold on the same entry elsewhere

- No ruling is bold in two places. Checked the frozen spec's chapters 5–10
  and 12–14 and units A–J's `new.md` files present now.
- D-174: unit C bolds "The harness cell drains last" (D-174 Rationale's
  harness paragraph) and the claim-sources sentence of its "Write surfaces
  and claim sources" subsection. G2's two D-174 bolds are other Rationale
  sentences; "`is_greedy` is a claim source, not a device class" (D-174
  Position) stays plain here because §11.3 is its home (R5).
- D-177 Position (mandatory roots): left plain here. G1 shows the `attach!`
  signature and the `AbstractDevice` root, where the run of the roots is
  described.
- D-045: units D and H bold other bullets (3 and 5). G2 cites bullet 3
  plain.
- D-250: chapter 13's two bolds are other bullets. G2's bullet 5 citation is
  plain, as in the old text.

## Glossary links

Left unlinked because G1's `new.md` links them first in §11.6: binding,
claim, device, roster, snapshot, drain, diagnostic cell, frame, periphery,
face (G1 uses it first, at its line 180, and takes the link).
Removed: `contract` (F61). G2's own first-use links, each glossed: calling
task, selector (gloss in its own sentence), component, class (added,
the glossary sense in "a supertype for class"), greedy claim (added, in the
R5 sentence). `trace` lost its link because its only use moved to §11.3
under R5. Not linked: `contract` in "behind its contract (§8.5)", which is
the glossary sense, because the same sentence uses "public contract" in
another sense. The orchestrator may add it.

## Inbound citations affected

- Rows citing §11.6 for "everything downstream is identical" (spec 12636,
  glossary 14127, log 6364, `inbound_periphery_walkthrough.md` 92) now find
  one sentence and a pointer at §11.3. Each cites §11.3 beside §11.6, so
  they stay true.
- Glossary `greedy-claim` (14012–14016) says "the shipped GUI binding is the
  shipped instance"; Appendix B renames under R23 at landing.
- Appendix C rows for `DeviceContractMismatch` (gather) and `ArgumentInvalid`
  (`TableBinding`) now find their conditions in §11.6.
- Spec 12373–12375 (Appendix A, "keep the traits trivial (§11.6)") still finds
  no such rule in §11.6. Pre-existing.

## Open questions

- D-177's Rationale (log 6501–6504) says the `sides(b)` answer is "annotated
  inline where §11.6 lists the rejection". R6 cuts that inline list to one
  sentence, so the log sentence goes stale. It needs a track 2 repair.

- The deleted render-loop read path (old 8013–8016) leaves "its read path is
  the handle's primitive read" with no pacing. Whether the bridge's browser
  client reads that way is D-310's open point.
- Unit C's text maps "shape, shim, merge, scatter" as "shape compilation
  (§11.4)". D-174's Position lists all four, so the claim is held, but the
  verifier may ask whether C's wording carries shim, merge and scatter.
- D-177 owes a Position stating the conformance check, its bullets and the
  empty-enumeration rule (survey 2 part E, item 1). D-174 owes one for the
  empty remainder and several front ends (item 7).
