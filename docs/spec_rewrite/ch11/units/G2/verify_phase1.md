# G2 verify, phase 1 (blind assertions from new.md)

## The binding
V1. A binding is a value subtyping `AbstractBinding`.
V2. `AbstractBinding` is the second mandatory root.
V3. Its type declares which sides it has.
V4. Its type enumerates what each side touches.
V5. A binding is framework-legible by enumeration and opaque in its mappings.
V6. The legible half is explicit methods returning data.
V7. The legible half is called once at attach, on the calling task (the task that invoked `run!`). [#g-calling-task]
V8. The opaque half is called per datum on the device task by the author's own loop.
V9. Code block: `T16000MBinding <: AbstractBinding` with field `table::NamedTuple`; roots mandatory because `attach!` dispatches on `::AbstractDevice, ::AbstractBinding`.
V10. Code block: sides are declared, never inferred; the root carries false defaults, so silence = absent.
V11. Code block: `is_greedy` is the claim source within the input side (§11.3).
V12. Code block: `claims(b)` input side: enumerated face set → the claim; `map_input(datum,b)`: datum → face ⇒ value pairs, user code.
V13. Code block: `reads(b)` output side: labeled §14.4 selectors → one compiled gather; `map_output(nt,b)`: gather NamedTuple → wire datum.
V14. The root carries `is_greedy(::AbstractBinding) = false` beside the two side defaults, so silence is not greediness. [D-177]
V15. The computed claim source is declared or absent.
V16. The framework needs no contract on the datum's shape.
V17. The datum travels only between `loop` and `map_input`, written by the same author.
V18. The framework's structural knowledge comes entirely from the declared traits and enumeration methods.
V19. Everything enumerable validates at attach.
V20. Everything opaque is bounded at its runtime enforcement point.
V21. `map_input` is bounded by the staging checks. [§11.4]
V22. `map_output` receives exactly the compiled gather's NamedTuple.
V23. What `map_output` puts on the wire is the peer's business.
V24. BOLD: `map_input`/`map_output` are, precisely, conventions of the author-owned loop idiom. [D-177]
V25. The framework never calls them.
V26. So they are taught [Appendix A] and never checked.
V27. A binding whose loop calls something else by another name is simply a binding with a different private helper.
V28. BOLD: `reads(b)` returns a labeled NamedTuple of selectors. [#g-selector] [D-199]
V29. Selectors are the closed family of deferred reads. [§14.4]
V30. Example `(; alt = get_output(…), pose = get_face(…))`.
V31. Labels are the binding's own naming.
V32. Labels are carried through compilation in declaration order.
V33. So the NamedTuple `map_output` receives is keyed by exactly the names `reads` declared.
V34. One returned value fixes names, order and reads together. [D-199]
V35. ... under the same attach-time validation as `claims`. [D-199]
V36. The periphery gets roots where components (the units of modeling) have one. [#g-component]
V37. §8.5 refuses a supertype for class (a component's primitive-vs-assembly status). [§8.5] [#g-class]
V38. §8.5 refuses it for two reasons; neither reaches here.
V39. First: a component's single-inheritance slot is already spoken for by domain hierarchies (`AbstractAircraft`, engine families).
V40. A device's and a binding's slots are vacant; nothing else wants them.
V41. Second: a component's class is implementation detail behind its contract. [§8.5]
V42. A binding's sidedness is its public contract, the one thing every consumer must know. [D-177]

## The conformance check
V43. BOLD: Sides are declared, and the obligations they create are enforced both ways. [D-177]
V44. `claims` and `reads` have error-throwing fallbacks on the root.
V45. Therefore a declared side whose method was never written fails loudly at the attach point rather than degrading into silence.
V46. The attach runs a bidirectional conformance check over the pair (trait, method).
V47. `is_input && !is_greedy` ⇒ `claims(b)` called once and its faces staked. [#g-face; faces = names ports wear on components' boundaries]
V48. The fallback firing there means "you declared an input side and wrote no enumeration".
V49. `is_input && is_greedy` ⇒ the claim is computed [§11.3]; a `claims` method defined for this binding is an error.
V50. The two sources are alternatives, not layers.
V51. `is_output` ⇒ `reads(b)` is called and the gather compiled.
V52. Neither side declared ⇒ attach-time error naming both traits.
V53. A binding that touches nothing is a configuration mistake, not a degenerate.
V54. `is_greedy` without `is_input` ⇒ error.
V55. Greediness is a source within a side; a source without its side is meaningless.
V56. A specific method of `claims`/`reads` defined for the binding type while its trait reads false ⇒ error, the converse direction.
V57. A method written and never reached is exactly the drift the check exists to catch.
V58. Detecting it is one `which` against the fallback method.
V59. It is the same kind of reflection check as §8.1's shadowing check, an `isdefined`/`!==` pair. [§8.1]
V60. The `which` detection runs once at a stopped-sim service point, not inside any frame.
V61. Every violation in that list reports `BindingContractMismatch`. [Appendix C]
V62. The report names binding type, trait, method at fault and direction (declared-but-missing, or defined-but-undeclared).
V63. `gather` against a binding with no output side reports `DeviceContractMismatch`. [D-216]
V64. `DeviceContractMismatch` is the device twin of `BindingContractMismatch`. [D-216]
V65. Declared sides, checked both ways, close the shadowing hole.
V66. Detection by method presence is the rejected alternative. [D-177]
V67. Under it, a bidirectional binding whose `claims` was written without extending the framework's generic presented as output-only and degraded silently.
V68. That omission is the `using`-without-`import` trap [§8.1], one level down.
V69. With the side declared, the absent method has something to contradict.
V70. An abstract binding-type taxonomy encoding the sides stays rejected. [D-177]
V71. Optional roots left unenforced stay rejected. [D-177]
V72. A declared `sides(b)` trait returning the side set stays rejected. [D-177]

## Greedy claims
V73. `is_greedy` is a claim source, not a device class. [D-174]
V74. A binding declares that source in exactly one line, in the open.
V75. Past the attach point nothing tells a greedy claim (unclaimed complement computed at attach) from a returned one. [§11.3] [#g-greedy-claim]
V76. Greediness stays orthogonal to `reads`.
V77. A greedy front end may also drive a compiled output gather.
V78. That combination is legal and currently uninstantiated.
V79. Its plausible customer is a narrow-wire interactive surface, a motorized control board whose detents must be driven back out.
V80. The binding stays an `attach!` argument, never a device field.
V81. The same `T16000M` binds differently per aircraft.
V82. Narrowing the binding narrows the claim. [§11.3]
V83. BOLD: A second greedy attach stakes the empty remainder. [D-174]
V84. The complement is computed against the roster as it stands.
V85. Therefore a greedy binding attached after another has swallowed everything gets the empty claim.
V86. That claim is legal, being the honest may-write-nothing degenerate below.
V87. It is useless, worth saying out loud.
V88. The attach succeeds and records `EmptyGreedyClaim` [Appendix C; a warning naming device and binding] in the roster entry's diagnostic cell.
V89. `attach!` mutates the roster, so the warning lives in that state's status.
V90. It surfaces through the status record. [§11.8] [D-250]
V91. The log line at return is presentation.
V92. That is the one honest reading of "you asked for what is left and nothing was left".
V93. BOLD: Several interactive front ends may be rostered at once. [D-174]
V94. Example: a web console claims autopilot faces beside a local GUI claiming stick faces.
V95. With explicit claims they are two enumerated devices, partitioning the surface rather than sharing it.
V96. The standard GUI binding is a greedy one.
V97. It declares `is_input` and `is_greedy`, stakes the computed claim (everything unclaimed at attach), defines no `claims`.
V98. It declares no `reads`, because its read path is the handle's primitive read.
V99. The compiled output gather therefore has nothing to do for it.
V100. The same GUI device type is equally attachable under a binding returning explicit claims.
V101. Greediness is the binding's declaration, not the device's nature.
V102. Every other interactive front end (web console, remote panel) has both spellings available: greedy where the GUI would have been, or explicit beside other front ends.

## The empty enumeration
V103. The empty enumeration is not a back door.
V104. BOLD: `is_input(b) = true` with `claims(b) = ()` stays an honest degenerate, a device that may write nothing. [D-177]
V105. Its writes are still binding-bounded, so drift onto any face is `OutOfClaimEntry`. [D-044]
V106. There is no privileged class for it to promote into.
V107. `claims` bodies are ordinary code (the idiom [§8.5]; comprehensions included).
V108. An enumeration that came back empty by accident stays inert, exactly as written.
V109. The maximal surface is reachable only through the explicit `is_greedy(b) = true` declaration.
V110. The most privileged claim is the hardest to acquire by accident; a declared trait is deliberate authorship.
V111. For the same reason `claims` never returns `nothing` or a sentinel to mean "compute it for me".
V112. The enumeration contract has one meaning; the trait carries the other.
V113. A dual-meaning return would be exactly the ambiguity the declaration vocabulary is built to refuse.

## TableBinding
V114. `TableBinding` is the one shipped binding type.
V115. It is data-driven.
V116. The framework writes its `map_input` once.
V117. A table value (axis/button entry → face, deadzone/expo parameters) is constructed per device × aircraft pairing, where configurations are made. [D-045]
V118. Code block: `TableBinding(stick_y=..., throttle=..., trigger=(face="brake_count",))` # levels doctrine: a counter.
V119. A malformed table reports `ArgumentInvalid`, collected over the table's entries. [D-216]
V120. `TableBinding`'s generic `map_input` is the shared pure conditioning helper [§11.4], and its owner.
V121. The entry tuple rides in the type, so the mapping specializes per table with no dynamic dispatch.
V122. A code-driven binding looks identical to the framework.
V123. Example: a JSON telecommand peer whose `claims` returns the vocabulary and whose `map_input` parses bytes.
V124. One purity note is taught in Appendix A.
V125. Cross-datum state (press counters, edge detection) lives in the device struct, maintained by the loop, and arrives inside the datum.
V126. `map_input` stays pure.
