# Unit F verify, phase 1 (blind read of new.md)

V1. [bold] Stage returns are named tuples of port values, period. [D-036]
V2. [bold] A custom struct is a first-class port value. [D-036]
V3. A struct port value is one field of the returned tuple, one declared port, one cell (`pose = KinPose{T}`; `KinPose` illustrative).
V4. Nested fields get no cells of their own.
V5. A reader reaches a nested field through the port's leaf address (field name plus dotted and bracketed steps), e.g. `"pose.q_eb"`. [§14.4, D-276]
V6. A wired consumer takes the bundle (the struct-valued port) whole.
V7. Bare-struct returns are rejected. [D-036]
V8. A port value's leaves are what the leaf walk reaches through `Real`s, static arrays and isbits structs. [D-237]
V8a. Gloss: the leaf walk is the framework's derivation of per-activation types.
V9. An enum is one leaf, pinned. [§8.2, D-316]
V10. `StopFlag` is the one enum with a framework meaning.
V11. An output port of type `StopFlag` is a stop request (a port that ends the run when it reads `STOP_REQUESTED`).
V12. A `StopFlag` nested in a port of another type, or declared as a root input, is refused (`IllegalPortType`). [§13.5, D-316]
V13. [bold] The walk stops at an immutable non-isbits type and treats it as one opaque leaf. [D-237]
V14. The table stores an opaque leaf whole, references included.
V15. A field handle (immutable query object evaluated at consumer-chosen arguments, §4.4) is such a leaf.
V16. [bold] A `Symbol` is an opaque leaf too. [D-243]
V17. Julia classifies `Symbol` mutable, but it is interned, immutable and never freed.
V18. §7.3 admits `Symbol` in a store on the same grounds, so a `Symbol` mode publishes like any other.
V19. [bold] A mutable type anywhere in a port value is refused, and so is an opaque leaf surfacing as a root input. [IllegalPortType, D-237]
V20. An opaque leaf as root input has no synthesis (reason for refusal).
V21. [bold] Wiring is port-granular. [D-276]
V22. There are no sub-field connections.
V23. A consumer wanting less than a bundle takes the bundle and destructures it, or asks the producer for a loose port. [D-276]
V24. It destructures in its own stage or through an unbundling component.
V25. An unbundling component is a `y_direct` leaf that takes the bundle and publishes its fields.
V26. The unbundling component is a candidate for the §13.7 standard library.
V27. A field-projection connector is a guarded addition (capability admitted but not built); its shape is obvious, and it is not built. [D-036]
V28. [bold] Under the granularity guideline, authors should bundle what shares a stage and is consumed together. [D-036]
V29. The first criterion is trivially enforced, because each port has exactly one producing function.
V30. Bundling across dependency footprints is the classic mistake.
V31. A kinematics bundle mixing pose (stage 1) with velocity-derived quantities (stage 2) must split.
V32. Fan-out is free, so publishing both a bundle and a hot loose field (`pose` and `q_eb`) is legitimate. (uncited)
V33. It costs one extra isbits cell.
V34. Sketch: bundle, loose hot field, and a face aliasing an interior port, in declaration form. `Kinematics`, `Vehicle` illustrative; `KinPose` illustrative.
V35. `RQuat` is FlightPhysics' rotation quaternion; `RQuat{Float64}` is the spec's form; FlightPhysics' `RQuat` takes no type parameter.
V36. Code: a continuous leaf with one bundle port and the hot field loose, two cells; the enclosing assembly's faces alias interior ports, creating no endpoint.
V37. [bold] Under the write-side rule, data written by different external writers, or at different cadences, must not share a port. [D-045]
V38. In short, bundle what is written together.
V39. Pilot commands are the case in point; they are scalar faces under a namespace prefix.
V40. The convenient bundle is assembled downstream, inside the graph, by an ordinary component.
V41. Assembling it there is legal by the read-side guideline, since the bundle has a single producer and is consumed together.
V42. The granularity guideline and the write-side rule compose into one principle.
V43. The finest-grained party owning either end sets a port's granularity: a producer on the read side, an external writer on the write side.
V44. Field-addressed staging (a lens into struct slots) stays a recorded guarded addition, unbuilt. (uncited)

Bold count: 8 (V1, V2, V13, V16, V19, V21, V28, V37).
