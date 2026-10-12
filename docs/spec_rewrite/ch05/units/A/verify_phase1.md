# Unit A verify, phase 1 (blind read of new.md)

Opening
- V1 This chapter fixes two output stages per component.
- V2 It fixes what each stage may see.
- V3 It fixes how those signatures alone yield a static execution order.
- V4 The build derives that order from declared feedthrough.
- V5 The build rejects algebraic loops by naming the cycle.
- V6 Roadmap: 5.1 ordering problem; 5.2 two output stages, signatures, bundles, hand-off laws; 5.3 stage roles, execution order, step boundaries; 5.4 artificial loops and escape hatch; 5.5 policy rejecting algebraic loops at build time; 5.6 diagnostics through feedthrough tracing.

5.1
- V7 At every evaluation instant all signals must be computed consistently.
- V8 Every consumer reads values already produced at that instant.
- V9 The build constructs the directed graph of wiring edges and intra-component feedthrough relations (def: instantaneous input->output dependences).
- V10 If acyclic, a topological sort yields a static execution order (def: order in which stage functions run), computed once at build time [D-048].
- V11 A cyclic graph is the subject of 5.5 (pointer).
- V12 The hot loop runs a flat list of (component, stage) pairs, no runtime graph logic [D-086].

5.2
- V13 (bold) Every component provides exactly two output stages [D-006].
- V14 Feedthrough declared structurally, by function signature.
- V15 No dependency annotations anywhere in the design [D-006].
- V16 Code block: continuous y_state views x,m,t[,ws], no-feedthrough stage; y_direct x,m,u,y_x,t[,ws]; x_deriv x,m,y,u,t[,ws]. Discrete: same two stage names; y_state s,t,dt[,ws]; y_direct s,u,y_s,t,dt[,ws]; s_update s,y,u,t,dt[,ws]. Every output stage returns its port NamedTuple. Event system continuous side only, same fresh table, same state views: guard x,m,y,u,t[,ws] returns Bool or scalar sign (2.1); handler returns (;x,m), keys by return law (9.5); x_projection(comp,x) manifold projection, positional.
- V17 Transition: the laws fix how a function receives args, where each view comes from, which names it receives, what an output stage returns, what a handler returns. (Roadmap of the laws; the last two not covered in this unit.)
Hand-off
- V18 (bold) Every function receives exactly two arguments, component and one NamedTuple bundle of zero-copy views [D-074].
- V19 Author destructures by name only what body reads; examples LowPassFilter x_deriv (;x,u), PID y_direct (;s,u,dt).
- V20 Executor (def: compiled form of the stage execution order) therefore issues one fixed call shape fn(comp,args). Causal: two-arg rule -> one call shape.
- V21 Language semantics ignore unread fields.
- V22 Argument order cannot be confused, because there is no order.
- V23 Positional, kwarg_decl-reflected and slurping-keyword spellings all closed [D-074].
- V24 kwarg_decl spelling: keyword args whose names framework reads via Base.kwarg_decl (Julia internal).
- V25 Slurp spelling: keyword args ending with `_...` slurp.
- V26 (bold) x_projection alone stays positional [D-074].
- V27 It takes one store in and returns same store out, so nothing to select.
Views
- V28 Each bundle field is a view of one of five sources.
- V29 Own state: continuous tier (def: continuous side of hybrid formalism), x from flat buffer, m from mode stores; discrete tier s from its store.
- V30 Own published signals: y gathered from component's own cells in signal table (declared ports, 8.2).
- V31 Inputs: u gathered from foreign cells through wiring, by name.
- V32 Clock: t and dt (10.5).
- V33 Scratch: ws (7.3).
- V34 (bold) Signal table holds only produced signals, never transported [D-035].
- V35 Each datum has exactly one home: buffer x, s/m stores s and m, table signals.
- V36 No store mirrors another.
- V37 Every bundle field earns its place as a view genuinely readable.
- V38 No minimization of the set survives without introducing a copy [D-035].
