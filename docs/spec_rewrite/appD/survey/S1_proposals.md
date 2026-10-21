<a id="g-class"></a>**class** — a component's primitive-vs-assembly
status, read off *which* well-known declarations its type defines.
`local_wires` makes an assembly, any leaf declaration makes a primitive, and
neither is `ClassUnreadable` ([§8.5][s8-5]). Class is neither a
[tier](#g-tier) nor a diagnostic [kind](#g-kind). The "two leaf classes" of
[§3.4][s3-4] are the tiers, named in ordinary English.

<a id="g-component"></a>**component** — the unit of modeling. It is a leaf,
either a continuous or a periodic discrete component, or an assembly of
components ([§3][s3]).

<a id="g-continuous-component"></a>**continuous component** — the hybrid
primitive. Its facets are continuous state `x`, modes `m`, the flow `x_deriv`,
two output stages, events (guards with handlers) and an optional
`x_projection`. Any facet may be empty. One with modes and events but no `x`
is a finite-state machine ([§3.1][s3-1]).

<a id="g-contract"></a>**contract** — a component's declared interface.
`u_types` states its requirements, what each entry *allows* to arrive.
`y_types` states its public ports, what each cell *carries*
([§8.2][s8-2]). A name returned in `y` and declared
nowhere is a build error ([§8.3][s8-3]). The
[derived contract](#g-derived-contract) and the spec's other contracts, such
as the device authoring contract ([§11.6][s11-6]), are distinct senses.

<a id="g-declaration-inventory"></a>**declaration inventory** — the closed set
of well-known functions a component or assembly defines, each declared in a
stated source of authority, by value, by type or by allocation
([§8.2][s8-2]). The set is the import list of [§8.1][s8-1]. It holds
`x_init`/`s_init`/`m_init`, `ws_init`, `u_types`/`y_types`, `state_events`,
the stages, `x_deriv`/`s_update`/`x_projection`,
`local_wires`/`input_wires`/`output_wires`/`sample_times`/
`transparent_container`, and `stop_reason`.

<a id="g-derived-contract"></a>**derived contract** — the checkable surface an
assembly or the `Build` derives from declarations and wiring instead of
declaring it. An assembly's is its face list ([§8.6][s8-6], [§8.8][s8-8]).
The `Build`'s is its wire list, root inputs, execution order and face table
([§9.2][s9-2]). Under [generic holding](#g-generic-holding) it is the
constraint the referencing wires impose on the child ([§8.8][s8-8]).

<a id="g-hybrid-causal-system"></a>**hybrid causal system** — what the
framework simulates. It combines continuous flow with algebraic outputs,
multi-rate periodic discrete dynamics, state events under two detection
policies, post-step manifold projection and externally injected inputs
([§2][s2]).

<a id="g-local-wire"></a>**local wire** — an entry of `local_wires`, a wire
from one child's face to another's, with both ends inside the assembly's
boundary. An input wire or an output wire has one end on the boundary instead
([§6.1][s6-1], [D-303][d-303], [D-314][d-314]).

<a id="g-the-letters"></a>**the letters** — the mathematical symbols the
spec's formulas keep beside the API's words ([§5.3][s5-3], [D-220][d-220]).
`f` is `x_deriv`, `g` is `s_update`, and `y = h(x)` and `y = h(x, u)` are
`y_state` and `y_direct`. The bundle letters `x`, `m`, `s`, `u`, `y` and `ws`
are API names ([§5.2][s5-2]). Bare `h` is the integration
step ([§2.1][s2-1]). Bare `z` appears only in the shift operator `z⁻¹`,
because [D-173][d-173] retired it as a state letter.