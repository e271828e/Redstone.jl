### 11.7 The GUI write path: port resolution, peek, staging contract

Panels remain per-[component](#g-component) extensions in FlightCore's style,
such as `GUI.draw!(ctx, ::LowPassFilter)`, discovered by walking the
[assembly](#g-assembly). Widgets, however, name **the component's own
[ports](#g-port)**, never [root inputs](#g-root-input). The build-time wiring
answers one question statically and exactly: *is this port transitively
driven by a root input, and which one?* Every input port has exactly one
source ([§6.1][s6-1]), so the resolution is total:

- **Root-driven, within the GUI's claim: a live widget.** It
  [peeks](#g-peek) and stages the resolved root input through the GUI's own
  [staging cell](#g-staging-cell).
- **Component-driven, or root-driven under another device's claim: a
  read-only rendering.** It displays the driven value from the
  [snapshot](#g-snapshot), visually distinct, with its source
  ("driven by `avionics/throttle_cmd`", the canonical slash form of
  [§8.6][s8-6]).

This retires FlightCore's dead-slider convention and replaces it with checked
structure: **a widget is live exactly when the underlying input is yours to
command in this configuration.** The dead slider is the `Cessna172Xv1`
throttle. The engine panel's slider is visually live and the avionics
silently overwrite it every cycle, so who commands what lives in the user's
head. User-commandability is a wiring decision made where configurations are
made. Command-plus-manual-override is a mux component with a root-wired
select. That is explicit structure, not two writers racing (the same race as
the drag phase in the worked example of [§11.4][s11-4], ruled out the same way). This places one
obligation on the GUI. Read-only rendering is first-class, not an error
state, because the author of `input_slider!` cannot know at authoring time
whether it will be live.

**Liveness is a [derived property](#g-derived-liveness), and resolution is
transitive.** A widget is live iff two things hold. Its port's feed chain
terminates in a root input, *and* that root input lies **inside the GUI's
own [claim](#g-claim)** in the run's frozen surface partition (root-input
exclusivity, [§11.3][s11-3]). The feed chain is walked through [local wires](#g-local-wire) and
interface connections across *all* levels, not just the local assembly. The
claim may have been computed from the unclaimed complement under
`is_greedy`, or enumerated [face](#g-face) by face by a partial-claims
binding ([§11.6][s11-6]). Either way, "live" reads as "inside the surface I
declared for".

Under the [roster](#g-roster) freeze, liveness is a static fact of the run.
It is baked once, with the port resolution, when the run starts, and never
consulted against mutable claim state at render. There is no per-port
"GUI-controlled" marking anywhere. The export chain is the marking, written
by the one author entitled to write it. A component's ports become
GUI-commandable exactly when the assemblies above surface them. The switch
between "driven by its own panel" and "driven by an external provider" is
therefore automatic. At build time it follows the wiring archetype, where a
scripted `World` wires a [scenario component](#g-scenario-component) into the
same faces the interactive `World` exports to root. At run start it follows
roster claim state. Nominally-connected ports with a GUI *override* channel
are rejected ([D-045][d-045]). The honest cost stands. **Unexported ports are
unpokeable.** FlightCore's poke-any-`u` workflow does not survive
[contract](#g-contract) visibility ([§8.3][s8-3]), deliberately.

**Peek rule.** A widget displays its **own pending write if any, else the
snapshot value**. It peeks its own [cell](#g-staging-cell) only. Another
[device](#g-device)'s pending write is invisible by design. Its applied value
arrives via the snapshot one frame later, and cross-device peek is rejected
([D-026][d-026]). While paused, staged edits display indefinitely and apply
at the un-pause [drain](#g-drain) (the frame-top swap that publishes staged
device writes into the root inputs). Fan-out is consistent for free. Widgets
on ports resolving to the same root input peek the same pending value.

**Staging contract: widgets stage on interaction events only.** Value
widgets (sliders, drags) stage the new absolute level on edit. Edge widgets
(buttons) stage on activation, as a level computed from the peek. A flaps
button peeks the current counter `k` and stages `k+1`. The levels doctrine
makes this safe by construction. Repeated staging of the same level within a
drain window is idempotent, so there is no repeat-increment hazard.
Multi-click within one window counts correctly through the
own-pending-first peek (`k` → stage `k+1`; second click peeks pending `k+1`
→ stages `k+2`). Held buttons do not re-stage. After the drain applies and
the snapshot catches up, re-staging from the peek would auto-repeat at frame
rate. The activation edge is the intent.

The alternative, active widgets staging on *every* render pass, is rejected
([D-026][d-026]). Under root-input exclusivity ([§11.3][s11-3]) it has no
motivation. As a side benefit, staging traffic (and trace noise) drops from
render-rate-while-grabbed to actual edits.

No claim-transition policy exists, because no claim transition can occur
mid-run (the freeze, [§11.3][s11-3]). The one liveness-adjacent display rule
is the orphan case. A read-only widget whose claiming device's task has died
renders the fact in its source label ("claimed by `T16000M` — task dead"), the
heartbeat surfaced in place ([§12.2][s12-2]). What it displays beside that
fact is the ordinary snapshot value, the orphaned root input's last drained
level. An orphan widget is a read-only rendering like any other, never a
blanked one. An orphaned root input is therefore visible where the user is
looking, not only in the status panel.

**The panel convention has two halves. The framework's half is fixed here,
and the GUI package's half is deferred.** A panel reaches the framework
through three values: a port view, the device handle and a snapshot. The
port view is this section's baked verdict, one per declared port of every
component, input and output. The handle supplies the two reads the peek
composes and the one write, `stage!`. The snapshot supplies every driven
value and the writer status the orphan label reads. Nothing a panel needs
reaches into the loop ([D-270][d-270]).

**Rule. The port view.** `port_views(handle)` builds one view per port of
every component, keyed by `(path, port)`, from the build's wiring, the
handle's claim and the exclusivity index. A view carries the port's terminal
producer (`("", face)` when root-driven), the liveness verdict, the port's
position in the handle's staging schema when live, the producer's cell
address, and the incumbent writer of a root-driven port the GUI does not
command. The GUI's loop body builds the table once at its top. That point
is after the roster freeze, so the incumbents are the run's, and nothing at
render resolves a name. The handle carries the build's `Structure` and the
nominal `Layout` by reference for this, the two things the bake needs that
the handle did not hold. An output port's view is read-only with itself as
producer, so a generated panel reads every face through one lookup.

| the port resolves to | live | slot | incumbent |
|---|---|---|---|
| a root input inside the GUI's claim | yes | its position | the GUI |
| a root input in another device's claim | no | none | that device |
| a root input no device claims | no | none | the harness |
| another component's port, or its own output | no | none | none |

**Rule. The peek.** `pending(handle, slot)` reads the handle's own staging
cell with one acquire load and never takes it: `Some(value)` when the slot
is touched, else `nothing`. A staged batch is never mutated after it is
published into the cell, so the load sees a complete batch or none.
`peek(view, handle, snapshot)` composes that read with the snapshot. A
live view returns its own pending value when one is touched, and the
producer's cell off the snapshot otherwise. A read-only view skips the cell
and reads the producer's cell. Two ports resolving to one root input share
slot and address, which is the fan-out consistency above.

The rule has one visible consequence, and it is the rule's own. Between the
frame-top drain that takes the cell and the publication of that frame's
snapshot, a live widget finds nothing pending and shows the previous
snapshot's value, for at most one frame's compute. A click inside that
window peeks the old level and stages a level already drained, which the
levels doctrine makes idempotent. No device task reads the loop's store, so
no reading is more current than this one.

**Rule. The orphan fact.** `incumbent_status(view, snapshot)` returns the
incumbent's writer record from the snapshot's status ([§11.8][s11-8]), or `nothing`
for a port no device writes. On that record, `orphaned` is a task that
returned or crashed, and `stale` is [§12.2][s12-2]'s silent heartbeat. The record
tells an exited loop from a crashed one, and the label may. The label text
is the GUI package's.

**What stays deferred is the GUI package's half** (`pending.md`), which the
built-in GUI's parking ([D-310][d-310]) assigns to the browser client over the
bridge: what the client receives beside the three values, how a panel
scopes to a child component, and the widgets. Its constraints are fixed
here. Panels name their own ports by face-name string. Resolution to root
inputs and the liveness verdict are baked at run start, never performed at
render. Liveness and peek arrive through the framework-supplied context,
never by reaching into the loop. And assembly panels compose children by
path.

