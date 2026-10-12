#### Step boundaries

Guards and handlers read the same fresh world. At each step boundary the framework
integrates, projects, runs the boundary sweep (the full pass that
refreshes the signal table, with the boundary's due discrete ticks gated in),
evaluates *all guards once* against that sweep, and fires the eligible events.
So by guard and handler time `y` is a fresh decode of exactly the state being
transformed, and the state views are that state itself. Handlers construct
their `x`/`m` returns from raw state naturally. A reset map is
`(; x = (; x..., ω = 0.0))`, with no reassembly from published fields.

Each firing is `handler → x_projection`. The sweep → guards → handlers phase
then iterates to [quiescence](#g-quiescence) (the fixed point where a round of
handlers fires nothing), so newly enabled guards fire within the *same*
boundary ([D-020][d-020]).

> integrate → project → [ sweep → guards → handlers ] iterated to quiescence

**`x_projection` runs between a state write and its decode**
([D-016][d-016]). That is after integration, and after any handler `x`-reset.
Those are the only positions in the boundary sequence where no fresh `y` of
the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function
gets state views. It is unique in that position of the boundary sequence.

The signal table is written *only by sweeps*, so a transition reaches the
table at the next round's re-sweep ([§10.6][s10-6], [D-154][d-154]). The round
that detects quiescence leaves the table post-transition-consistent for
whatever else the boundary does, such as discrete [ticks](#g-tick) (the
instants at which a discrete component's stages and update run) and logging.

Under the epoch rule ([§10.6][s10-6]), a handler executes against exactly the
world its guard fired on ([D-154][d-154]). Own `y`, foreign `u` and own
`x`/`m` alike come from the firing round's sweep, so `y = h(x)` holds at every
handler entry.

[§10.6][s10-6] settles the iteration itself, how far it runs and how often
each event may fire under the [firing budget](#g-firing-budget) (the
per-boundary cap on how often each event fires). Two rules from
[§10.6][s10-6] matter here. Within a round each component fires at most one
event, and declaration order picks among that component's simultaneously
eligible events ([D-154][d-154]). Same-component sequential composition
happens *across* rounds. Each later event is re-decided against the
post-transition sweep rather than fired on a stale premise.

#### Supervisory inputs: scheduled gains and commanded resets

A supervisor sits one level above a set of compensators. It schedules their
gains and resets them on mode transitions. Gain scheduling and resets are both
ordinary signal flow here, because the rules for stores and views admit neither
parameter mutation nor hand-ordered resets.

**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns
the lookup tables as inert parameters, reads the scheduling variables as
inputs, and publishes one gain bundle per compensator. Compensators consume
gains as `u`. Ports expose what mutation would hide. Gain trajectories are
observable in log, [trace](#g-trace) and [replay](#g-replay) (the session's
recorded inputs, and the ordinary loop re-driven from that recorded trace), where a parameter write
would be invisible to all three. The feedthrough graph carries the dependency.
Linearization holds unseeded gain inputs constant with no special casing
([§14.10][s14-10]). One-shot design-time gains, such as a controller
synthesized at init, are construction-time parameters or stopped-sim service
outputs ([D-089][d-089]). They are not a runtime write path.

**A commanded reset of a discrete component is a same-tick input, consumed in
the output stage** ([D-089][d-089]). The supervisor publishes `engage` and the
latch value from its own feedthrough stage. The compensator sits topologically
after the supervisor and honors them *this tick*:

```julia
y_direct(c::PI, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PI, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                      : s.s_i + c.k_i*Δt*u.e)
```

Honoring the reset only in `s_update` is legal, and it means something else
([D-089][d-089]). The state still lands correctly at the next tick. But the
*output at the engagement tick* was already published from the stale state
during the sweep. Under zero-order hold, which keeps a discrete component's
outputs constant between its ticks ([§10.5][s10-5]), the plant integrates a
full step under that stale command. That one-tick-late command is exactly the
bump that bumpless transfer exists to remove. No diagnostic can catch the
bump, because both spellings are meaningful designs. The update stage cannot
rescue its own boundary, because republishing from `s⁺` is rejected
([D-067][d-067]). The output stage is therefore the *only* same-tick path.
[Appendix A][sA] carries this as the same-tick reset entry, and the
bumpless-engage answer of the C172X demo's *Mode engage* frame presupposes
exactly this spelling. The C172X demo is the interactive Flight.jl demo that
section 3 of `companions/flight_case_studies.md` examines.

**A continuous component's reset is an event** ([D-141][d-141]). The
continuous tier admits no input spelling at all, because only handlers write
`x` ([§3.1][s3-1]). A commanded reset of continuous state, whose condition
arrives as an ordinary `Bool` input, is therefore an edge-triggered event
owned by the reset component. A landing gear's friction regulator,
re-initialized at touchdown by weight-on-wheels, is the canonical case
([D-141][d-141]). The gear wires the strut's `wow` port to the
regulator `frc`'s `reset` input, `strut.wow → frc.reset`, so the reset fires
on the touchdown edge. A flag-gated reset [face](#g-face) (the
name a port wears on its component's boundary) on a library PI block is sugar over
exactly that event. [Appendix A][sA] carries the continuous-reset contract
too.
