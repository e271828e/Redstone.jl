# Unit C, phase 1 (blind): assertions in new.md

V1 Total wrench, total mass properties, total internal angular momentum are totals over many contributors.
V2 In Flight.jl these totals come from tree walks.
V3 FlightPhysics' generated functions `get_wr_b`, `get_mp_b`, `get_hr_b` sum each quantity over a model tree.
V4 (roadmap) The section covers the rule, the junction, what the explicit form buys, the hierarchical idiom, zero contributors, cost.
V5 [bold] N-to-1 physical aggregation is expressed by ordinary junction components and explicit wires. [D-037]
V6 There is no framework aggregation mechanism: no multi-connection ports, no declared fold ops, no identity-element opt-outs.
V7 Every input port takes exactly one connection, everywhere. [§6.1]
V8 Code: `Junction{In,Out,N,F} <: AbstractComponent`, library-provided (§13.7); field `f` the N-ary fold, instance data; `SumJunction{V,N} = Junction{V,V,N,typeof(+)}`; x_init = (;) stateless continuous, empty store is tier marker (§8.2); u_types in1..inN at In; y_types out=Out; y_direct folds u.
V9 [bold] The parameters are the nominal port types and the arity. [D-311]
V10 Example `SumJunction{Wrench{Float64}, 3}`; the fold is instance data.
V11 `Wrench` is FlightPhysics' force-and-torque type.
V12 `SumJunction{V,N}` is the Junction at `+`.
V13 A custom fold (weighted blend, mass-properties composition) is written at the site as `Junction{In,Out,N}(f)`, which infers `F`.
V14 The junction is a continuous leaf, so its contracts are written at nominal Float64.
V15 On a continuous leaf the leaf walk retypes them. [§8.2]
V16 An input entry at `Wrench{Float64}` is the tolerant form a promoting consumer writes.
V17 Walking, frozen and root-input contributors are all admissible behind it.
V18 A root input is the root component's own input face. (definition)
V19 The Bool gates of §13.7 are the same leaf at `|` and `&`. [§13.7, D-311]
V20 Junctions (summing junctions and Bool gates) are the seed of the standard component library committed in §13.7. [D-062]
V21 They are ordinary components with no framework privileges.
V22 The inventory grows by judgement against three guidelines §13.7 states. [D-313]
V23 Wired at an ownership boundary inside the assembly owning the contributors, the junction is ordinary structure.
V24 An assembly is a component of pure composition with no dynamics of its own. (definition)
V25 `Systems` is the systems assembly; its children include `aero`, `pwp`, `ldg`.
V26 `wr_sum::SumJunction{Wrench{Float64},3}` is a field of `Systems` like any other child. [§8.5]
V27 Code: local_wires(::Systems) wiring aero/pwp/ldg wrench to wr_sum/in1..3 and wr_sum/out to dynamics/wr_ext.
V28 Every mistake is loud under the declaration layer.
V29 A counted-but-unwired contributor is an unconnected-input error naming `in4`.
V30 A double-wired slot violates single-connection.
V31 A stale arity surfaces as one or the other.
V32 The bookkeeping is ceremony, never silence.
V33 A contributor's output that nobody wires stays legal and silent, as any unconnected output does. [D-084]
V34 The aggregate is a first-class signal; `"wr_sum/out"` is an ordinary port.
V35 It is loggable, GUI-visible, and fanned out to a second consumer (a structural-loads monitor) for one wire.
V36 Aggregation logic is arbitrary stage-2 code (mass-properties composition with transport terms, weighted blends), not restricted to a declared commutative-associative binary op.
V37 [bold] Fold order is author-visible. [D-037]
V38 It is the positional order of the junction's inputs.
V39 Reassigning contributors to slots changes summation order, hence bits, because float addition is not associative.
V40 The ordering is deterministic per configuration and under author control, strictly more explicit than a framework-canonical order.
V41 For the handful of real sites, a named site-specific junction documents the contributor set better than generated slots, at the price of hard-coding it into a type; example `u_types(::VehicleWrenchSum) = (aero=…, ldg=…, pwp=…)`.
V42 The generic positional form remains the tool for configuration-variable sites.
V43 Both are plain components; the framework is not involved.
V44 [bold] Each assembly that owns contributors aggregates them with an internal junction and exports the total. [D-037]
V45 The junction is a component inside the assembly; the assembly exports its `out` port. [§8.6]
V46 The §6.1 connection rules force this shape.
V47 A child is opaque to wiring at every boundary, so every contributor-owning assembly must export its aggregate.
V48 Example: `Ldg` sums its three struts and exports `wrench`; the systems assembly sums aero+ldg+pwp; the vehicle wires the systems totals into the rigid-body equations of motion.
V49 Junctions placed this way replace the tree walk.
V50 Each recursion step of FlightPhysics' tree walk becomes one visible junction at the level owning the contributors.
V51 For Flight.jl's Cessna 172 model that is about four junctions and fifteen wires, written once.
V52 They read as a manifest of what weighs, pushes and spins.
V53 Only physical contributors publish the ports a junction sums; a strut publishes `wrench`, avionics publishes nothing.
V54 Frame responsibility is as in Flight.jl: contributors publish in the common body frame, applying mounting transforms at source.
V55 Do not bundle the three quantities into one contribution struct.
V56 Contributors are ragged, each publishing only the quantities it has.
V57 A bundled struct forces zero-filled identity noise through every port, the "silently sum nothing" hazard in a new coat. [D-037]
V58 A `sum_ports!`-style helper would instantiate, wire and export in one call.
V59 [bold] Such a helper is guarded-addition sugar, added when real models show the pattern repeated. [D-037]
V60 Guarded addition = a capability the design admits but does not build. (definition)
V61 Ragged contributors bottom out at none: some configuration has a consumer whose required aggregate input has no physical contributors.
V62 `Vehicle{NoVehicleSystems}` (FlightPhysics' bare-propagation vehicle with no systems) is one.
V63 It has zero contributors to external wrench and internal angular momentum; its rigid-body dynamics component `VehicleDynamics` requires both unconditionally.
V64 There is no junction to write and no producer to wire.
V65 §6.1 bans unconnected inputs and silent defaults. [§6.1]
V66 The identity element a zero-arity junction would need is deliberately absent. [D-037]
V67 [bold] The zero-contributor spelling is a library Constant source (§13.7) wired straight to the consumer's input. [D-143] Example `Constant(Wrench())` → `dynamics/wr_ext`.
V68 A constant source has no inputs, no state, and publishes a value its instance holds.
V69 The zero total thus becomes declared structure: "external wrench ≡ 0" as a visible wire and observable port, rather than an identity method the framework supplies behind the author's back.
V70 [bold] The Constant wire is not the banned default (§6.1) in component clothing but its opposite. [D-143]
V71 That default is silent and consumer-declared; this one is loud and assembly-declared, the author writing child and wire, both inspectable.
V72 Adding a contributor from another subtree edits the assembly levels between producer and junction instead of none. [§6.1]
V73 In exchange explicit wiring buys per-contributor values and intermediate totals as observable ports, with every silence in the aggregation's bookkeeping inverted into a warning or error. [D-037]
V74 Consumer-declared folds with multi-connection legality are closed. [D-037]
