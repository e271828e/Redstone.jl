# The frame, the base tick and the step: choosing a deployment's time quantities

*A companion explainer, not normative text. The ground truth is `spec.md`
[§9.2][s9-2] (the deployment's time quantities), [§6.3][s6-3] (rates down
the hierarchy) and [§10.5][s10-5] (spans and steps), with decisions
[D-445][d-445] and [D-449][d-449]. If this document and the spec ever
disagree, the spec wins. It was written on 2026-11-27, while the tutorial's
increment 1b was ruled, to preserve the answer to one question: when a run
needs a shorter step, does it shorten the frame or set a bound?*

## 1. What each quantity is for

A deployment fixes three time quantities, and each answers to a different
party.

**`Δt_frame` is the run's exposure to the outside.** It is the spacing of
the frame tops, and it is required. Root inputs land at a frame top, the
drain and the control read run there, and a paced run's pacer waits there.
It is also the unit `step!` counts and the trace's ordinal.

**`Δt_base` is the discrete tier's schedule.** It is the tick every
`Relative` multiplier counts. A model that declares only ratios states no
seconds, and this keyword gives them. When it is absent the base tick is the
frame.

**`h_max` is the method's.** It is the longest step the integrator may take,
under every method, and it is optional. It need divide neither period.

The three stand in no required ratio. [D-445][d-445] gives the reason: tying
any two together makes one quantity's choice constrain another's.

A step ends at every frame top and at every instant where a discrete
component is due. These are the mandatory instants, and a span runs from one
to the next. A fixed-step method takes a span in one step, or with a bound in
the fewest equal steps no longer than `h_max`. Every step end is a boundary,
but the three kinds of boundary do not do the same work.

| At the boundary | Frame top | Due instant inside a frame | Step end inside a span |
|---|---|---|---|
| A step ends | yes | yes | yes |
| Events are detected and a snapshot goes out | yes | yes | yes |
| Discrete components update | those due | those due | none |
| Root inputs land, the drain and the control read run | yes | no | no |
| The pacer has a deadline | yes | no | no |
| `step!` counts it | yes | no | no |

## 2. A shorter step: the frame or the bound

Both give a shorter step, and they differ in what else they change.

A shorter frame adds frame tops, with everything the first column of the
table lists. Staged writes land at a finer grain, the pacer meets more
deadlines, and a loop that calls `step!` once per frame returns more often.

A bound adds step ends alone. Events are detected and snapshots go out at a
finer grain, but the run meets the outside no more often than before.

`Δt_frame` is the required keyword, and with no bound a span is one step. A
batch run with a fixed-step method therefore sets its step with the frame and
never needs `h_max`. Where every due instant falls on a frame top and no
root input changes at the added tops, the two choices take the same steps and
give the same trajectory. Section 4 measures that.

The bound earns its place in the three cases of section 3. In each, the frame
cannot move, or moving it does something the run does not want.

## 3. Three cases for the bound

**The outside fixes the frame.** In a paced run the frame's period is a fact
about the operator and the wall clock, not a numerical choice.

```julia
# an operator flies at a 20 ms frame, and the landing gear needs 1 ms steps
Simulation(model; Δt_frame = 1//50, Δt_base = 1//200, h_max = 1//1000)
```

The pacer has 50 deadlines a second. The discrete tier ticks every 5 ms, and
each 5 ms span takes five steps. The same step from the frame alone,
`Δt_frame = 1//1000`, gives every frame a wall budget of 1 ms, and a frame
that exceeds its budget leaves debt ([§10.7][s10-7]). It also runs the drain
and the control read a thousand times a second.

**The method is adaptive.** Here a shorter frame is not equivalent at all. A
frame top is a mandatory instant, so a step must end there. A bound only
clamps the step the method proposes.

```julia
Simulation(aircraft(); Δt_frame = 1, algorithm = BS3(), h_min = 1//1000, h_max = 1//10)
```

With a 1 s frame the method chooses its steps from its error estimate. The
bound caps them at 0.1 s, which also caps the spacing of the snapshots and of
the detection of events that are not localized. A 0.1 s frame would force a
step end every 0.1 s whether the method wants one or not.

**The spans are unequal.** A component whose ticks fall inside frames splits
them into spans of different lengths. Take a 10 ms frame and one component
due 3 ms into each, so every frame is a span of 3 ms and one of 7 ms.

| Choice | Steps of one frame, in ms |
|---|---|
| `h_max = 1//500`, a 2 ms bound | 1.5, 1.5, 1.75, 1.75, 1.75, 1.75 |
| `Δt_frame = 1//500`, a 2 ms frame | 2, 1, 1, 2, 2, 2 |

The bound divides each span equally and never makes a short step of its own.
The finer frame adds the instants of its own lattice, and the tick then cuts
one of its steps in two. Both take six steps, and the bound's are the more
even. [D-449][d-449] chose equal division because, at a given count, even
steps have the lower truncation error.

## 4. One measured example

The tutorial's loop runs its fastest controller at 200 Hz, on a base tick of
5 ms. Two deployments halve the plant's step to 2.5 ms:

```julia
Simulation(model; Δt_frame = 1//400, Δt_base = 1//200)                     # the frame
Simulation(model; Δt_frame = 1//200, Δt_base = 1//200, h_max = 1//400)     # the bound
```

Every tick falls on a frame top of both, so they take the same steps.

| | `Δt_frame = 1//200`, no bound | The frame | The bound |
|---|---|---|---|
| Snapshots of a 60 s run of `autopilot` | 12001 | 24001 | 24001 |
| The approach's wall time | 0.108 s | 0.209 s | 0.166 s |

Over chapter 5's 120 s climb the plant's five outputs agree to the bit at all
48001 instants the two share. Against the run with no bound, which takes
half the steps, they differ by up to 1.7e-7. The bound is the cheaper of the
two because it skips the added frame tops. The frame is the one that makes
`Δt_base` matter: left out, the base tick falls to 2.5 ms and every rate
doubles.

The tutorial takes the frame. Its reader has no reason to avoid frame tops in
a batch run, and `h_max` stays the subject of the chapter on linearization,
where it bounds the step under a 1 s frame. The figures are those of the
probes `p09_frames` and `p09b_timing` of
`design/increments/20261127_tutorial_rates/probes/`.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-445]: ../log.md#d-445--advance-the-frame-through-boundaries-on-three-lattices
[d-449]: ../log.md#d-449--bound-the-step-by-h_max-and-take-each-span-in-equal-steps
[s10-5]: ../spec.md#105-multi-rate-execution-sweeps-spans-and-the-clock
[s10-7]: ../spec.md#107-real-time-pacing
[s6-3]: ../spec.md#63-rates-down-the-hierarchy
[s9-2]: ../spec.md#92-the-build-and-deployment-artifacts
