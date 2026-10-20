#### Condition algebra

- `set(; x = (;), s = (;), m = (;), u = (;))`. The leaf, a fragment of
  self-vocabulary payloads at the authoring level ([§14.2][s14-2]).
- `at(prefix, node)`. Scoping. It stores, never applies. It also lifts a
  whole [`TrimProblem`](#g-trimproblem) (the closed nine-field value a trim
  solves) and a linearization [tap set](#g-taps) ([§14.2][s14-2],
  [§14.9][s14-9], [§14.10][s14-10]).
- `combine(nodes...)`. Symmetric collection. Duplicate leaves error with both
  origins ([§14.2][s14-2]).
- `override(base, patches...)`. Ordered layering. The patch wins, and the
  origin keeps both ([§14.6][s14-6]).
- `condition(comp; kw)`. The shipped condition-method idiom ([§14.2][s14-2]).

#### Stopped-sim services

- `init!(sim, condition = set(); t0::Real = 0.0, trace = true, log = true,
  log_every = 1, log_max = 65536)`.
  [Root-input totality](#g-root-input-totality) is checked pre-write
  ([§14.6][s14-6]). Then boundary zero runs at `t0`, held as a `Float64`
  origin, and the [checkpoint](#g-checkpoint) that is the run's
  [trace header](#g-trace-header) follows ([§11.5][s11-5], [§14.5][s14-5],
  [D-260][d-260]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `trace` | `true` | the input [trace](#g-trace)'s plain kill switch | [§11.5][s11-5] |
  | `log` | `true` | the snapshot [log](#g-log)'s plain kill switch | [§11.2][s11-2] |
  | `log_every` | `1` | the log's keep-every-kth [decimation](#g-decimation) | [§11.2][s11-2] |
  | `log_max` | `65536` | the maximum number of retained snapshots, `Inf` the opt-out | [§11.2][s11-2] |

  Recording. The four keywords configure the run this call builds, with its
  log and trace ([§12.6][s12-6], [D-261][d-261]). `overlay!`, `restore!` and
  `replay!` take the same four.
- `trim!(sim, problem; baseline, t0::Real = 0.0,
  backend = LevenbergMarquardt()) → TrimReport`. It solves against the
  problem's own `tolerances`, by default as nonlinear least squares on the
  packed residuals with exact Dual Jacobians ([§14.7][s14-7]).
  `LevenbergMarquardt()`, the default backend, is an in-house dense
  Levenberg–Marquardt ([§14.8][s14-8], [D-070][d-070]). The commit is `init!` with
  `override(baseline, condition(solution))`, gated on the report's
  `converged` ([§14.8][s14-8]).
- `solve(backend, eval!, d0, lower, upper, tol) → (; d, status,
  n_evaluations, n_iterations)`. The backend [seam](#g-seam), a pinned
  one-method signature ([§14.8][s14-8]).
- `checkpoint(sim) → Checkpoint`. A checkpoint holds the `Model`'s state at
  a frame top, with `t₀`, the fingerprint and the deployment, beside the run's two counters, the frame index and the boundary
  ordinal ([§12.6][s12-6], [D-274][d-274]).
- `restore!(sim, cp; trace = true, log = true, log_every = 1,
  log_max = 65536)`. A door beside `init!`, `overlay!` and `replay!`, legal
  where `init!` is. It checks the checkpoint's fingerprint and deployment
  (`CheckpointMismatch`) and its `t` against its grid (`CheckpointMidFrame`).
  The warm restart is `checkpoint` → `restore!` → `run!`
  ([§12.6][s12-6], [D-274][d-274]).
- `restore!(sim, model_state; trace = true, log = true, log_every = 1,
  log_max = 65536)`. Takes a `ModelState` prepared on a standalone model,
  with the same fingerprint and deployment check (`CheckpointMismatch`). A
  state off the grid is `CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and the restored boundary
  publishes under ordinal 0 ([§9.2][s9-2], [§12.6][s12-6], [D-319][d-319]).
- `overlay!(sim, condition = set(); trace = true, log = true, log_every = 1,
  log_max = 65536)`. The state what-if. The condition's stores are written
  onto a stopped run's own, and a fresh run opens whose header is the
  checkpoint taken after the settling ([§12.6][s12-6], [§14.1][s14-1],
  [D-429][d-429]).
- `linearize(sim, taps; about = nothing, t0 = nothing, width = 8) →
  Linearization`. A pure query. The operating point defaults to the
  checkpoint of the simulation, and `about` with `t0` (default `0.0`) places
  it anywhere else ([§14.10][s14-10]).
- `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`,
  `get_input(leaf)` and `get_face(leaf)`. The closed
  [read-selector](#g-selector) family, one
  address space for every reader that takes a selector ([§14.4][s14-4]).
- `taps(; x = (;), u = (;), y = (;))`. Builds the tap set, three labeled
  selector lists with closed membership, every tap a
  [leaf address](#g-leaf-address) resolving to one scalar ([§14.4][s14-4],
  [§14.10][s14-10], [D-272][d-272], [D-276][d-276]).

#### Running

- `run!(sim; pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = ())`.
  `run!` blocks until the run ends. Deviceless, it is fully synchronous on
  the [calling task](#g-calling-task) ([§11.1][s11-1], [§12.6][s12-6]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `pace` | `Inf` | the run's [pacing](#g-pacing) rate; `Inf` is pacer-off, `1` real time | [§10.7][s10-7] |
  | `margin` | `0.002` | the single pacing knob, in seconds | [§10.7][s10-7] |
  | `t_end` | `Inf` | the run's end time, declared for this advance, validated per call | [§12.6][s12-6], [§13.5][s13-5] |
  | `ignore_stop_requests` | `()` | the requesters this advance ignores, `:all` or paths in the [requester roster](#g-requester-roster) | [§13.5][s13-5] |

  Each advance builds a [`StopPolicy`](#g-stop-policy) from its `t_end` and
  `ignore_stop_requests` ([§13.5][s13-5], [D-260][d-260]). `t_end = Inf` with
  no honoured stop request is an unbounded run, allowed, with `UnboundedRun`
  raised into the loop's [diagnostic cell](#g-diagnostic-cell) in `:live`
  only ([§11.8][s11-8], [§13.5][s13-5]).
- `step!(sim; frames = 1, t_plus = nothing, t_end = Inf,
  ignore_stop_requests = ()) → frames_advanced`. A synchronous partial
  advance through the ordinary frame sequence, bit-identical to the same
  frames under `run!`. `t_plus = <duration>` is the mutually exclusive
  duration spelling ([§12.6][s12-6]).
- `stage!(sim, "face" => value, …)`. Staging from any task, the calling task
  included, into the [harness writer](#g-harness-writer). Its surface is the
  currently unclaimed faces ([§11.3][s11-3]).
- `latest(sim) → snapshot`. The current published snapshot, the same
  immutable value device handles read ([§11.2][s11-2]).
- `phase_bodies(sim) → named callables`. The compiled phase bodies of the
  nominal activation, bound over the simulation's own buffers. They are the
  [§9.8][s9-8] [measurement seam](#g-measurement-seam) ([§9.7][s9-7]).
- Control plane. `pause!(sim)`, `resume!(sim)` and `stop!(sim)` are the
  calling code's spellings and `paused(sim)` the read ([§12.1][s12-1],
  [D-268][d-268]). `pace!(sim, p)` and `margin!(sim, m)` set the two knobs
  and `pace(sim)` and `margin(sim)` read them ([D-269][d-269]). A device
  stops through `stop!(handle)` ([§11.6][s11-6], [D-268][d-268]).
- Termination. The model's state ends a run via stop requests, `StopFlag`
  ports read at every published boundary unless the advance ignores them
  ([§13.5][s13-5]).
- `termination(sim)`. The current run's
  [termination record](#g-termination-record), whose source is a typed value
  such as `EndTimeReached` or `ModelRequestedStop` ([§13.5][s13-5],
  [D-203][d-203]).
- `logged(sim)`. The log is the retained snapshots, and `logged` returns them
  ([§11.2][s11-2]).
- `reads(; selectors...)`. Builds a read set, the value `series` takes and
  `at` mounts ([§11.2][s11-2], [D-407][d-407]).
- `series(sim, read_set) → ts`. Gathers the retained snapshots into labeled
  columns through the read-selector family, one typed vector per labeled
  entry beside `t`, frame and boundary ([§11.2][s11-2], [D-407][d-407]).
- `trace(sim) → trc`. Retrieves the input trace, on by default
  ([§11.5][s11-5]).
- `replay!(sim2, trc; to_boundary = nothing, to_time = nothing, pace = Inf,
  margin = 0.002, t_end = Inf, ignore_stop_requests = (), trace = true,
  log = true, log_every = 1, log_max = 65536, restore = true)`. Re-drives a
  fresh `Simulation(world)` bit-identically through the ordinary loop,
  taking `init!`'s four recording keywords as well ([D-261][d-261]). Replay
  is the state-trajectory inspector and the `StepError` reproduction tool
  ([§11.2][s11-2], [§11.5][s11-5], [§12.7][s12-7]).
- `warnings(x) → Vector`. The artifact's warning list, on `Build` and
  `Deployment`, and on `Simulation` as the concatenation of its artifacts'
  lists ([§9.2][s9-2], [§13.2][s13-2]).
- `closed(run) → Bool`. True once the loop's tail has written the run's
  termination record ([§12.6][s12-6]).
- `mode(sim) → :live | :replay`. The [input mode](#g-input-mode), read beside
  the lifecycle state. It says where the next frame's [drain](#g-drain) takes
  its [batches](#g-batch) from, the [staging cells](#g-staging-cell) or an attached `replay!` recording
  ([§12.6][s12-6], [§12.7][s12-7]).
- `live!(sim)`. Detaches the remainder of an attached recording and sets the
  mode to `:live`, touching neither the trajectory nor the trace
  ([§12.7][s12-7]).

---
