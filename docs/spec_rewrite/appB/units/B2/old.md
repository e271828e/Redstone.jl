**Condition algebra** ([§14.1][s14-1]–[§14.6][s14-6]).

- `set(; x, s, m, u)`. The leaf, a fragment: self-vocabulary payloads at
  the authoring level. `u` names faces of that level's contract.
- `at(prefix, node)`. Scoping. It stores, never applies. It also lifts whole
  `TrimProblem`s and linearization tap sets ([§14.9][s14-9],
  [§14.10][s14-10]). An empty prefix is refused ([§14.2][s14-2]).
- `combine(nodes...)`. Symmetric collection. Duplicate leaves error with both
  origins. Blending a node with a bare NamedTuple is a directive error
  method ([§14.2][s14-2]).
- `override(base, patches...)`. Ordered layering. The patch wins, and
  the origin keeps both ([§14.6][s14-6]).
- `condition(comp; kw)`. The shipped condition-method idiom. Aircraft
  baselines (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) are its
  full-coverage instances.

**Stopped-sim services** ([§14][s14]).

- `init!(sim, condition; t0 = 0.0, trace = true, log = true, log_every = 1,
  log_max = 65536)`. `t0` is any real, held as a `Float64`
  origin ([D-260][d-260]). Root-input totality is checked
  pre-write ([§14.6][s14-6]). Then boundary zero runs: project, sweep, events,
  the due `s_update` calls, then the first snapshot, and the checkpoint that
  is the run's trace header ([§11.5][s11-5], [§14.5][s14-5]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `trace` | `true` | the input trace's plain kill switch | [§11.5][s11-5] |
  | `log` | `true` | the snapshot log's plain kill switch | [§11.2][s11-2] |
  | `log_every` | `1` | the log's keep-every-kth decimation | [§11.2][s11-2] |
  | `log_max` | `65536` | the maximum number of retained snapshots, finite by default with `Inf` the opt-out | [§11.2][s11-2] |

  Recording. The four keywords configure the run this call builds, with its
  log and trace ([§12.6][s12-6], [D-261][d-261]); `restore!` and `replay!`
  take the same four. `log_every` is admissible on the derived artifact
  only, never on the trace ([§11.2][s11-2], [§11.5][s11-5], [D-029][d-029]). When the log fills,
  the retention stride doubles, so the whole run stays covered at coarsening
  density. The run's first and terminal snapshots are retained
  unconditionally and outside the bound ([§11.2][s11-2]). All four are view
  policies, not trajectory-determining. Replay neither records nor compares
  them.
- `trim!(sim, problem; baseline, t0 = 0.0, backend) → TrimReport`. Nonlinear
  least squares on the packed residuals with exact Dual Jacobians, against the
  problem's own `tolerances`. `residuals(reads, d) → NamedTuple` is packed in
  `tolerances`' field order, as decisions pack in `guess`'s. Names pair, and the
  order is the declared side's. The problem itself closes at nine fields
  ([§14.7][s14-7]). Setup and commit both carry the root-input-totality check ([§14.6][s14-6]).
  The commit is `init!` with `override(baseline, condition(solution))`, boundary zero
  anchored at `t0` and the recorders built anew ([§12.6][s12-6]). On a `Model{Float64}`,
  `trim!(model, problem; …)` is the same service, its commit the model's
  `init!` ([D-319][d-319]). `converged` is the service's
  per-residual box test at the backend's returned point. It is
  backend-independent and the commit's gate, and the backend's status and counts
  are recorded diagnostically. The backend seam is a pinned one-method
  signature,
  `solve(backend, eval!, d0, lower, upper, tol) → (; d, status, n_evaluations, n_iterations)`.
  The in-place `eval!(r, J, d)` fills `J` only when it is not `nothing`, the
  packed vectors are in the declared orders, and `status` is an open `Symbol`
  recorded verbatim. Non-convergence reports, never throws ([§14.8][s14-8]).
- `checkpoint(sim) → Checkpoint`. The `Model`'s state at a frame top beside
  the run's two counters, the frame index and the boundary ordinal. The state
  is a `ModelState`, as `checkpoint(model)` reads it, holding the flat
  buffer, the `s` and `m` stores, the whole signal table, the guard priors,
  `t` and `t₀`, the fingerprint and the deployment. Legal in `initialized`
  and `stopped`, refused after a `t*` stop and after an abandoned frame
  (`CheckpointMidFrame`). A checkpoint is not a condition and has no algebra
  ([§14.1][s14-1], [D-274][d-274], [D-319][d-319]).
- `restore!(sim, cp; trace = true, log = true, log_every = 1,
  log_max = 65536)`. A door beside `init!` and `replay!`, legal where `init!`
  is. It checks the checkpoint's fingerprint and deployment
  (`CheckpointMismatch`) and its
  `t` against its grid (`CheckpointMidFrame`). It copies the state back,
  builds a fresh run with the checkpoint as its trace header
  and publishes one snapshot at the checkpoint's `t`. It runs no boundary
  zero, and the boundary ordinal continues. The warm restart is
  `checkpoint` → `restore!` → `run!` ([§12.6][s12-6], [D-274][d-274]).

  `restore!(sim, model_state; kw...)` takes a `ModelState` prepared on a
  standalone model, with the same keywords and the same fingerprint and deployment check. A
  state off the grid is `CheckpointMidFrame`. It opens a fresh trajectory at
  the state's frame, and the restored boundary publishes under ordinal 0
  ([§9.2][s9-2], [§12.6][s12-6], [D-319][d-319]).
- `overlay!(sim, condition; trace = true, log = true, log_every = 1,
  log_max = 65536)`. The state what-if. The condition's stores are written
  onto a stopped run's own, the clock, the lattice and the priors are kept,
  the overlaid state settles with no discrete output stage and no update, and
  a fresh run opens whose header is the checkpoint taken after the settling.
  A partial store entry merges onto the current store, and a root-input entry
  writes its cell with no totality asked. Legal where `checkpoint` is, with the
  four recording keywords ([§12.6][s12-6], [§14.1][s14-1], [D-429][d-429]).
- `linearize(sim, taps; about, t0, width = 8) → Linearization`. A pure
  query, seeded Dual passes on scratch, `width` directions per pass. The
  operating point defaults to the checkpoint of the simulation, restored
  with no boundary zero, and `about` with `t0` (default `0.0`) places it
  anywhere else. `t0` is admitted only beside `about`, never silently
  ignored. On a `Model{Float64}`, `linearize(model, taps; …)` is the same
  query, its default point `checkpoint(model)` ([D-319][d-319]).
  `taps(x = (…), u = (…), y = (…))` builds the tap set, three
  labeled selector lists with closed membership (`x`: `get_state`; `u`:
  `get_input`; `y`: `get_output`, `get_face`), every tap a
  [leaf address](#g-leaf-address) resolving to one scalar
  ([§14.4][s14-4], [§14.10][s14-10], [D-272][d-272], [D-276][d-276]).

**Running.**

- `run!(sim; pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = ())`. `run!` blocks until the run ends. Deviceless, it
  is fully synchronous on the calling task. `init!` is required first
  ([§12.6][s12-6]). Paced and unpaced runs are bit-identical ([§10.7][s10-7]).

  | keyword | default | meaning | owning section |
  |---|---|---|---|
  | `pace` | `Inf` | the run's pacing rate; `Inf` is pacer-off, `1` real time | [§10.7][s10-7] |
  | `margin` | `0.002` | the single pacing knob, in seconds | [§10.7][s10-7] |
  | `t_end` | `Inf` | the run's end time, declared for **this advance**, validated per call | [§12.6][s12-6], [§13.5][s13-5] |
  | `ignore_stop_requests` | `()` | the stop requesters **this advance** does not honour: `:all`, or their component paths, validated against the `Build`'s requester roster per call | [§13.5][s13-5] |

  `pace` defaults to `Inf`, pacer-off. A deviceless run is the harness and
  CI mode, and real time is `pace = 1` away ([D-269][d-269]). `margin` defaults to 2
  ms, the sleep primitive's granularity plus its measured overshoot. The
  values `0`, 2 ms and `∞` span the design space ([§10.7][s10-7]). Each
  advance builds a [`StopPolicy`](#g-stop-policy) (the
  immutable `t_end`-plus-ignored-requesters value an advance declares) from its
  `t_end` and `ignore_stop_requests`. It passes that policy to the loop, and the value
  lives as long as the call. The termination record carries the policy that
  ended the run, and nothing else keeps one ([§12.6][s12-6], [§13.5][s13-5], [D-260][d-260]). `t_end = Inf` with no honoured
  stop request is an unbounded run, allowed, with `UnboundedRun` raised into the
  loop's diagnostic cell ([§11.8][s11-8]).
- `step!(sim; frames = 1, t_end = Inf, ignore_stop_requests = ()) → frames_advanced`. A
  synchronous partial advance through the ordinary frame sequence,
  bit-identical to the same frames under `run!`. It never waits ([D-269][d-269]).
  `t_plus = <duration>` is the
  mutually exclusive duration spelling
  (whole frames until the boundary time covers that duration). It returns the
  frames *actually* advanced, fewer than requested when `t_end` or a
  stop request ended the run inside the call. Between calls the simulation
  reports `initialized`. `run!` may follow, and it continues from the current
  boundary. A stepping session is deviceless. Write via `stage!` and read via
  `latest` ([§12.6][s12-6]).
- `stage!(sim, "face" => value, …)`. Staging from any task, the calling
  task included, into the harness writer ([§11.3][s11-3]). Its surface is the currently
  unclaimed faces. The batch is traced, drained last at the next frame top,
  and surface-checked exactly as any device's (the harness cell,
  [§11.3][s11-3]). It is legal under `run!` and `step!` alike
  ([§12.6][s12-6]).
- `latest(sim) → snapshot`. The current published snapshot, the same
  immutable value device handles read ([§11.2][s11-2]). It is the assertion
  and inspection accessor of the harness and REPL modes ([§12.6][s12-6]).
- `phase_bodies(sim) → named callables`. The compiled phase bodies of the
  nominal activation, bound over the simulation's own buffers. They are the
  four blocks (`rhs`, `sweep_1`, `sweep_2`, `ticks`), with the sweeps in both
  arities, zero-arg interior and tick-indexed boundary, and `ticks` taking
  the tick index. Per-event guards/handlers and per-component
  `x_projection` come with them, keyed by the model's roster. This is the
  [§9.8][s9-8] allocation seam. Warm, then `@ballocated(body()) == 0` per
  body. It is an inspection-only surface, and its one promise is identity with
  what the loop runs. An isolated invocation leaves buffers valid but
  off-trajectory. Re-run `init!` to continue ([§9.7][s9-7]).
- Control plane. Pause/un-pause, pace and `margin` changes, and stop all
  sit on a separate atomic surface, never staged ([§12.1][s12-1]). Pacing sits
  outside the semantics, so pace and `margin` are both safe to change live.
  `pause!(sim)`, `resume!(sim)` and `stop!(sim)` are the calling code's
  spellings and `paused(sim)` the read; `pace!(sim, p)` and
  `margin!(sim, m)` set the two knobs and `pace(sim)` and `margin(sim)` read
  them ([D-269][d-269]); a device stops through `stop!(handle)` ([§11.6][s11-6]). The
  tail clears the pause, never a run's start ([D-268][d-268]).
- Termination. The model's state ends a run via stop requests, `StopFlag`
  ports read at every published boundary unless the advance ignores them
  ([§13.5][s13-5]). Shutdown completes a boundary,
  publishes the final snapshot, then joins ([§12.4][s12-4]).
- Post-run. The log is the retained snapshots. `series(sim, read_set) →
  ts` gathers them into labeled columns through the read-selector
  family, one typed vector per entry beside `t`, frame and boundary
  ([§11.2][s11-2], [D-407][d-407]). `trace(sim) → trc` retrieves
  the always-on input trace.
  `replay!(sim2, trc; to_boundary = k, pace = Inf, margin = 0.002,
  t_end = Inf, ignore_stop_requests = (), restore = true)`, taking `init!`'s four
  recording keywords as well ([D-261][d-261]), re-drives
  a fresh `Simulation(world)` bit-identically through the ordinary loop. It
  restores the trace's checkpoint and feeds the drain by frame ordinal from
  the frame after the header's; `restore = false` feeds the simulation as it
  stands. A halt names a frame from the one the feed starts from through the
  recording's last. It ends
  `initialized`. `to_time = t` is the mutually exclusive time spelling
  of the halt, floored to the last frame top at or before `t`. Inspect via
  `latest` or the live stores, advance via `step!`, continue via `run!`.
  Replay is the state-trajectory inspector and the `StepError` reproduction
  tool ([§11.2][s11-2], [§11.5][s11-5], [§12.7][s12-7]; on-disk persistence
  is deferred, `pending.md`).
- `warnings(x) → Vector`. The artifact's warning list, on `Build` and
  `Deployment`, and on `Simulation` as the concatenation of its artifacts'
  lists ([§9.2][s9-2], [§13.2][s13-2]).
- `closed(run) → Bool`. True once the loop's tail has written the run's
  termination record ([§12.6][s12-6]).
- `mode(sim) → :live | :replay`. The input mode, read beside the lifecycle
  state. It says where the next frame's drain takes its batches from, the
  staging cells or an attached `replay!` recording ([§12.6][s12-6],
  [§12.7][s12-7]).
- `live!(sim)`. Detaches the remainder of an attached recording and sets the
  mode to `:live`, touching neither the trajectory nor the trace. The next
  `run!` or `step!` then continues live from the replayed boundary and
  re-records onto the replayed prefix. Stopped-sim only. It is legal on an
  `initialized` simulation in `:replay`, and an already live one refuses
  ([§12.6][s12-6], [§12.7][s12-7]).

---
