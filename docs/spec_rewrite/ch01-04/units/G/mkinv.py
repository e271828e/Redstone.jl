import json, os
H = os.path.dirname(os.path.abspath(__file__))
C = []
def c(old, new, tag, cites=(), newcites=None, ruling=None):
    d = {"id": f"C-{len(C)+1:03d}", "old": old, "new": new, "where": "new",
         "cites": list(cites), "tag": tag}
    if newcites is not None: d["newcites"] = list(newcites)
    if ruling: d["ruling"] = ruling
    C.append(d)

c("### 4.4 Function-valued signals: environment access", "### 4.4 Function-valued signals: environment access", "X")
c("Atmosphere and terrain are query-shaped.", "Atmosphere and terrain are query-shaped.", "F")
c("Consumers evaluate them at arguments of their own choosing, such as each gear strut at its own contact point, or airflow at the vehicle pose.",
  "Consumers evaluate them at arguments of their own choosing, such as each gear strut at its own contact point, or airflow at the vehicle pose.", "F")
c("Ordinary ports therefore carry them as immutable query objects, called field handles.",
  "Ordinary ports carry them as immutable query objects (a port is one declared name with its cell), called field handles, because of that shape (D-008).",
  "R", [], ["D-008"], "R6")
c("An environment component emits a field value (`ISAField(T_sl, p_sl, wind)`, `TerrainField(…)`),",
  "An environment component (the unit of modeling, leaf or assembly) emits a field value, such as the illustrative `ISAField(T_sl, p_sl, wind)` or `TerrainField(…)`.", "F")
c("and consumers receive it through ordinary input ports.", "Consumers receive it through ordinary input ports.", "F")
c("Inside their own stage functions (`y_state`/`y_direct`) they call query functions on it, such as `airdata(field, pos, vel)` and `ray_intersect(field, p, u)`.",
  "Inside their own stage functions (`y_state`/`y_direct`) they call query functions on it, such as the illustrative `airdata(field, pos, vel)` and `ray_intersect(field, p, u)`.", "F")
c("Parametric models are isbits (ISA, uniform wind, horizontal terrain).",
  "Parametric environment models are isbits. Examples are the International Standard Atmosphere (ISA), uniform wind and horizontal terrain.", "F")
c("Bulk-data models use the handle pattern.", "Bulk-data environment models use the handle pattern.", "F")
c("The handle is an immutable struct combining isbits parameters with references to bulk data (heightmaps, wind grids, the geoid undulation grid) loaded at build time and frozen.",
  "The handle is an immutable struct combining isbits parameters with references to bulk data loaded at build time and frozen. Such bulk data includes heightmaps, wind grids and the geoid undulation grid (the geoid's height above the reference ellipsoid).", "F")
c("Handles are rebuilt per evaluation without allocation, as immutable structs holding existing references.",
  "Handles are rebuilt per evaluation without allocation, as immutable structs holding existing references.", "F")
c("They are never `Ref`s, whose mutable cell allocates.", "They are never `Ref`s, whose mutable box allocates.", "F")
c("No mutable caches inside field objects, such as memoizing interpolators or lazy loaders.",
  "A field object must hold no mutable cache, such as a memoizing interpolator or a lazy loader.", "F")
c("Concurrent consumers and the GUI thread would race on them.", "Concurrent consumers and the GUI thread would race on it.", "F")
c("Caches belong in the consumer's state, or the interpolant is restructured to be pure.",
  "Caches belong in the consumer's state, or the interpolant is restructured to be pure.", "R", ruling="R8")
c("Loggers treat field-handle signals specially. They skip or summarize them.",
  "Loggers treat field-handle signals specially. They skip or summarize them.", "F")
c("The value-level constructor.", "#### The value-level constructor", "X")
c("Every field-emitting component must expose the map (component, input values) → handle as a plain, pure, public function.",
  "Every field-emitting component must expose the map (component, input values) → handle as a plain, pure, public function, its value-level constructor (D-139).",
  "R", [], ["D-139"], "R6")
c("For the `SimpleAtmosphere` successor that function is `atmospheric_field(atm; T_sl, p_sl, wind)`.",
  "For the successor of FlightPhysics' `SimpleAtmosphere`, that function is `atmospheric_field(atm; T_sl, p_sl, wind)`.", "F")
c("The field-emitting component's swept output stage must be a one-line call to that function, never the other way round.",
  "The field-emitting component's swept output stage (run by a sweep, one pass through the execution order) must be a one-line call to that function, never the other way round.", "F")
c("The other way round puts the query math in the output stage, where only a sweep can reach it.",
  "The other way round puts the query math in the output stage, where only a sweep can reach it.", "F")
c("The reason is script-side.", "The reason is script-side.", "X")
c("The condition math (§14.1) must be able to construct, outside any sweep, bit-for-bit the same handle the sweep would produce from the same root input values.",
  "The condition math of §14.1 must be able to construct, outside any sweep, bit-for-bit the same handle the sweep would produce from the same values of the root inputs (the inputs no component produces).",
  "F", ["§14.1"])
c("One implementation serves two call sites, so there is no drift.", "One implementation serves two call sites, so there is no drift.", "F")
c("The drift avoided here is the silent-drift class that §5.3 exists to kill.",
  "The drift avoided here is the silent drift that §5.3 exists to kill.", "F", ["§5.3"])
c("This is a shipped component's obligation, not something a consumer can retrofit.",
  "The value-level constructor is a shipped component's obligation, not something a consumer can retrofit.", "F")
c("The real component composes sub-models, and anyone else reconstructing the map has re-created the drift class.",
  "The real component composes environment sub-models, and anyone else reconstructing the map has re-created that drift.", "F")
c("For bulk-data components the obligation is only that the query math be reachable as a plain function.",
  "For bulk-data components the obligation is only that the query math be reachable as a plain function (D-139).", "C", [], ["D-139"])
c("They own their resource loading, so building a handle outside a build may cost a load.",
  "They own their resource loading, so building a handle outside a build may cost a load.", "F")
c("That cost is acceptable, because condition authoring is design-time code.",
  "That cost is acceptable, because condition authoring is design-time code.", "F")
c("Example. The sketch below shows the map as a plain function, and the stage that does nothing but call it.",
  "The sketch below shows the map as a plain function, and the stage that does nothing but call it.", "X")
c("#the map: plain, pure, public — callable outside any sweep atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)",
  "#the map: plain, pure, public — callable outside any sweep atmospheric_field(atm; T_sl, p_sl, wind) = ISAField(…)", "F")
c("#the swept output stage: one line, nothing but the call y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))",
  "#the swept output stage: one line, nothing but the call y_direct(atm, args) = (; … = atmospheric_field(atm; T_sl = …, p_sl = …, wind = …))", "F")
c("Pre-sampling is an idiom built on top, used where natural, not a separate mechanism.",
  "Pre-sampling is an idiom built on top, used where natural, not a separate mechanism (D-008).", "C", [], ["D-008"])
c("In it, a component consumes the field and a pose and emits plain data, as `Airflow` emits `AirData` for the whole vehicle.",
  "In it, a component consumes the field and a pose and emits plain data, as an illustrative `Airflow` component emits FlightPhysics' `AirData` for the whole vehicle.", "F")
c("Resource injection (declare-and-resolve service registries) is closed for the first cut (D-008).",
  "Resource injection (declare-and-resolve service registries) is closed for the first cut (D-008).", "F", ["D-008"])
c("The field-handle mechanism replaces threading `atmosphere`/`terrain` as arguments through every update signature.",
  "The field-handle mechanism replaces Flight.jl's threading of `atmosphere`/`terrain` as arguments through every update signature.", "F")
c("It dovetails with the terrain ray-query direction of the landing-gear redesign.",
  "Flight.jl's landing-gear model finds contact through a bounded ray query to the terrain model, the query a terrain field handle's `ray_intersect` serves.", "R", ruling="R11")
c("Substitutability behind a stable face is declared with an abstract input entry, `terrain = AbstractTerrainField`, which is structural substitutability (§8.2).",
  "Substitutability behind a stable face (the name a port wears on its component's boundary) is declared with an abstract input entry, here the illustrative `terrain = AbstractTerrainField`. That is structural substitutability (§8.2, D-296).",
  "C", ["§8.2"], ["§8.2", "D-296"])
c("The consumer wires to any concrete field type below the bound.",
  "The consumer wires to any concrete field type below the bound (D-078).", "C", [], ["D-078"])
c("That preserves today's `AbstractTerrain` polymorphism at the declaration layer.",
  "That preserves FlightPhysics' `AbstractTerrain` polymorphism at the declaration layer.", "R", ruling="R11")

added = [
  "#### Pre-sampling and substitutability",
  "(a port is one declared name with its cell)",
  "(the unit of modeling, leaf or assembly)",
  "such as the illustrative `ISAField(T_sl, p_sl, wind)`",
  "such as the illustrative `airdata(field, pos, vel)`",
  "Examples are the International Standard Atmosphere (ISA)",
  "(the geoid's height above the reference ellipsoid)",
  "(run by a sweep, one pass through the execution order)",
  "(the inputs no component produces)",
  "its value-level constructor",
  "the successor of FlightPhysics' `SimpleAtmosphere`",
  "an illustrative `Airflow` component emits FlightPhysics' `AirData`",
  "(the name a port wears on its component's boundary)",
  "here the illustrative `terrain = AbstractTerrainField`",
  "Flight.jl's threading of",
]
json.dump({"claims": C, "added": added}, open(os.path.join(H, "inventory.json"), "w"), ensure_ascii=False, indent=1)
