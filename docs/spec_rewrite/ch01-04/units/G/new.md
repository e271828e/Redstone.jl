### 4.4 Function-valued signals: environment access

Atmosphere and terrain are query-shaped. Consumers evaluate them at arguments of
their own choosing, such as each gear strut at its own contact point, or airflow
at the vehicle pose. **Ordinary [ports](#g-port) carry them as immutable query objects**,
called [field handles](#g-field-handle), because of that shape ([D-008][d-008]). A port is one declared name
with its cell.

- An environment [component](#g-component) (the unit of modeling, leaf or
  assembly) emits a field value, such as the illustrative
  `ISAField(T_sl, p_sl, wind)` or `TerrainField(…)`. Consumers receive it
  through ordinary input ports. Inside their own
  [stage functions](#g-stage-function) (`y_state`/`y_direct`) they call query
  functions on it, such as the illustrative `airdata(field, pos, vel)` and
  `ray_intersect(field, p, u)`.
- Parametric environment models are isbits. Examples are the International
  Standard Atmosphere (ISA), uniform wind and horizontal terrain. Bulk-data
  environment models use the handle pattern. The handle is an immutable struct
  combining isbits parameters with references to bulk data loaded at build
  time and frozen. Such bulk data includes heightmaps, wind grids and the geoid
  undulation grid (the geoid's height above the reference ellipsoid). Handles
  are rebuilt per evaluation without allocation, as immutable structs holding
  existing references. They are never `Ref`s, whose mutable box allocates.
- A field object must hold no mutable cache, such as a memoizing interpolator
  or a lazy loader. Concurrent consumers and the GUI thread would race on it.
  Caches belong in the consumer's state, or the interpolant is restructured to
  be pure.
- Loggers treat field-handle signals specially. They skip or summarize them.

#### The value-level constructor

**Every field-emitting component must expose the map (component, input values)
→ handle as a plain, pure, public function**, its
[value-level constructor](#g-value-level-constructor) ([D-139][d-139]). For the
successor of FlightPhysics' `SimpleAtmosphere`, that function is
`atmospheric_field(atm; T_sl, p_sl, wind)`. The field-emitting component's
[swept](#g-sweep) output stage (run by a sweep, one pass through the
execution order) must be a one-line call to that function, never the other way
round. The other way round puts the query math in the output stage, where only
a sweep can reach it.

The reason is script-side. The condition math of [§14.1][s14-1] must be able
to construct, outside any sweep, bit-for-bit the same handle the sweep would
produce from the same values of the [root inputs](#g-root-input) (the inputs
no component produces). One implementation serves two call sites, so there is
no drift. The drift avoided here is the silent drift that [§5.3][s5-3] exists
to kill. The value-level constructor is a *shipped component's obligation*,
not something a consumer can retrofit. The real component composes environment
sub-models, and anyone else reconstructing the map has re-created that drift.

For bulk-data components the obligation is only that the query math be
reachable as a plain function ([D-139][d-139]). They own their resource
loading, so building a handle outside a build may cost a load. That cost is
acceptable, because condition authoring is design-time code.

The sketch below shows the map as a plain function, and the stage that does
nothing but call it.

```julia
#the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)

#the swept output stage: one line, nothing but the call
y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))
```

#### Pre-sampling and substitutability

Pre-sampling is an idiom built on top, used where natural, not a separate
mechanism ([D-008][d-008]). In it, a component consumes the field and a pose
and emits plain data, as an illustrative `Airflow` component emits
FlightPhysics' `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut
([D-008][d-008]).

The field-handle mechanism replaces Flight.jl's threading of `atmosphere`/`terrain`
as arguments through every update signature. Flight.jl's landing-gear model
finds contact through a bounded ray query to the terrain model, the query a
terrain field handle's `ray_intersect` serves. Substitutability behind a stable
[face](#g-face) (the name a port wears on its component's boundary) is declared with an
[abstract input entry](#g-abstract-entry), here the illustrative `terrain = AbstractTerrainField`. That
is structural substitutability ([§8.2][s8-2], [D-296][d-296]). An abstract input entry is an
input whose declared type is abstract. The consumer wires to any concrete field
type below the bound ([D-078][d-078]). That preserves FlightPhysics' `AbstractTerrain`
polymorphism at the declaration layer.

---
