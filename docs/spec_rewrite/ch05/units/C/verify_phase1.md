# Unit C verify, phase 1 (blind assertion list from new.md)

Opening
V1. §5.2 fixes the two-stage surface and its laws. [§5.2]
V2. A stage's role has two halves: what its name asserts and what it may see.
V3. (pointer) section order: names, visibility, why derivatives may read outputs, execution order, step boundary, two supervisory inputs (scheduled gains, commanded resets).
V4. A boundary is a published consistency point (gloss).

Names
V5. Math symbols and API names are two vocabularies, deliberately. [D-220] (bold)
V6. Formulas keep symbols of their source traditions.
V7. `f` is the continuous flow (derivative function); `g` the discrete update; flow/jump pair from hybrid systems (Goebel-Sanfelice-Teel).
V8. Output map is `h` in y = h(x,u), the control/estimation convention, as in every navigation filter's measurement function.
V9. API spells the same objects as words so that a name bound in an author's own module is unambiguous evidence of a forgotten import. [D-220]
V10. Correspondence is one to one; table f->x_deriv, g->s_update, h(x)->y_state, h(x,u)->y_direct.
V11. A stage's name states the dependence class, not the argument list. [D-220] (bold)
V12. y_state is y=h(x) case; y_direct is y=h(x,u) case.
V13. "no direct in the name" is the no-feedthrough property, visible at every definition site; feedthrough = instantaneous input->output dependence.
V14. Names are deliberately non-exhaustive. [D-075]
V15. Modes fold under state; m is state; name states feedthrough split rather than argument inventory. [D-075]
V16. Ambient facts (t, Δt) and scratch (ws) ride unnamed.
V17. Update law carries the tier in its name (x_deriv vs s_update); tier = continuous or discrete side.
V18. The two output stages do not carry tier; one pair of names serves both tiers over each tier's state letter. [D-220]
V19. A stateful leaf's declarations must agree on one tier throughout. [§8.2, D-112]
V20. Mixing update laws, or store of one tier with update law of other, is a build error DeclarationOnWrongTier.

Visibility
V21. y_state is the no-feedthrough stage, defined entirely by what it cannot see. [D-035] (bold)
V22. Its bundle (NamedTuple of zero-copy views) carries no u, so no feedthrough cannot be violated by construction.
V23. That structural guarantee is what stage-1 ports contribute to the feedthrough graph; port gloss = addressable units, one declared name each.
V24. Stage-1 ports break would-be loops.
V25. Stage 1 exists when component has state-derived ports, including any state-derived intermediate a later function reads [§5.2]; otherwise absent.
V26. An empty stage is unwritable on purpose; stage with no port is DeadStage error of §5.2.
V27. A declared output is produced by stage 1 or stage 2 and nothing else. [D-252, §8.3]
V28. A component exposes a state or mode field by returning it from y_state. [D-252] (bold)
V29. The line is one method `y_state(c, b) = (; q = b.x.q)`.
V30. A declared output no stage produces is DeclaredNotProduced [§8.3], at every tier and every level of the tree.
V31. y_direct receives all wired inputs plus the stage-1 hand-down. [D-006]
V32. The hand-down is the component's own stage-1 ports.
V33. A shared intermediate is therefore computed once and read; stage 1 declares it as a port and stage 2 finds it in y_x, or y_s on the discrete tier. [D-194]
V34. Stage 2 receives the state views too (zero-copy reconstructions of stores).
V35. Conservatively, every stage-2 output is presumed dependent on every wired input.
V36. x_deriv and s_update run after the sweep, when the full signal table is complete and fresh, own stage-2 ports included. [D-015] (bold)
V37. Fused idiom stands: compute each law once in a stage, publish, let x_deriv/s_update copy from y.
V38. Interfaces reward single-source-of-truth rather than making duplication unwritable. Nothing ever needs computing twice. [D-015, D-035]
V39. All output stages must be pure, no side effects. [D-015]
V40. State types make mutation impossible anyway. [§7]

Derivatives reading outputs
V41. Design departs from orthodox formalism openly.
V42. Textbook x' = f(x,u), y = h(x,u); this design's f receives orthodox args plus published table, x' = f(x,m,y,u,t).
V43. Composite map x -> x' is mathematically identical, so linearization, trim and AD untouched.
V44. Heterodox element is only that derivatives may read outputs.
V45. Teaching line quoted.
V46. Derivative/output overlap is the norm in physical and control models.
V47. Newton-Euler computes accelerations that are both published outputs and state derivatives; kinematics, engine models, gear friction, every discrete compensator show same overlap.
V48. That overlap makes the orthodox split expensive here. [D-015]
V49. f_ode!, FlightCore's fused in-place derivative function, already embodied same economics.
V50. This design keeps those economics while adding checked ordering.
V51. Shared expensive computations solved uniformly by the fused idiom: compute once in stage 2, publish, x_deriv/s_update consume ports.
V52. External consumers read the same ports, as an accelerometer model reads f_c_c (strapdown IMU example §3.4).
V53. Computer/integrator split remains fully expressible without framework support. [D-015]
V54. §7.4 carries full statement including when the factoring earns its keep.
V55. Purity rules forbid classic resolution by mutable caching, by design. [D-015]

Execution order
V56. Execution: all stage-1 in any order, then stage 2 topological, then all x_deriv against consistent table. [D-288, §9.7]
V57. Evaluating the RHS means running the sweep; RHS = the flow x_deriv.
V58. No incremental x_deriv-only re-evaluation.
V59. Nothing lost because implicit solvers, linearization, trim already work this way; they seed x and run the composite.
V60. §10.3 and §10.4 restate this as a property of the execution model.
V61. RHS evaluations and guard trial evaluations both run the interior sweep, the continuous-only variant of §10.5. [D-147]
V62. Discrete executor entries are absent from it by construction, so discrete cells hold across the step. cell gloss = typed signal-table slots, one per output port.
