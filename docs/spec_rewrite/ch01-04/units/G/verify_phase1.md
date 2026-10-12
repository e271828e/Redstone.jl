# Unit G verify, phase 1 (blind read of new.md)

V1. Atmosphere and terrain are query-shaped.
V2. Consumers evaluate them at arguments of their own choosing (e.g. each gear strut at its own contact point; airflow at the vehicle pose).
V3. (bold) Ordinary ports carry them as immutable query objects, called field handles, because of that shape. [D-008]
V4. Gloss: a port is one declared name with its cell.
V5. Gloss: component = the unit of modeling, leaf or assembly.
V6. An environment component emits a field value (illustrative `ISAField(T_sl, p_sl, wind)`, `TerrainField(…)`).
V7. Consumers receive it through ordinary input ports.
V8. Inside their own stage functions (`y_state`/`y_direct`), consumers call query functions on it (illustrative `airdata(field, pos, vel)`, `ray_intersect(field, p, u)`).
V9. Parametric environment models are isbits; examples ISA, uniform wind, horizontal terrain.
V10. Bulk-data environment models use the handle pattern.
V11. The handle is an immutable struct combining isbits parameters with references to bulk data loaded at build time and frozen.
V12. Bulk data examples: heightmaps, wind grids, geoid undulation grid (gloss: geoid's height above the reference ellipsoid).
V13. Handles are rebuilt per evaluation without allocation, as immutable structs holding existing references.
V14. Handles are never `Ref`s, whose mutable box allocates.
V15. A field object must hold no mutable cache (e.g. memoizing interpolator, lazy loader).
V16. Reason: concurrent consumers and the GUI thread would race on it.
V17. Caches belong in the consumer's state, or the interpolant is restructured to be pure.
V18. Loggers treat field-handle signals specially; they skip or summarize them.
V19. (bold) Every field-emitting component must expose the map (component, input values) -> handle as a plain, pure, public function, its value-level constructor. [D-139]
V20. For the successor of FlightPhysics' `SimpleAtmosphere`, that function is `atmospheric_field(atm; T_sl, p_sl, wind)`.
V21. The field-emitting component's swept output stage must be a one-line call to that function, never the other way round.
V22. The other way round puts the query math in the output stage, where only a sweep can reach it. Gloss: sweep = one pass through the execution order.
V23. The reason is script-side: §14.1's condition math must be able to construct, outside any sweep, bit-for-bit the same handle the sweep would produce from the same root-input values. [§14.1]
V24. Gloss: root inputs = the inputs no component produces.
V25. One implementation serves two call sites, so there is no drift.
V26. The drift avoided is the silent drift §5.3 exists to kill. [§5.3]
V27. The value-level constructor is a shipped component's obligation, not something a consumer can retrofit.
V28. Reason: the real component composes environment sub-models, and anyone else reconstructing the map has re-created that drift.
V29. For bulk-data components the obligation is only that the query math be reachable as a plain function. [D-139]
V30. Bulk-data components own their resource loading, so building a handle outside a build may cost a load.
V31. That cost is acceptable because condition authoring is design-time code.
V32. Code sketch: the map as plain function; the stage that only calls it.
V33. Pre-sampling is an idiom built on top, used where natural, not a separate mechanism. [D-008]
V34. In pre-sampling a component consumes the field and a pose and emits plain data (illustrative `Airflow` emits FlightPhysics' `AirData` for the whole vehicle).
V35. Resource injection (declare-and-resolve service registries) is closed for the first cut. [D-008]
V36. The field-handle mechanism replaces threading `atmosphere`/`terrain` as arguments through every update signature.
V37. Flight.jl's landing-gear model finds contact through a bounded ray query to the terrain model.
V38. Substitutability behind a stable face is declared with an abstract input entry (illustrative `terrain = AbstractTerrainField`). Gloss: face = the name a port wears on its component's boundary.
V39. That is structural substitutability. [§8.2, D-296]
V40. The consumer wires to any concrete field type below the bound. [D-078]
V41. That preserves FlightPhysics' `AbstractTerrain` polymorphism at the declaration layer.
