# Unit A, phase 1 (blind): assertions in new.md

V1. Components are the units of modeling, leaf or assembly. (glossary link)
V2. Components become a system through wiring.
V3. Connections route signals across the hierarchy of assemblies.
V4. Assemblies are components of pure composition, with no dynamics of their own. (glossary link)
V5. Ordinary junction components sit wherever several signals must combine into one.
V6. §6.1 gives connection and hierarchy rules; §6.2 gives the aggregation idiom they force. (pointers)
V7. A wire names its two endpoints by path; paths run down the hierarchy of children.
V8. How far a path may reach decides whether a parent addresses a grandchild's port directly or every intermediate level must re-export it. (roadmap)
V9. A port is one declared input or output. (glossary link)
V10. Section order: reach, then wire type-checking, then connections per port (count and unconnected ports). (roadmap)
V11. An assembly has three wiring declarations. [§8.6]
V12. A local_wires pair wires one child's face to another's.
V13. A face is the name a port wears on its component's boundary. (glossary link)
V14. An input_wires entry routes a face to an immediate child's face.
V15. An output_wires entry sources a face from an immediate child's face.
V16. An entry of any of the three is a wire; an entry of the first is a local wire. [D-303, D-314]
V17. (bold) Every connection endpoint names an immediate child and one of its faces. [D-207]
V18. The rule covers all three wiring declarations.
V19. Container children are elements of a Tuple or NamedTuple field holding only components. [§8.5]
V20. Container children keep their key segment; "aircraft/2/face" is one level, not two. [D-085]
V21. A name-transparent container (§8.5) is the exception; its elements go by bare key, "ctl/face" reads as a plain child's endpoint, one level. [D-211]
V22. An endpoint naming no port of the child it resolves to is an UnknownPort error, at either end of the wire. [D-113, Appendix C]
V23. Therefore routing across several levels is declared level by level, each assembly speaking only of its own children.
V24. This restriction is named the locality law. [D-065]
V25. Fragments of the condition algebra follow the same law. [§14.2]
V26. Sketch: root Cessna172 holds Systems, which holds landing gear Ldg with legs left, right, nose.
V27. The root's input trn is a terrain field handle. [§4.4]
V28. Cessna172 hands trn to systems, Systems to ldg, Ldg fans it out to three legs.
V29. The fan-out is declared at the level where the paths diverge.
V30. Code: input_wires methods per level, with fan-out as tuple of targets.
V31. First consequence: faces become the only currency crossing an assembly boundary, so substitutability holds at every boundary rather than only generic ones.
V32. This is the contract-is-the-interface principle of §8.3 with its one leak closed. [§8.3]
V33. Second consequence: the face graph is total. [D-207]
V34. Every signal crossing a boundary bears a declared face there, at every level it crosses.
V35. Totality is what the condition algebra addresses against.
V36. An `at` prefix stopping at a child's face has a name to resolve through. [§14.2]
V37. The ceremony the rule costs is the re-export entry per level.
V38. The design already pays this ceremony almost everywhere, because every level of a realistic tree is a generic seam, where one-level routing was mandatory anyway. [§8.8]
V39. A seam is a narrow, named interface kept deliberately thin. (glossary link)
V40. Where entries multiply, they are computed, not typed, via input_passthrough/output_passthrough over a single authored feed list. [§8.8]
V41. Parallel routes threading many boundaries signal to gather them into a component of their own. [D-207]
V42. Enforcement lives in the path-resolution primitive `resolve`. [§13.3, D-130]
V43. resolve walks declared field types alongside instances. [D-061]
V44. An endpoint reaching past the immediate child is a PathResolution error. [Appendix C]
V45. Paths are validated at build time.
V46. Renames break loudly.
