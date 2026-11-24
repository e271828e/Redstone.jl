# G2b: rows for the fixer

Each row: the site at the pinned tip 72b12836, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV8-107 (deviation, clear=True)

- at: `src/assembly.jl:182`
- claim: ChildNameCollision's reason values :sample_times_sugar, :sibling_field and :two_children are named in neither spec nor Appendix C. The entry describes the arms in prose and a test matches on the symbol.
- evidence: src/assembly.jl:180, :186 and :265 raise ChildNameCollision with reason :sample_times_sugar, :sibling_field and :two_children (src/diagnostics.jl:826). test/test_assembly.jl:294, :310 and :321 match on the symbols. spec.md:15611-15616 describes the three arms in prose only, and rg finds none of the three symbols in spec.md or log.md. Other entries name their reasons, such as IllegalStateLeaf at spec.md:15537 and RatesViolation at :15603-15608.
- fix: Appendix C, ChildNameCollision: "Assembly path, the colliding child name, a `reason`, `:sample_times_sugar` (a bare container key against the `sample_times` sugar, [D-211][d-211]), `:sibling_field` (a bare key against a sibling field, [D-212][d-212]) or `:two_children` (two children with one name), and the declarations."

## CV8-109 (drift, clear=True)

- at: `src/assembly.jl:246`
- claim: The comment says the transparency check runs after the walk 'so a mixed container reports as one rather than as a bad transparency declaration'. A mixed container named by transparent_container reports both ContainerMixed and TransparentContainerUnknown.
- evidence: src/assembly.jl:246-256: _check_transparent pushes TransparentContainerUnknown into the same diags list after the walk pushed ContainerMixed (:168-170), and :204 throws both together. Probe '109 mixed+transparent' => [(:ContainerMixed), (:TransparentContainerUnknown)]. The comment dates from 2e974eab, when ContainerMixed threw fail-fast so the transparency check never ran. 3b5b204b moved to collecting over the child-naming pass, and D-431 (log.md:17528) records that move.
- fix: # The declaration is checked after the walk, so a mixed container it names reports `ContainerMixed` first, then `TransparentContainerUnknown`.

## CV8-125 (deviation, clear=True)

- at: `src/assembly.jl:626`
- claim: UnknownFaceSelection's reason :unknown_names is named nowhere. Spec 8.8 and Appendix B name only :multiple_selectors, and Appendix C says 'unknown names' in prose.
- evidence: src/assembly.jl:625-628 raises UnknownFaceSelection with reason = :unknown_names. Probe '125 unknown' => (:UnknownFaceSelection, :unknown_names). spec.md:4612-4613 (§8.8) says only 'errors with the child's face list in hand'. spec.md:15042 (Appendix B) and 4618-4619 name only :multiple_selectors, and spec.md:15595-15596 (Appendix C) says 'reason (unknown names / more than one selector given)'. rg finds no :unknown_names in spec.md or log.md.
- fix: Appendix C, UnknownFaceSelection: "The helper, the child's full path, a `reason`, `:unknown_names` (an `except` or `only` name the child lacks) or `:multiple_selectors` (more than one selector given), the offending names or the selectors given, the child's face list." §8.8's bullet: "`except` or `only` naming a nonexistent face is `UnknownFaceSelection` with reason `:unknown_names`, the child's face list in hand."

## CV8-131 (deviation, clear=True)

- at: `src/assembly.jl:704`
- claim: FaceNameIllegal's invariant values :empty and :contains_slash are not named. Appendix C says '(contains /, or empty)' in prose.
- evidence: src/assembly.jl:704 and src/structure.jl:761-762 raise FaceNameIllegal with invariant :empty or :contains_slash (src/diagnostics.jl:662). Probe '131 empty key' => (:FaceNameIllegal, :empty) and '131 slash face' => (:FaceNameIllegal, :contains_slash). spec.md:15572-15574 says '(contains `/`, or empty, ...)' in prose, and rg finds neither symbol in spec.md.
- fix: Appendix C, FaceNameIllegal: "Component path, face name, and the violated `invariant`, `:contains_slash` (the name contains `/`) or `:empty` (the name is empty, a primitive's contract key included, [D-437][d-437])."
- coordinator: Name the invariant values the code raises. Do not claim where the check runs; whether contract keys are checked for '/' is a separate defect left to the user (S8d-042).

## CV8-132 (drift, clear=True)

- at: `src/assembly.jl:771`
- claim: The comment 'a top marker says nothing where every leaf pins (§8.5, D-263)' cites 8.5. The topic, a Pinned entry on a discrete consumer, sits in 8.2. 8.5's 'One arity on both tiers' mentions only DeclarationOnWrongTier in general.
- evidence: src/assembly.jl:768-771 cites §8.5 for 'a top marker says nothing where every leaf pins'. That rule is in §8.2, at spec.md:2958-2962 ('On a discrete consumer it pins wholesale. A `Pinned` entry there says nothing') and :3503-3504. §8.5's 'One arity on both tiers' (spec.md:3720-3728) names DeclarationOnWrongTier only in general. Until ef7f5dd8 (chapter 8's readability rewrite), §8.5 said '`Pinned` on a discrete leaf, is the same kind', which git log -S traces. Probe '132 disc top' => (:DeclarationOnWrongTier, :pinned_entry).
- fix: # and a top marker says nothing where every leaf pins (§8.2, D-263).

## CV8-047 (drift, clear=True)

- at: `src/declare.jl:353`
- claim: transparent_container docstring names ChildNameCollision only for a bare key that collides with a sibling child's name. The build also raises it for a bare key equal to its own field's name and for a key equal to a sibling container field's name.
- evidence: src/declare.jl:349-352 names ChildNameCollision only for 'a bare key that collides with a sibling child's name'. src/assembly.jl:178-183 also raises it as :sample_times_sugar for a bare key equal to its own field's name, and :184-189 as :sibling_field for a key equal to a sibling container field that holds children. test/test_assembly.jl:310 and :321 assert both. D-212 (sibling container field) and D-215 (the sample_times arm) record the two arms after D-211, whose wording the docstring follows.
- fix: On an [assembly](@ref g-assembly), the build refuses a name that matches no container field as `TransparentContainerUnknown`. It refuses a bare key as `ChildNameCollision` when the key collides with a sibling child's name, equals its own field's name, or equals the name of a sibling container field that holds children.

## CV8-098 (deviation, clear=True)

- at: `src/declare.jl:988`
- claim: BundleFieldError's reason values :undeclared, :illegal_for_family and :wrong_tier appear in neither spec nor Appendix C. Appendix C describes the classification in prose only. Other kinds name their reason symbols.
- evidence: src/declare.jl:916-921 classify_bundle_field returns :undeclared, :illegal_for_family or :wrong_tier, carried as BundleFieldError.reason (src/declare.jl:976-979, src/diagnostics.jl:1201). Probe '098 bundle classes' => [:undeclared, :wrong_tier, :illegal_for_family]. spec.md:15693-15697 says 'classification (undeclared store / wrong-tier fact / illegal for this function family)', and rg finds none of the three symbols in spec.md or log.md.
- fix: Appendix C, BundleFieldError: "Component path, function family, the primitive's tier, requested field, the legal field set, and a `reason`, `:undeclared` (an undeclared store), `:wrong_tier` (a wrong-tier fact) or `:illegal_for_family` (illegal for this function family)."

## S8e-122 (deviation, clear=True)

- at: `design/spec.md:4619`
- claim: the :multiple_selectors diagnostic reads "more than one selector given"
- evidence: src/diagnostics.jl:738-740: the :multiple_selectors message reads "`input_passthrough` at `s`: `except`, `only` were given together — the three selectors are exclusive, one per call, and a second rule takes a second call (§8.8)" (probe). The quoted text 'more than one selector given' never appears in src, and git log -S on src finds no commit that ever held it.
- fix: More than one selector given is `UnknownFaceSelection` with reason `:multiple_selectors`, its message naming the selectors given together and stating that the three are exclusive, one per call, its payload naming the selectors given.
- note: spec_rules.md:89-90 says quoted diagnostic messages stay verbatim, so the quotation reads as message text. Appendix C (spec.md:15595) uses the same phrase only as a gloss of the reason, which is accurate.

## S8e-131 (deviation, clear=True)

- at: `design/spec.md:4629`
- claim: an `only` may name faces that exist while keeping nothing, and so raise EmptyFaceSelection
- evidence: src/assembly.jl:633-636: '`only` cannot reach here — a non-empty `only` of known names keeps them all' (also src/diagnostics.jl:749-750). Probe: only = ("a","b") and only = ("a",) raise no EmptyFaceSelection. An empty only counts as no selector. The code has held this since 97c63804, the commit that implemented D-251.
- fix: An `except` may list every face, or a `select` may match none. An `only` passes the unknown-names check only by naming faces that exist, and it then keeps them all, so it never raises the warning.
- note: D-251's rationale (log.md:10421-10423) carries the same garbled clause, '`only` naming faces that exist but a `select` that matches none', which the spec copies. The entry's Position never rules that `only` can warn.
