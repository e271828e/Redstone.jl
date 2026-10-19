exec(open('tmp/ledger.py').read())
F(83)
C("Making the model coherent is the job of boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate), §14.5.",
  new="Making the model coherent is the job of boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate), which §14.5 specifies.",
  note="colon in the gloss goes; the citation leaves the gloss; stays the section's last sentence (M3)")

# §14.5
C("### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions")
C("`apply!` establishes the stores at `t₀`.", note="store linked at its first use")
C("The init service then completes the §10.6 macro-sequence with an empty integrate.",
  new="The init service then completes the §10.6 macro-sequence with an empty integrate (D-067).",
  tag="R", ruling="R7", newcites="§10.6 D-067",
  note="bold headline of D-067's Position, 'Boundary zero is the §10.6 macro-sequence run with an empty integrate'; §10.6 6646 states it plain and points here. Not in R7's list for §14.5: see rulings, open questions")
C("The sequence is", new="The sequence is the following.", note="the inline sequence becomes a display, as in §10.6 6642-6644")
C("project → [sweep → guards → handlers]\\ → due `s_update` calls → first snapshot.",
  new="> project → [sweep → guards → handlers]\\ → due `s_update` calls → first snapshot")
F(88)
C("The parity with an ordinary boundary is exact, not approximate.", note="boundary linked here, since the old link sat inside 'boundary zero' (F4)")
C("The pieces follow one by one.",
  new="The pieces follow one by one, in run order. Projection, the sweep, events and the due `s_update` calls come first, then the `t₀` argument, then what boundary zero (the initialization boundary at `t₀`) means for trim.",
  tag="X",
  note="the context's parts sentence (survey part C); boundary zero linked and glossed at its first prose use (late link fixed, F4), gloss from #g-boundary-zero")
for i in range(91, 109): F(i)
C("The prior rule grounds that timing (§10.6).",
  new="The prior rule grounds that timing (§10.6, D-292).",
  tag="C", newcites="§10.6 D-292",
  note="D-292 bullet 1: 'Boundary zero sets every prior to not-holding, so an authored condition whose guard holds fires at t₀'; plain, §10.6 6487 bolds it (O7)")
F(110, note="the late boundary-zero link moves to the section's first prose use (F4)")
C("Suppressing those firings was rejected (D-067), on the stage-on-interaction lesson of §11.7 (widgets stage on edit or activation, never per render pass). Insurance that masks invariant violations is anti-diagnostic (D-026).",
  new="Suppressing those firings was rejected (D-067), on the lesson of the stage-on-interaction rule (§11.7). That lesson is that insurance masking invariant violations is anti-diagnostic (D-026).",
  tag="R", ruling="R9",
  note="F14: the gloss describing the parked GUI's widgets goes, and the lesson is stated as the insurance rule (§11.7 8337-8340, D-026)")
F(113)
C("Replay restores it and runs no boundary zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice (§12.7).",
  new="Replay restores it and runs no boundary zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice (§12.7, D-274).",
  tag="C", newcites="§12.7 D-274",
  note="D-274 bullet 3, 'runs no boundary zero', and bullet 4, 'Replay restores it'. F4: the wrong #g-boundary link inside 'boundary zero' goes")
F(115); F(116); F(117)
C("The request simply holds in the published `t₀` snapshot and the loop reacts (§13.5).",
  new="The request simply holds in the published `t₀` snapshot and the loop reacts (§13.5, D-413).",
  tag="C", newcites="§13.5 D-413",
  note="D-413 bullet 1: 'After init! that snapshot is boundary zero's, so an authored condition already terminal ends the run at t₀'")
F(119, note="list label goes plain (R7)"); F(120); F(121)
C("A boundary's `s_update` is the outgoing transition.",
  new="A boundary's `s_update` is the outgoing transition (D-067).",
  tag="R", ruling="R7", newcites="D-067",
  note="bold headline of D-067 bullet 1, 'a boundary's update is the outgoing transition', citation now in the sentence (q4)")
F(123); F(124)
C("Boundary zero is missing its incoming transitions on both tiers, and authorship replaces both.",
  new="Boundary zero is missing its incoming transitions on both tiers (the continuous and discrete sides of the hybrid formalism), and authorship replaces both.",
  note="tier linked and glossed at its first use, from the table header (late link fixed), gloss from #g-tier")
C("| tier | `t₋₁` | `t₀` (boundary zero) | `t₁` | |---|---|---|---| | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` | | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \\to t_0 + h$ | |",
  note="carried verbatim with its two-space indent; the header's tier link moves to the prose first use")
C("The outgoing work all runs, and `t₀`'s `s_update` has its only opportunity.")
for i in range(127, 132): F(i)
C("- `t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component.",
  new="- `t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component (D-067).",
  tag="R", ruling="R7", newcites="D-067",
  note="bold lead-in becomes the bold headline of D-067 bullet 2, 't₀ is an init-service argument anchoring the harmonic grid'; Rejected 't₀ as a condition entry: time is not a store'")
F(133)
C("Both init-service entry points carry the argument, with the same default.",
  new="Both init-service entry points carry the argument, with the same default (D-110).",
  tag="R", ruling="R7", newcites="D-110",
  note="D-110's bold home is §14.5 (R7). Position: 'trim! gains the init-service t0 argument ... default 0.0 matching init! (one rule for both entry points)'")
C("They are `init!(model, condition; t0)`, which the simulation's `init!(sim, condition; t0)` forwards to, and `trim!`'s commit (§14.8, D-319).",
  new="They are `init!(model, condition; t0)` and `trim!`'s commit (§14.8, D-319). The simulation's `init!(sim, condition; t0)` wraps the model's, resolving the condition and opening the run before the model's method writes.",
  tag="R", ruling="R9",
  note="F27 (src/sim.jl 591-607); 'door' avoided for the model's init!, which opens no run (R13)")
C("`trim!(model, problem; baseline, t0, backend)` commits through the model's `init!`, and `trim!(sim, problem; baseline, t0, backend)` through the simulation's.",
  new="Each form of `trim!` commits through the matching `init!`, the model's or the simulation's (§14.8).",
  tag="R", ruling="R6", newcites="§14.8",
  note="R6: §14.8 keeps trim!'s signature (units/F/old.md, 'The backend seam'); §14.5 keeps which init! each form commits through, with a pointer")
for i in range(137, 140): F(i)
C("- Trim is untouched by all of this.",
  new="- Trim is untouched by all of this (D-067).",
  tag="R", ruling="R7", newcites="D-067",
  note="D-067 bullet 3 bold once, on row 200 (R7): 'Trim iterations bypass boundaries entirely ... only the commit runs boundary zero'")
F(141); F(142)
F(143, note="bold lead-in goes plain: D-067 bullet 3's one bold sits on 'Trim is untouched' (R7)")
C("Today's hand-written trim asserts (`!stall`, no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`.",
  new="The hand-written trim asserts of Flight.jl's Cessna 172 models (no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`.",
  tag="R", ruling="R32",
  note="R32: `!stall` goes, since c172s.jl 244 sets stall = false and asserts nothing of it. R12: owner checked: ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172s/c172s.jl 256-257 and c172x/c172x.jl 317-318 (the weight-on-wheels and ω_idle asserts after f_init!); see rulings on !stall")
F(145); F(146)
C("The channel that says it is the trim report (§14.8).",
  new="The channel that says it is the trim report (§14.8, D-126).",
  tag="R", ruling="R7", newcites="§14.8 D-126",
  note="bold headline of D-126's one ruling, 'Events firing at trim's boundary zero get a channel, the TrimReport carries the fired set'; first in reading order, §14.8 points (R7)")
C("- A commit-fired handler is not the only mover, and the second one is unconditional.",
  new="- A commit-fired handler is not the only mover, and the second one is unconditional (D-155).",
  tag="R", ruling="R7", newcites="D-155",
  note="bold lead-in becomes the bold headline clause of D-155's first ruling, 'Projection is named the second legitimate mover of the committed point'; §14.8 bolds TrimCommitResiduals (unit G)")
for i in range(149, 154): F(i)

# §14.6
C("### 14.6 Root-input totality: the missing-value error and the `override` combinator")
C("Root inputs are the one initialized datum without declared defaults.")
C("That is the bare-types decision (§11.3), upheld here (D-068).",
  new="That is the bare-types decision (§11.3), upheld here (D-068, D-376).",
  tag="C", newcites="§11.3 D-068 D-376",
  note="D-376 Position: 'The services own root-input initial values. Neither export entries nor face declarations carry root-input defaults'; §11.3 7326 bolds it")
C("So a root input's only source before boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate) is the condition.",
  new="So a root input's only source before boundary zero is the condition (the path-addressed sparse overlay that sets a build's state). Boundary zero is the initialization boundary, the ordinary macro-sequence with an empty integrate.",
  note="condition linked and glossed at its first use (late link fixed); the boundary-zero gloss becomes its own sentence, one parenthetical per sentence; the gloss is #g-boundary-zero's")
C("Three consequences follow.",
  new="Three consequences follow. They are the totality check, the probe-value barrier, and baselines layered by `override`.",
  tag="X", note="the parts sentence names the three in order")
C("Totality is a precondition of starting, checked by the service.",
  new="Totality is a precondition of starting, checked by the service (D-068).",
  tag="R", ruling="R7", newcites="D-068",
  note="bold headline of D-068's Position sentence, 'Slot totality is enforced at the service', its citation now in the sentence")
F(159); F(160); F(161)
C("It is a property of every application that establishes a complete world over virgin stores.",
  new="Totality is a property of every application that establishes a complete world over virgin stores (D-149).",
  tag="R", ruling="R7", newcites="D-149",
  note="D-149's bold home is §14.6 (R7); Position: 'Slot totality is checked at every application that establishes a complete world over virgin stores'. 'It' becomes 'Totality' so the bold clause stands alone. §9.3 4690 bolds it too")
F(163)
C("They are `init!`, trim's setup application to freshly allocated scratch stores, and trim's commit through boundary zero (§14.8).",
  new="They are `init!`, trim's setup application to freshly allocated scratch stores, trim's commit through boundary zero (§14.8), and linearization's operating condition under `about`, applied to its own scratch (§14.10).",
  tag="R", ruling="R3", newcites="§14.8 §14.10",
  note="R3, F2's dictated wording (src/linearize.jl 172-181); the wrong #g-boundary link inside 'boundary zero' goes (F4)")
C(S[165], new="That is one group of sites, one mechanism and one kind.", tag="R", ruling="R33", note="R33: class is reserved; the count stays")
F(166)
C("A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, a §13.2 kind) naming every uncovered face.",
  new="A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, Appendix C) naming every uncovered face.",
  tag="R", ruling="R9", newcites="Appendix C", note="F24: the kind's owning section is §14.6 (Appendix C 13659); §13.2 is the diagnostic value")
for i in range(168, 172): F(i)
C("The probe-value barrier is structural.",
  new="The probe-value barrier is structural (D-068).",
  tag="R", ruling="R7", newcites="D-068",
  note="bold headline of D-068 bullet 1, 'probe_value is structurally unreachable from the services path'")
C("The `probe_value` synthesis (§9.3; zero/false/first-enum/`T()`) exists so build-time probes can exercise code with fabricated inputs.",
  new="The `probe_value` synthesis (zero, false, the first enum value or `T()`) exists so build-time probes can exercise code with fabricated inputs (§9.3).",
  note="the citation leaves the gloss's parentheses; the slashed list spelled out")
for i in range(174, 179): F(i)
C("The trace header holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction (the requirement discharged, §11.3).",
  new="The trace header holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction. That discharges the requirement (§11.3).",
  note="the citation leaves the parentheses")
C("Baselines are aircraft-shipped condition functions, layered by `override`.",
  new="Baselines are aircraft-shipped condition functions, layered by `override` (D-068).",
  tag="R", ruling="R7", newcites="D-068",
  note="bold narrowed to the headline of D-068 bullet 2, 'Baselines are aircraft-shipped full-coverage condition functions'; 'layered by override' is bullet 3's, bold below. condition stays unlinked, linked in the context")
F(181)
C("Today `SystemsInitializer`'s `@kwdef` defaults carry that load.",
  new="In Flight.jl the `@kwdef` defaults of `SystemsInitializer`, the systems initializer of its Cessna 172 model (`c172.jl`), carry that load.",
  tag="R", ruling="R12",
  note="owner checked: ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 768, '@kwdef struct SystemsInitializer'")
F(183); F(184)
C("The collision is the intent. Hence the fourth node kind, `override(base, patch)`.",
  new="The collision is the intent, and the fourth node type, `override(base, patch)`, exists for it (D-068).",
  tag="R", ruling="R38", newcites="D-068",
  note="R38: node kind becomes node type, kind being reserved. R7: the bold term becomes the bold headline of D-068 bullet 3, 'override(base, patch) is admitted as the fourth node kind'; 'Hence' goes so the rule is not a consequence; override linked at its first prose use, no gloss (the next sentences define it)")
C("It is ordered and asymmetric, where `combine` is symmetric and collision-intolerant.", note="combine linked at its first use")
C("At resolution a leaf present in both takes the patch's value, with the origin recording both layers (\"patch overrode base's `throttle`\").",
  new="At resolution a leaf present in both takes the patch's value, and the origin names both layers.",
  tag="R", ruling="R9", note="F25: the quoted origin is not the code's spelling (src/conditions.jl 219-229), so the quote goes")
for i in range(189, 192): F(i)
C("The committed condition is `override(baseline, solution)`, the solver's handful of values over full coverage (D-068).",
  new="The committed condition is `override(baseline, condition(d))`, the solved condition over full coverage (D-068).",
  tag="R", ruling="R9", note="F25: the commit is override(baseline, condition(d*)) (src/trim.jl 425-426; §14.9 12379); norm drops the asterisk")
