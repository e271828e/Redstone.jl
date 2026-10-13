### 11.4 Inbound: per-device staging, representation and the drain

A device produces writes on its own task, whenever its hardware or its peer
hands it a datum. The loop consumes them at frame top. Between those two
rates something has to hold each device's pending writes and hand the loop a
value it can apply. That something is the staging cell, a compound term
distinct from a table cell ([D-121][d-121]). Unlike a table cell it is mutated
frame by frame, outside the table's publish-once discipline. This section fixes
the policy under which a device writes into its cell, the shape the cell
holds, and the [drain](#g-drain) (the frame-top swap that publishes staged
device writes into the root inputs) that empties it.

**Rule.** Staging keeps one atomic [cell](#g-staging-cell) per attached
[device](#g-device) under one [coalescing](#g-coalescing) policy: CAS merge,
newest wins per [face](#g-face). Each cell has a single writer, its own device
task, and holds that device's latest pending [batch](#g-batch) of
[root input](#g-root-input) writes. Staging merges the incoming batch into the
pending one. Untouched faces survive, and re-staged faces take the newest
level. That is the per-face ZOH. The CAS can fail only because a drain
intercepted the old batch, so the retry is bounded. The failure case is
precisely correct as well. Intercepted writes are already applied, and must
not be re-staged.

**Why.** Merge is the *only* policy because it is always correct. A
**complete** writer covers every face in every batch it stages. A joystick
delivering its full write-set every poll is the type case. For such a writer
merge and overwrite are provably the same operation, which makes overwrite a
degenerate fast path rather than a second semantics. A **sparse** writer
stages only what was touched. The GUI and a JSON peer are sparse writers, and
under overwrite they lose writes silently instead. The worked example at the end of this section works that
hazard through: a pending `flaps` edit clobbered by an unrelated `gear`
message, undrained and undiagnosable. A user-facing overwrite opt-in
(`complete(binding)`) is closed ([D-104][d-104]).

**Rule.** The staged representation is fixed per attachment, compiled at
attach. An enumerated writer's [claim](#g-claim) set and root-input types are
both known at attach, since `claims(binding)` ([§11.6][s11-6]) is read
against the root [contract](#g-contract). So the framework fixes the cell's
content type there. It is a pair of positional tuples over the claim set: a
values tuple, concretely typed `Tuple{T₁, …, Tₙ}`, and a parallel `Bool`
touched-mask. A set mask position means *staged this time*. A clear one
means *not touched*, never "reset". Untouched positions carry placeholder
values and are never read. The mask guards every consumer, so no placeholder
ever reaches the model. The batch is therefore isbits with one concrete
layout per writer. The levels doctrine is untouched, and root inputs only
ever receive masked positions. The face-name → position schema lives in the
[roster](#g-roster) entry.

In sketch form:

```julia
# claim set enumerated f₁ … fₙ; Tᵢ = declared type of the root input behind fᵢ

# attach fixes the cell's content type — values and mask, both concrete:
values :: Tuple{T₁, …, Tₙ};  mask :: NTuple{n, Bool}

# stage!, on the device task: the shim turns the author's face ⇒ value pairs
# into `incoming` — name → position, convert to Tᵢ, set the mask

# staging merges into the pending batch, newest wins per face:
merged.values[i] = incoming.mask[i] ? incoming.values[i] : pending.values[i]
merged.mask[i]   = incoming.mask[i] | pending.mask[i]

# the drain scatters, unmasked positions skipped:
batch.mask[i] && (the root input at position i receives batch.values[i])
```

**Why.** One concrete layout is what makes the frame-top drain compilable.
The alternative carrier, `Union{Nothing, Tᵢ}` per face with the marker riding
in the value, has no such layout. Tuple types are covariant, so each
combination of touched faces is its own concrete type, and applying a batch
would specialize at frame top on which faces it touched ([D-202][d-202]). The
mask buys the layout back at the price of dead placeholders. Those are filled
from the declaration's [probe](#g-probe) values, which are constructible for
every declared type and unreachable behind the mask guard.

The consequences are each mechanical. The merge is positional and
mask-driven (the sketch above), so it compiles straight-line, leans on no
small-tuple heuristic, and does not degrade with surface width
([D-202][d-202]). The drain applies each cell through an attach-compiled
**scatter**: position → root-input cell, statically typed, masked-off
positions skipped. That scatter is the exact mirror of the compiled output
gather ([§11.2][s11-2]).

Authors never build the shape by hand. `map_input` returns face ⇒ value pairs
for whatever the datum touched, and `stage!` normalizes those pairs through
an attach-compiled shim. The shim does three things. It maps name to
position, converts to the root input's declared type, and sets the mask. It
thereby confines the residual name-shaped dynamism to one framework-owned
conversion on the device task, at the boundary where wire-shaped data becomes
system-shaped data. Author-built total tuples are rejected as a padding form,
the same disease [D-074][d-074] and the handler return law refuse
([D-104][d-104]).

**A greedy entry needs no special treatment here.** Its claim was computed at
the attach point, and by the time shapes are compiled it is an ordinary claim
set ([§11.3][s11-3]). The GUI's cell is compiled exactly as a joystick's.

**The [harness cell](#g-harness-cell) (the always-present staging cell of the
harness writer) gets the same treatment.** Under the roster freeze its
derived surface, the unclaimed complement, is as static as any claim set, so
it too is compiled to a positional shape. That shape is recompiled at each
`attach!`/`detach!`, both stopped-sim points, and it carries the same shim,
merge and scatter. Being always present, the harness cell gets the
compilation unasked. It is also the one cell whose shape the framework
derives rather than receives.

One representation, one mechanism. The name-keyed dynamic path the mutable
surface used to force does not exist, and no face name is ever resolved
inside the loop's frame.

The recompilation has one seam. A pending harness batch staged *before* a
stopped-sim `attach!` may hold the old shape, or may name a face the new
claim covers. The attach renormalizes that batch. It is reshaped, and
newly-claimed faces are discarded with `ClaimedFaceEntry`. So the run always
starts with cells matching the run's schemas.

**Rule.** Diagnostic sites follow the compilation, all of them to staging.
Face-name validity, surface membership and value convertibility are all
static facts of the run. Every check therefore runs in `stage!`'s
normalization, on the writer's own task. A device's out-of-claim face has no
position in the schema and is rejected with `OutOfClaimEntry`. Staging is an
earlier, better-attributed site than the drain for that rejection, and the
kind and [payload](#g-payload) are the same either way. The GUI is included,
its claim being an ordinary one. A **harness** write to a claimed face is
rejected the same way, with `ClaimedFaceEntry` naming the incumbent device.
And a value that cannot convert to its root input's declared type is
discarded with `EntryTypeMismatch` ([Appendix C][sC]), at the same spot.

Nothing remains at the drain. With surfaces frozen for the run, there is no
fact only the drain can know, and the drain is pure application.

**Doctrine: staged values are levels, never deltas** (`press_count = 17`,
never `presses += 1`). Levels are idempotent and survive coalescing. Button
edges ride as monotonic counters.

**Rule.** At frame top the drain takes each device's cell with one
`atomicswap(cell, nothing)`. The swap is an indivisible take, so there is no
lost-write window. Each taken cell is then applied through its compiled
scatter, **in attachment order**. Attachment order is retained as a
deterministic application order. Under root-input exclusivity, cross-device
writes to one root input cannot arise, so the order matters only for
diagnostics.

Which *frame* a write lands in remains wall-clock reality. What the drain
guarantees is that the frame's outcome is a pure function of the drained
batches.

Because the roster is a fixed value at `run!`, the drain is fully compilable.
The cells and their scatters form a heterogeneous but *known* tuple the frame
function can specialize on, which means zero dynamic dispatch at frame top.
That is the same per-configuration compile trade the [executor](#g-executor)
([§9.7][s9-7]) already makes, now incurred only at stopped-sim attach points.
The specialization is an implementation freedom
[the freeze](#g-the-freeze) creates, not an obligation. Iterating a roster
array costs a handful of dispatches per frame and remains acceptable.

Two shapes were rejected, both examined in the worked example below: per-input
atomic cells, and a shared lock-free [batch](#g-batch) stack ([D-024][d-024]).

**Mappings run on the device task.** Today's
`assign_input!(mdl, mapping, data)` becomes the pure
`map_input(data, mapping) → batch`. User-extensible code thereby never
executes inside the loop's frame, and the trace consists of root-input-level
batches.

**Mappings are binding data, not shaping code.** A mapping
is a declarative table: axis/button → root input, plus per-axis conditioning
parameters (deadzone, expo strength). The shipped `TableBinding` applies
those parameters in its generic `map_input`, on the device task. That is the
shared pure helper, with an owner ([§11.6][s11-6]).

The boundary is set by the face contract: **a face's meaning is
writer-independent**. Faces therefore carry *post-conditioning* semantics. A
GUI slider or a script writes the same command a curved stick delivers, and
running a mouse drag through a deadzone would be absurd. This GUI-parity test
is what places conditioning upstream.

Aircraft-semantic derivation must *not* ride along. A command fan-out such as
`q_ref = q_sf · axis` is the case in point. It is FCS design and
lives in-model, in the avionics. Alternatively it is accepted as a small
per-aircraft×device mapping entry, an aircraft-design fork.

The trace records post-conditioning levels. Those are exactly what the model
consumed, so [replay](#g-replay) is exact. The raw stick levels are the known,
accepted loss: re-running a session through *different* curves is impossible.
Edge logic follows the levels doctrine. Devices stage monotonic press counters.
Accumulators (trim offsets, flap detents) are model state, not mapping state.

#### Worked example: filter, joystick and GUI

This worked example is the exercise that selected per-[device](#g-device)
[cells](#g-staging-cell) and produced the [§11.7][s11-7] staging contracts. The setup is a first-order filter with root inputs `u_cmd`
and `τ`, a fictitious 100 Hz single-axis joystick streaming a slow ramp onto
`u_cmd` (a complete writer), and a 60 Hz GUI with sliders for both
[root inputs](#g-root-input) (a sparse writer). [Boundaries](#g-boundary) run
at 50 Hz, at pace 1. The interference on `u_cmd` is the point.

Three candidate staging shapes were on the table: **per-input cells**, a
shared **[batch](#g-batch) stack**, and **per-device cells**. The user-level
listing came out identical across all three, so ergonomics cannot discriminate
between them. Behavior under a concrete interleaving did.

**Root-input exclusivity rules out the very contest the setup builds.** Under
root-input exclusivity ([§11.3][s11-3]) the contested-`u_cmd` scenario cannot
arise, because a second writer on `u_cmd` is an attach-time error. What the
test settles is therefore the cell *shapes*: atomicity,
[coalescing](#g-coalescing), pause behavior and the peek rule. Its
conflict-precedence comparison and the active-widget stage-every-pass contract
([§11.7][s11-7]) describe a contested-input world the design does not have.
The findings below are read under that scope.

- **Drag against the stream.** The user grabs the `u_cmd` slider while the
  joystick streams. Under per-input cells and the batch stack, each
  [frame](#g-frame)'s conflict resolves by last-store/last-push wall-clock
  order ([D-024][d-024]). With 16.7 ms renders against 10 ms polls, the
  applied input alternates between drag value and ramp on the cadence beat,
  the filter visibly wobbles, and the pattern differs run to run. The
  [trace](#g-trace) replays any given run exactly, but the behavior is still a
  timing artifact. Under per-device cells the GUI stages in every drag frame,
  since it renders at least once per 20 ms frame and the active-widget
  contract stages on every pass. The GUI therefore wins every
  [drain](#g-drain) (the frame-top swap that publishes staged device writes
  into the root inputs) by attachment order. That win is a clean,
  deterministic override for exactly the grab duration. The same user code
  gives qualitatively different physics.
- **Edits while paused.** Under per-input cells, the still-polling joystick
  overwrites the user's `u_cmd` edit about 10 ms later ([D-024][d-024]). The
  knob visibly snaps back and the edit never applies. Under the batch stack,
  the edit is buried under newer pushes, and the pending chain grows at the
  polling rate, about 10³ nodes per 10 s pause, with every [peek](#g-peek)
  walking that chain ([D-024][d-024]). Under per-device cells, the `u_cmd`
  edit holds in the GUI's own cell across the pause, and the knob keeps the
  edit by the [§11.7][s11-7] peek rule. That edit merges with the `τ` edit,
  which is the sparse-accumulation case, and applies at the un-pause drain. It
  holds for one deterministic frame before the joystick reclaims the root
  input. That one-frame application is the honest semantics of one-shot
  editing a streamed input. The uncontested `τ` edit works under all three
  shapes.
- **Corrections the exercise forced.** The sparse-writer lost-write hazard is
  specific to one-cell-per-device layouts. Per-input cells cannot lose
  independent-input writes, so the CAS merge is per-device cells' antidote,
  not a general need. And the batch stack's conflict order is temporal, not an
  attachment-order policy ([D-024][d-024]).
- **Discoveries.** There were two: the active-widget contract, and the
  [port](#g-port)-resolution answer to panel reuse ([§11.7][s11-7]). The
  second came from asking how the filter's panel survives the filter becoming
  an embedded [component](#g-component) with `u_cmd` driven by another
  component.

