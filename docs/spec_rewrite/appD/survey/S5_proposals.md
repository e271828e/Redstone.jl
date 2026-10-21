<a id="g-binding"></a>**binding** — the value passed at `attach!` that makes a device
framework-legible. It subtypes `AbstractBinding` and declares its sides by the
`Bool` traits `is_input` and `is_output`, false by default on the root. Attach
checks its enumeration methods, `claims` and `reads`, against those traits
([§11.6][s11-6]). Every input-side binding stakes a [claim](#g-claim), returned
or [greedy](#g-greedy-claim) ([§11.3][s11-3]).

<a id="g-control-plane"></a>**control plane** — the separate few-word atomic surface carrying pause,
pace, `margin`, stop and the other fields of `Control` ([§12.1][s12-1]). The
loop consults it at frame top, so a change during a wait lands at the next one.
A run's outcome belongs to the [`Run`](#g-run), not to it. It is structurally
not staging, since a paused loop drains nothing.

<a id="g-diagnostic-cell"></a>**diagnostic cell** — the per-writer cell each rostered device, the harness
writer, the loop itself and the `Model` own for runtime diagnostics and
liveness. It holds a bounded ring (capacity 16) of diagnostic values,
per-kind suppressed counts and an atomic heartbeat timestamp. The loop takes
it at the frame-top [drain](#g-drain) and freezes it into the published
[framework status](#g-framework-status) ([§11.8][s11-8]).

<a id="g-operator-interrupt"></a>**operator interrupt** — Ctrl-C in an interactive session, read as a
control-plane stop rather than a failure. Delivery is masked across the
boundary macro-sequence and raised at a frame-top, wait or pause-block unmask
point. The run then takes the ordinary graceful tail and ends `stopped`.
Outside the REPL, SIGINT still kills the process ([§12.4][s12-4],
[§12.1][s12-1]).

<a id="g-run"></a>**`Run`** — the state one run owns, a `Simulation` field beside the control
plane. Its two `const` fields are the log and the trace. Its four writable
ones are `feed`, `termination` and the trajectory's counters `frame` and
`boundary`. The four doors, `init!`, `overlay!`, `restore!` and `replay!`,
construct one, and `closed(run)` is `termination !== nothing`
([§12.6][s12-6], [D-255][d-255], [D-260][d-260], [D-317][d-317]).

<a id="g-leaf-address"></a>**leaf address** — the `leaf` argument of a [selector](#g-selector), naming
one leaf of a port value or one component of a state leaf. It is the field or
face name followed by `.name` and `[k]` or `[k,l]` steps in any order, as in
`"pose.q_eb[2]"` or `"J[1,3]"`. A bare `Symbol` is the short form of a plain
name ([§14.4][s14-4], [D-276][d-276]).

<a id="g-should_abort"></a>**`should_abort`** — the per-attachment failure policy, an `attach!` keyword
defaulting to `false`. Set, a device's departure (loop body returning, crash,
or a failed `init!`) also requests a control-plane stop. Clear, the run
continues with the device absent and its claims held to run end. It is never
a device property ([§11.6][s11-6], [§12.4][s12-4], [D-381][d-381]).

<a id="g-stop-policy"></a>**`StopPolicy`** — the immutable value one advance declares, `t_end` plus the
requester paths it ignores. `run!`, `replay!` and `step!` build and validate
it per call and pass it to the loop. Afterwards only the
[termination record](#g-termination-record) keeps it. A stop through the
[stop word](#g-stop-word) sits outside it ([§12.1][s12-1], [§12.6][s12-6],
[§13.5][s13-5], [D-255][d-255], [D-260][d-260], [D-316][d-316]).

<a id="g-write-surface"></a>**write surface** — the set of faces a writer's batch entries may reach. For
a device it is the claim set, whether returned by `claims` or computed under
`is_greedy`. For the harness writer it is the derived unclaimed complement. It
is static per run and enforced entirely at staging, `OutOfClaimEntry` for a
device and `ClaimedFaceEntry` for the harness ([§11.3][s11-3]).
