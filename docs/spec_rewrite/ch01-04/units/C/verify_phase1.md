# Unit C verify, phase 1 (blind assertion list from new.md)

V1. The taxonomy has three categories of component. [D-003] (bold)
V2. Two categories are leaves with crisp, closed semantics.
V3. One category is pure composition.
V4. §3.1 describes the continuous component, §3.2 the periodic discrete component, §3.3 the assembly. (pointer)
V5. §3.4 justifies the two-leaf split. (pointer)
V6. A continuous component is a classical hybrid automaton.
V7. It has continuous state `x`, a NamedTuple whose leaves are real scalars and `SArray`s. [§7.1, D-094]
V8. It has mode variables `m`: piecewise-constant values (enums, integers, flags).
V9. Modes parametrize the flow.
V10. Modes change *only* through event handlers.
V11. Flow is ẋ = f(x, m, u, t).
V12. It has two output stages. [§5.2]
V13. Events are each a guard plus a handler; a guard is the declared function defining an event's predicate.
V14. A handler may update `m`.
V15. A handler may reset the component's own `x`. [D-090]
V16. Both guard and handler read the fresh boundary signal table. [§5.3, D-154]
V17. It has an optional projection, the per-component hook `x_projection`.
V18. Any facet may be empty.
V19. A component with no continuous state, only modes, events and mode-valued outputs, is an FSM.
V20. A single primitive supports both factorings of mode logic. [D-003] (bold)
V21. Internal modes suit tightly coupled cases, e.g. stall hysteresis inside the aero component.
V22. Internal modes preserve cohesion and enable reset maps. [D-003]
V23. An external FSM component feeding modes through a port gives maximal purity, independent testability and swappable supervision logic.
V24. A port is the addressable unit through which components exchange values. (gloss)
V25. The rule of meaning separates a command from a detection.
V26. A supervisor commanding a mode change is an ordinary input.
V27. A component detecting its own transition is an event.
V28. The two mechanisms carry two meanings and do not overlap.
V29. On the continuous tier, a commanded reset of state still arrives as an input and lands through an event whose guard reads that input. [§5.3, D-141]
V30. A periodic discrete component has discrete state `s`, a NamedTuple whose fields are each isbits or a `Symbol`. [§7.3, D-231]
V31. Update s+ = g(s, u, t) at a declared rate.
V32. Two output stages, with feedthrough applying at update instants.
V33. Feedthrough is an instantaneous input→output dependence. (gloss)
V34. A proportional path is direct feedthrough; a state-only output is not.
V35. Each tier carries its own state letter. [D-195] (bold)
V36. `x` is the argument of the flow map under `f`; `s` is the argument of the jump map under `g`.
V37. The two are different objects.
V38. `x` has a derivative and lives in the flat buffer.
V39. `s` has none and is latched in a store between ticks.
V40. A store is the framework-owned home of a state letter. (gloss)
V41. Nothing is lost by splitting the letter, because a leaf is strictly one tier [D-056] and no component ever reads another's state.
V42. A discrete component's `s` influences continuous dynamics only through signals. [D-056]
V43. Those outputs are held zero-order between ticks. [D-019]
V44. `m` is continuous-only. [D-231, D-249] (bold)
V45. A discrete component has no mode store.
V46. Its FSM enums, flags and counters are ordinary `s` fields.
V47. `m` exists on the continuous side because modes must change between flow evaluations, which is what handlers do.
V48. On the discrete side `g` already runs at the only instants at which anything may change.
V49. A second store would duplicate the discrete tier's own state semantics under another name.
V50. An assembly is pure composition.
V51. It holds child components, local wires and boundary faces (faces: the names ports wear on a component's boundary).
V52. It has no dynamics of its own.
V53. Hybridness emerges at the assembly level.
V54. An aircraft is continuous vehicle parts plus discrete avionics parts.
V55. The two-leaf split was upheld against the integrate-and-dump challenge. [§3.4, D-056]
V56. Assemblies are flattened away for ordering. [D-019]
V57. Assemblies are retained as the navigation and introspection hierarchy (GUI, logging, paths). [§10.5, D-019]
V58. Assemblies are retained as declaration-level rate scopes. [§10.5, D-019]
