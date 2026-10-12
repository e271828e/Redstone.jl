# Unit B verify, phase 1 (blind assertions from new.md)

V1. A name appears in a component's bundle iff the corresponding store or fact exists for that component. [D-074] (bold)
V2. `x` present iff component declares non-empty `x_init` (continuous tier).
V3. `s` present iff non-empty `s_init` (discrete tier).
V4. `m` present iff non-empty `m_init`.
V5. `ws` present iff component declares `ws_init` (no "non-empty").
V6. `u` present iff the function family may see inputs AND the component declares `u_types`. (function family glossed as "which bundle fields a given function may legally receive")
V7. `y` present iff component produces any table cell at all (declares `y_types`).
V8. `y_x`/`y_s` present iff stage-1 ports exist, under the tier's own spelling.
V9. `t` always present.
V10. `Δt` present iff component is on the discrete tier.
V11. A store puts its letter in the bundle only when non-empty. [D-297]
V12. Undeclared stores are absent, never `nothing`-filled. (no citation)
V13. The stage-1 hand-down carries the stage-1 return. [D-285] (bold)
V14. `y_x` (or `y_s` on discrete tier) comes from the return of the stage-1 probe. Probe glossed as the build's single evaluation of a user function with real values.
V15. §9.3 already sources the rule. [§9.3]
V16. A component with no stage-1 ports has no `y_x`/`y_s` in its stage-2 bundle at all.
V17. Destructuring a field that does not exist for the component fails at the probe with a `BundleFieldError` diagnostic. [D-248]
V18. §13.2 describes the catch that recognizes it. [§13.2]
V19. The diagnostic carries did-you-mean (offending name + list it should have matched) against the legal field set.
V20. Example message: "`x_deriv` of `Foo` destructures `m`, but `Foo` declares no `m_init`".
V21. One law covers tier facts, stage legality and declarations alike.
V22. The mechanism is structured, not textual.
V23. Destructuring an absent field throws a `FieldError` carrying type and field name as data (Julia >= 1.12).
V24. The probe catches it matched against the bundle's own NamedTuple type.
V25. The probe synthesizes `BundleFieldError` from the legal set.
V26. It classifies the field as undeclared store, wrong-tier fact, or name illegal for this function family.
V27. No message text is scraped. 
V28. The bundle stays a bare NamedTuple. [D-074]
V29. A getproperty-wrapper spelling is the recorded fallback, should type-matched interception prove insufficient.
V30. Wrong-tier classification covers the state letters too. [D-195]
V31. `x` and `m` are continuous-only; `s` and `Δt` are discrete-only.
V32. So destructuring any of the four on the wrong tier is classified as wrong-tier fact.
V33. Per-function name sets are closed, one set per function per tier. [D-074]
V34. Update laws carry their tier in the name, so `x_deriv` and `s_update` have one set each.
V35. The two output stages are shared machinery over both tiers [D-220], so `y_state` and `y_direct` have one set per tier.
V36. Continuous: `y_state` = `x, m, t [, ws]`; `y_direct` = `x, m, u, y_x, t [, ws]`.
V37. Discrete: `y_state` = `s, t, Δt [, ws]`; `y_direct` = `s, u, y_s, t, Δt [, ws]`.
V38. Adding a name to any of them is a decision-log entry, not a convenience.
V39. Comments in the signature block above state each function's maximal legal set at each tier.
V40. A component's bundle narrows that set to declared reality; destructuring narrows further to actual reads.
V41. Three-level funnel (stage name at tier ⊇ bundle ⊇ reads) worth teaching once.
V42. Because a stateless component legitimately writes `y_direct` while owning neither `x` nor `m`.
V43. An output stage returns its port NamedTuple `y`, and nothing else. [D-194] (bold)
V44. `y` scatters into the component's declared cells as always.
V45. Every value a later function needs is one of those cells. [§8.3]
V46. Stages are discovered by method existence.
V47. Stage membership is a partition of the declared ports.
V48. Empty `y = (;)` is a `DeadStage` build error at the probe. [§9.3, D-285]
V49. A stage returning nothing computes nothing any consumer can read.
V50. That is the inert-component check [§8.1] applied to a single stage.
V51. A handler returns a NamedTuple carrying the stores it writes. [D-090] (bold)
V52. A key is present iff the store exists on the component AND the handler updates it.
V53. That is the bundle law's iff shape governing the return side.
V54. Pure FSM (modes and events, no `x`) returns `(; m = (; phase = running))`.
V55. `x`-only reset map returns `(; x = (; x..., ω = 0.0))`.
V56. A handler touching both returns both.
V57. Padding forms `((;), m⁺)` and `(x⁺, (;))` do not exist. [D-090, on argument-side ground of D-074]
V58. Return semantics are per key. [D-287]
V59. When `x` present, value is complete against the state field set.
V60. When `m` present, names-subset predicate applies. [D-090]
V61. Unknown key gets did-you-mean against `{x, m}` in a `HandlerReturnKey` diagnostic.
V62. Same `FieldError`-shaped machinery §13.2 builds for bundles, now in both directions. [§13.2, §9.5]

Glossary links: function family, cell, probe, did-you-mean. Reader-cold candidates: `FieldError`, `DeadStage`, `HandlerReturnKey`, `Foo`, FSM (glossed), "signature block above", "inert-component check".
