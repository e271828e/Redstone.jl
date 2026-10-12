#### Step boundaries

**[Guards](#g-guard) and handlers read the same fresh world.** At a step boundary the order
is *integrate → project → [boundary sweep](#g-sweep) → guards*. So by guard and handler time
`y` is a fresh decode of exactly the state being transformed, and the state
views are that state itself. Handlers construct their `x`/`m` returns from raw
state naturally. A reset map is `(; x = (; x..., ω = 0.0))`, with no reassembly
from published fields.

**`x_projection` runs between a state write and its decode.** That is after
integration, and after any handler `x`-reset. Those are the only positions in
the [execution order](#g-execution-order) where no fresh `y` of the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function
gets state views. It is unique in that position of the execution order.

**The boundary sequence.** At each boundary the framework integrates, projects,
runs the boundary sweep, evaluates **all guards once** against that sweep, and
fires the eligible events. Each firing is `handler → x_projection`. The
sweep → guards → handlers phase then iterates to [quiescence](#g-quiescence) (the fixed point
where a round of handlers fires nothing), so newly enabled guards fire within
the *same* boundary.

> integrate → project → **[ sweep → guards → handlers ]** iterated to quiescence

The signal table is written **only by sweeps**, so a transition reaches the
table at the next round's re-sweep ([§10.6][s10-6]). The round that detects quiescence
leaves the table post-transition-consistent for whatever else the boundary does,
such as discrete [ticks](#g-tick) and logging.

**Rule.** Hence the epoch rule ([§10.6][s10-6]). A handler executes against
exactly the world its guard fired on. Own `y`, foreign `u` and own `x`/`m` alike
come from the firing round's sweep, so `y = h(x)` holds at every handler entry.

[§10.6][s10-6] settles the iteration itself, how far it runs and how often each event may
fire under the [firing budget](#g-firing-budget) (the per-boundary cap on how often each event
fires). Two of its rules matter here. Within a round each component fires at
most one event, and declaration order picks among that component's
simultaneously eligible events. Same-component sequential composition happens
*across* rounds. Each later event is re-decided against the post-transition
sweep rather than fired on a stale premise.

#### Supervisory inputs: scheduled gains and commanded resets

A supervisor sits one level above a set of compensators. It schedules their
gains and resets them on mode transitions. Both are ordinary signal flow here,
because the [stores](#g-store)-and-[views](#g-view) rules admit neither
parameter mutation nor hand-ordered resets.

**Scheduled gains are inputs.** A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes
one gain bundle per compensator. Compensators consume gains as `u`. What
mutation would hide, ports expose. Gain trajectories are observable in log,
[trace](#g-trace) and [replay](#g-replay), where a parameter write would be
invisible to all three. The [feedthrough](#g-feedthrough) graph carries the
dependency. Linearization holds unseeded gain inputs constant with no special
casing ([§14.10][s14-10]). One-shot design-time gains, such as a controller
synthesized at init, are construction-time parameters or stopped-sim service
outputs. They are not a runtime write path.

**Rule.** A commanded reset of a discrete component is a same-tick input,
consumed in the output stage. The supervisor publishes `engage` and the latch
value from its own feedthrough stage. The compensator sits topologically after
the supervisor and honors them **this tick**:

```julia
y_direct(c::PI, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PI, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                      : s.s_i + c.k_i*Δt*u.e)
```

**Why.** Honoring the reset only in `s_update` is legal, and it means
something else. The state still lands correctly at the next tick. But the
*output at the engagement tick* was already published from the stale state
during the [sweep](#g-sweep), and under ZOH the plant integrates a full step
under that stale command. That one-tick-late command is exactly the bump that
bumpless transfer exists to remove. No diagnostic can catch the bump, because
both spellings are meaningful designs. The update stage cannot rescue its own
[boundary](#g-boundary), because republishing from `s⁺` is rejected
([D-067][d-067]). The output stage is therefore the *only* same-tick path.
[Appendix A][sA] carries this as the same-tick reset entry, and the
bumpless-engage answer ([§11.7][s11-7]) presupposes exactly this spelling.

**A continuous component's reset is an event.** The continuous
[tier](#g-tier) admits no input spelling at all, because only handlers write
`x` ([§3.1][s3-1]). A commanded reset of continuous state, whose condition
arrives as an ordinary `Bool` input, is therefore an edge-triggered event
owned by the reset component. A landing gear's friction regulator,
re-initialized at touchdown by weight-on-wheels, is the canonical case
([D-141][d-141]). A flag-gated reset [face](#g-face) on a library PI block is
sugar over exactly that event. [Appendix A][sA] carries the continuous-reset
contract too.

