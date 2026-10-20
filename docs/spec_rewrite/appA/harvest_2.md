# Harvest 2: the ten companions

Agent 2's return, verbatim. Sources: the ten companions the brief lists.
Spec line numbers refer to the frozen spec at `e2b7393`.

I read all ten companions, the frozen Appendix A, and the owning spec sections. I grepped Appendix C (13564–14018) for every candidate. Decision entries cited were read in full: D-019, D-262, D-266, D-290 with its annotations, and D-348. Nothing was edited or written.

### **`Δt` arrives, never stored**
Group: component authors
Owning section(s): §10.5 ("`Δt` in the bundle"); D-019
Spec sentence: "An author must never store `Δt`, or any `Δt`-derived coefficient, as a component parameter ([D-019][d-019])." (line 6368). Also: "Under scoped multipliers a component author *cannot* know their absolute rate. It does not exist until composition." (6374–6375)
Recall line: A discrete law reads its period from the bundle's `Δt` and derives its coefficients from it at every tick. A period or coefficient fixed at construction presupposes a deployment the instance has never seen, so the law silently runs at the wrong rate.
Goes wrong without it: Matrices designed at one sample time run at another. A forward-Euler filter goes unstable when `Δt > 2τd`, and "nothing complains, since the period is unknown at construction". No kind fires, because neither the constructor nor the structure step can compare the two.
Source: linear_blocks.md:354–360, 391–397; pid_anti_windup.md:379–402
Status: new

### **A release predicate excludes equality**
Group: component authors
Owning section(s): §10.4 ("Detection policy"); D-290 (annotation 2026-10-07)
Spec sentence: "A release predicate, "the input points back into the range", does not hold at an input of exactly zero, but the sign form `-u` alone holds there, since `-0.0 ≥ 0`. Gate on the strict comparison instead, `u < 0 ? -u : -one(u)`." (5754–5758)
Recall line: A predicate that latches a mode when one quantity reaches a level holds at equality. The predicate that releases it must not. Freeing the mode at the rest point leaves the latching predicate holding with no edge, so it never fires again. Gate the release on the strict comparison, or write it as the `Bool` form, which is strict by construction.
Goes wrong without it: A `LimitedIntegrator` fed exactly `0.0` at its limit frees on the limit. It then integrates through the limit to 1.45 against a bound of 0.5. The same thing happens at boundary zero for an `x0` on the limit. No check fires: the edge semantics work as specified, and the budgets never trip.
Source: limited_integrator_variants.md:50–69, 94–102, 247–254
Status: amends "Guard predicates, edges and priors"

### **Checks test the condition's beliefs about the world**
Group: service users
Owning section(s): §14.7 ("Residuals and checks"), §14.8; D-262, D-139
Spec sentence: "If the two disagree, the residuals vanish at a true equilibrium that is not the requested point, and nothing in the residual system can tell ([D-139][d-139])." (12122–12124)
Recall line: Residuals only ask that the derivatives vanish, not where. When the condition math uses its own copy of anything the world owns, such as density or wind, declare a check that reads the world's value or the target back at the committed state. Without one, a stale copy converges to a real equilibrium at the wrong point.
Goes wrong without it: A zero-wind `params` against a 10-knot headwind baseline trims at EAS ≈ 60 and reports it as 50. `TrimCommitChecks` fires only for checks the author wrote. With none declared, nothing fires.
Source: trim_environment_walkthrough.md:448–471, 613–621, 809–826
Status: new

### **`linearize` holds the discrete tier**
Group: service users
Owning section(s): §14.10 ("Seeded and frozen leaves", "The sampled-data extension"), §8.2
Spec sentence: "The discrete tier is frozen with zero partials, which is precisely "linearize with the discrete state held" ([§8.2][s8-2])." (12783–12784). Also: "A frozen discrete output is a constant with zero partials." (2832–2833)
Recall line: Linearization differentiates the continuous dynamics with every discrete output held at its operating-point value. A loop closed through discrete controllers is therefore absent from `A`. The result is the plant with its commands held, not the closed loop.
Goes wrong without it: An author linearizes a cascade of `DiscretePID`s expecting closed-loop poles and gets the open-loop plant. A `TapResolution` fires only for an `x` tap on a discrete store or a `u` tap on a root input a discrete consumer reads. Tapping only plant states and faces is legal and silent.
Source: linearization_walkthrough.md:306–317, 603–610; lqr_tracker.md:236–241
Status: new

### **Stripping partials declares a zero coupling**
Group: component authors
Owning section(s): §13.7 (`Freeze`), §14.10 ("Declared non-participation"), §9.5 ("Deliberate stripping"); D-266
Spec sentence: "What the wire then declares is a zero coupling in every Jacobian along that path ([D-266][d-266]), … Where the coupling matters to the Jacobian, the local rule ([§14.10][s14-10]) is the answer, not this block." (11071–11077). Also: "A component that must participate keeps its input entry tolerant and supplies its own local derivative inside the stage" (12905–12907)
Recall line: `Freeze`, or `ForwardDiff.value` mid-expression, is a modeling decision. Every Jacobian then reads a zero along that path. A sampler is no substitute, because it changes the model. If the coupling matters, as for an opaque table, keep the entry tolerant and chain a local derivative instead.
Goes wrong without it: An AD-opaque table or a severed schedule shows up as zero rows or columns, which read as "no effect". The spec says the lint that would name a severed coupling is recorded, not built (12934–12939). Stripping at an unpinned leaf "remains unseen" (5023–5024).
Source: handle_walk_walkthrough.md:175–196, 200–227; pid_anti_windup.md:490–493; lqr_tracker.md:178–184
Status: new

### **A unit delay is a modeling decision**
Group: component authors
Owning section(s): §5.5, §13.7 (`UnitDelay`); D-348
Spec sentence: "Inserting a `UnitDelay` into a *continuous* loop moves that signal onto the discrete tier and inserts a [`Δt_base`]-scale zero-order hold into the model's mathematics" (11011–11013)
Recall line: Breaking a cycle with a `UnitDelay` is not a transparent wire. The signal is now sampled, held between ticks and one tick old. Use one only where that delay is the intended semantics, as for a standby controller tracking the selected command.
Goes wrong without it: The cycle refusal goes away, but the model's mathematics has changed. `AlgebraicCycle`'s message states the caveat when it offers the remedy. Once the delay is wired, nothing flags it.
Source: lqr_tracker.md:268–276, 297–303; pid_anti_windup.md:598–602
Status: new

## No home

- **A switch on a continuous quantity is an undeclared mode.** A derivative branch such as conditional integration that reads a continuous signal switches inside a step. A jump in `ẋ` then costs O(h) and leaves `q` past its level. Switch on a moded block's code, which flips on a declared boundary, or declare the event. The companions attribute this to §2.3 and to a junction docstring, but no spec sentence states it. §10.2's claim 2 (5638–5642) is only about smoothness and high order. Source: pid_anti_windup.md:51–56, 108–117, 337–339; lqr_tracker.md:221–223.
- **A hit guard stays ungated.** If the hit guard is gated on `:free`, it reads `q − upper = 0` the moment a leave handler frees the mode. That edge re-saturates the block at once. §10.4 covers only the release half. Source: limited_integrator_variants.md:40–46.
- **A discrete law must be stable at every period.** The period is unknown at construction. The PID therefore uses backward Euler on its filter and the exact factor `β = −expm1(−Δt/Tt)`. The spec has the no-stored-`Δt` rule but not the stability obligation. Source: pid_anti_windup.md:379–402.
- **A scheduled gain fed from seeded state carries partials into `A`.** To freeze it at nominal, route it through `Freeze`. The spec's "Linearization holds unseeded gain inputs constant with no special casing" (1392–1393) can be read as saying the opposite for a gain computed from state. The owner may want that sentence clarified. Source: pid_anti_windup.md:490–493; lqr_tracker.md:181–184.
- **A check on a quantity the condition writes directly is always zero.** Only quantities with an independent source in the world earn a check. Source: trim_environment_walkthrough.md:794–800.
- **A plant-only trim leaves controller stores at their defaults.** The spec states the base rule, "The overlay base is always the declared defaults" (11353). It does not state the closed-loop consequence: a closed loop started from that trim is not at rest until each integrator is seeded with the trim value it commands. Source: longitudinal_aircraft.md:197–219.

## Rejected

- A method's existence declares the stage, so generic forwarding declares both stages (linear_blocks.md:230–248). Fails test 1: the wrong feedthrough class surfaces as `UserCodeFraming`, `ProducedByTwoStages` or `AlgebraicCycle`, not as a wrong model. The "stage funnel" entry also covers it.
- Stage-2 conservatism: an input read only by `x_deriv` is still a feedthrough edge (pid_anti_windup.md:91–106). Fails test 2: `AlgebraicCycle` fires.
- A handle's pin propagates down a forwarding chain; tying a handle's type parameter to another argument; `Float64` buffers or casts (handle_walk_walkthrough.md:128–159). Fails test 2: loud at the `Dual` probe or the identity rule.
- Pinning a leaf that really walks (handle_walk_walkthrough.md:52–56). Fails test 2: the spec says it "lurks, but is never silent" (2858). The silent variant is deliberate stripping, kept under the fifth candidate.
- A problem that writes the environment (trim_environment_walkthrough.md:332–337). Fails test 2: resolution fails by name.
- Folding trim targets into residuals. Design rationale (D-262 Rejected), not an author contract.
- Abstract `SMatrix` fields box and allocate (linear_blocks.md:139–149). Fails test 1: a performance cost, not a wrong model.
- `TransferFunction` takes `u0`, not `x0`; the `z = 1` pole test needs a tolerance; Tustin was rejected (linear_blocks.md:151–186, 362–367, 411–427). Library API and docstring facts, not framework contracts.
- PID and LQR tracker standby with the error gated off, the one-tick-stale `saturated` code, and choosing `Tt` (pid_anti_windup.md §§3, 11; lqr_tracker.md §§6–7). Library design with no framework spec sentence.
- A drain-caused guard edge fires at the frame-top boundary, not localized (frame_walkthrough.md:54–62, 125–140). Design mechanics with no author consequence.
- Discrete cells hold through trials, a zero-order hold by absence (frame_walkthrough.md:106–108). Already covered by "Boundary sampling".
- A localized touchdown versus a `Junction` on `h ≤ 0` (longitudinal_aircraft.md:295–305). Already covered by "Stop-request sampling".
- The two world shapes and elimination versus enlargement (trim_environment_walkthrough.md). The user picks the posing. Only the checks lesson survives, as the third candidate.
- fused_evaluation_lineage.md. History and orientation only.
