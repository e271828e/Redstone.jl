# Unit D, phase 1 (blind assertion list from new.md)

V1. Guards (declared functions defining each event's predicate) and handlers read the same fresh world. [glossary g-guard]
V2. At each step boundary the framework integrates, projects, runs the boundary sweep, evaluates all guards once against that sweep, and fires the eligible events.
V3. The boundary sweep is the full pass that refreshes the signal table, with the boundary's due discrete ticks gated in. [g-sweep]
V4. So at guard and handler time `y` is a fresh decode of exactly the state being transformed.
V5. At guard/handler time the state views are that state itself.
V6. Handlers construct their `x`/`m` returns from raw state naturally.
V7. A reset map is `(; x = (; x..., ω = 0.0))`, with no reassembly from published fields.
V8. Each firing is `handler → x_projection`.
V9. The sweep → guards → handlers phase iterates to quiescence. [D-020]
V10. Quiescence is the fixed point where a round of handlers fires nothing. [g-quiescence]
V11. Newly enabled guards fire within the same boundary. [D-020]
V12. Blockquote: integrate → project → [ sweep → guards → handlers ] iterated to quiescence.
V13. (bold) `x_projection` runs between a state write and its decode. [D-016]
V14. That is after integration and after any handler `x`-reset. [D-016]
V15. Those are the only positions in the execution order where no fresh `y` of the new state can exist yet.
V16. The execution order is the order in which stage functions run, fixed at build time. [g-execution-order]
V17. `x_projection` is not unique in receiving raw state; every function gets state views.
V18. `x_projection` is unique in its position in the execution order.
V19. The signal table is written only by sweeps. [§10.6, D-154]
V20. So a transition reaches the table at the next round's re-sweep. [§10.6, D-154]
V21. The round that detects quiescence leaves the table post-transition-consistent for whatever else the boundary does, such as discrete ticks and logging.
V22. Ticks are the instants at which a discrete component's stages and update run. [g-tick]
V23. Under the epoch rule, a handler executes against exactly the world its guard fired on. [§10.6, D-154]
V24. Own `y`, foreign `u` and own `x`/`m` all come from the firing round's sweep.
V25. So `y = h(x)` holds at every handler entry.
V26. §10.6 settles the iteration itself, how far it runs, and how often each event may fire under the firing budget. [§10.6]
V27. The firing budget is the per-boundary cap on how often each event fires. [g-firing-budget]
V28. Two rules from §10.6 matter here.
V29. Within a round each component fires at most one event. [§10.6, D-154]
V30. Declaration order picks among a component's simultaneously eligible events. [D-154]
V31. Same-component sequential composition happens across rounds.
V32. Each later event is re-decided against the post-transition sweep rather than fired on a stale premise.
V33. A supervisor sits one level above a set of compensators; it schedules their gains and resets them on mode transitions.
V34. Gain scheduling and resets are both ordinary signal flow here.
V35. Because the rules for stores and views admit neither parameter mutation nor hand-ordered resets.
V36. Stores are the framework-owned homes of a component's state letters. [g-store]
V37. (bold) Scheduled gains are inputs. [D-089]
V38. A scheduler component owns lookup tables as inert parameters, reads scheduling variables as inputs, publishes one gain bundle per compensator.
V39. Compensators consume gains as `u`.
V40. Ports expose what mutation would hide.
V41. Gain trajectories are observable in log, trace and replay; a parameter write would be invisible to all three.
V42. Replay is the session's recorded inputs, and the loop re-driven from them. [g-replay]; trace [g-trace]
V43. The feedthrough graph carries the dependency.
V44. Linearization holds unseeded gain inputs constant with no special casing. [§14.10]
V45. One-shot design-time gains (e.g. a controller synthesized at init) are construction-time parameters or stopped-sim service outputs. [D-089]
V46. They are not a runtime write path. [D-089]
V47. (bold) A commanded reset of a discrete component is a same-tick input, consumed in the output stage. [D-089]
V48. The supervisor publishes `engage` and the latch value from its own feedthrough stage.
V49. The compensator sits topologically after the supervisor and honors them this tick.
V50. Code block: `PI` y_direct and s_update using `engage`/`u_latch`.
V51. Honoring the reset only in `s_update` is legal. [D-089]
V52. It means something else. [D-089]
V53. The state still lands correctly at the next tick.
V54. But the output at the engagement tick was already published from the stale state during the sweep.
V55. Zero-order hold keeps a discrete component's outputs constant between its ticks. [§10.5]
V56. Under ZOH the plant integrates a full step under that stale command. [§10.5]
V57. That one-tick-late command is exactly the bump bumpless transfer exists to remove.
V58. No diagnostic can catch the bump, because both spellings are meaningful designs.
V59. The update stage cannot rescue its own boundary, because republishing from `s⁺` is rejected. [D-067]
V60. The output stage is therefore the only same-tick path.
V61. Appendix A carries this as the same-tick reset entry. [§A]
V62. The bumpless-engage answer of the C172X demo's Mode engage frame presupposes exactly this spelling.
V63. The C172X demo is the interactive Flight.jl demo that section 3 of companions/flight_case_studies.md examines.
V64. (bold) A continuous component's reset is an event. [D-141]
V65. The continuous tier admits no input spelling at all, because only handlers write `x`. [§3.1]
V66. A commanded reset of continuous state, whose condition arrives as an ordinary `Bool` input, is therefore an edge-triggered event owned by the reset component.
V67. A landing gear's friction regulator, re-initialized at touchdown by weight-on-wheels, is the canonical case. [D-141]
V68. The gear wires `strut.wow → frc.reset`, so the reset fires on the touchdown edge.
V69. A flag-gated reset face on a library PI block is sugar over exactly that event.
V70. A face is the name a port wears on its component. [g-face]
V71. Appendix A carries the continuous-reset contract too. [§A]
