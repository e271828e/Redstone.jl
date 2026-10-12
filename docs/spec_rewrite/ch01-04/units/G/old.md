### 4.4 Function-valued signals: environment access

Atmosphere and terrain are **query-shaped**. Consumers evaluate them at
arguments of their own choosing, such as each gear strut at its own contact
point, or airflow at the vehicle pose. Ordinary [ports](#g-port) therefore carry them as
**immutable query objects**, called [field handles](#g-field-handle).

- An environment [component](#g-component) emits a field value (`ISAField(T_sl, p_sl, wind)`,
  `TerrainField(…)`), and consumers receive it through ordinary input ports.
  Inside their own [stage functions](#g-stage-function) (`y_state`/`y_direct`) they call
  query functions on it, such as `airdata(field, pos, vel)` and
  `ray_intersect(field, p, u)`.
- **Parametric models are isbits** (ISA, uniform wind, horizontal terrain).
  **Bulk-data models use the handle pattern.** The handle is an immutable struct
  combining isbits parameters with references to bulk data (heightmaps, wind
  grids, the geoid undulation grid) loaded at build time and frozen. Handles are
  rebuilt per evaluation without allocation, as immutable structs holding
  existing references. They are never `Ref`s, whose mutable cell allocates.
- **No mutable caches inside field objects**, such as memoizing interpolators or
  lazy loaders. Concurrent consumers and the GUI thread would race on them.
  Caches belong in the consumer's state, or the interpolant is restructured to
  be pure.
- Loggers treat field-handle signals specially. They skip or summarize them.

**The [value-level constructor](#g-value-level-constructor).** Every field-emitting component must expose the
map (component, input values) → handle as a plain, pure, public function. For
the `SimpleAtmosphere` successor that function is `atmospheric_field(atm; T_sl,
p_sl, wind)`. The field-emitting component's swept output stage must be a
**one-line call to that function**, never the other way round. The other way
round puts the query math in the output stage, where only a [sweep](#g-sweep) can reach it.

The reason is script-side. The condition math ([§14.1][s14-1]) must be able to construct,
outside any sweep, bit-for-bit the same handle the sweep would produce from the
same [root input](#g-root-input) values. One implementation serves two call sites, so there is no
drift. The drift avoided here is the silent-drift class that [§5.3][s5-3] exists to
kill. This is a *shipped component's obligation*, not something a consumer can
retrofit. The real component composes sub-models, and anyone else reconstructing
the map has re-created the drift class.

For bulk-data components the obligation is only that the query math be reachable
as a plain function. They own their resource loading, so building a handle
outside a build may cost a load. That cost is acceptable, because condition
authoring is design-time code.

**Example.** The sketch below shows the map as a plain function, and the stage
that does nothing but call it.

```julia
#the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)

#the swept output stage: one line, nothing but the call
y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))
```

Pre-sampling is an **idiom built on top**, used where natural, not a separate
mechanism. In it, a component consumes the field and a pose and emits plain
data, as `Airflow` emits `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut ([D-008][d-008]).

The field-handle mechanism replaces threading `atmosphere`/`terrain` as
arguments through every update signature. It dovetails with the terrain
ray-query direction of the landing-gear redesign. Substitutability behind a
stable [face](#g-face) is declared with an abstract input entry, `terrain =
AbstractTerrainField`, which is structural substitutability ([§8.2][s8-2]). The consumer
wires to any concrete field type below the bound. That preserves today's
`AbstractTerrain` polymorphism at the declaration layer.

---

