<a id="g-checkpoint"></a>**checkpoint** — the `Model`'s state at a frame top as one value, a
`ModelState`, beside the run's frame index and boundary ordinal.
`checkpoint(model)` reads the state alone and `checkpoint(sim)` the whole
`Checkpoint`. `restore!` puts either back with no boundary zero. A checkpoint
is not a condition and has no algebra ([§11.5][s11-5], [§12.6][s12-6],
[§14][s14], [D-274][d-274], [D-317][d-317], [D-319][d-319]).

<a id="g-decimation"></a>**decimation** — the log's keep-every-kth retention policy, `log_every`. It
is admissible on the log alone because the log is derived data. Every
boundary still runs, publishes to live readers and enters the trace. When the
log fills its `log_max` bound, the stride doubles. That *progressive
re-decimation* keeps coverage global. Decimation is a view policy, never
trajectory-determining ([§11.2][s11-2]).

<a id="g-recorders"></a>**recorders** — the trace and the log jointly. `init!`, `overlay!`,
`restore!`, `replay!` and a trim commit build them anew together, so they
restart with the run they record ([§12.6][s12-6], [§14.8][s14-8]).

<a id="g-trace-header"></a>**trace header** — the trace's fixed preamble, a checkpoint the door that
builds the run writes once. `init!` takes it at the end of boundary zero,
and `overlay!` after the overlaid state settles. It carries the run's
`Deployment` and `t₀` with the rest of the state. It holds no stop policy and
no schema list ([§11.5][s11-5], [§14.5][s14-5], [D-274][d-274],
[D-429][d-429]).

<a id="g-at"></a>**`at` / `Scoped`** — the scoping combinator. `at(prefix, node)` stores a
prefix beside a condition node and applies nothing. It also lifts whole
`TrimProblem`s and linearization tap sets ([§14.2][s14-2], [§14.9][s14-9]). A
read set keeps its prefixes as a chain and is not a condition node
([D-277][d-277]). An empty prefix is refused when `at` is called
([D-278][d-278]).

<a id="g-baseline"></a>**baseline** — a full-coverage condition, such as an aircraft-shipped
function (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) returns, layered under
tweaks by `override` ([§14.6][s14-6]). It is also the `baseline` keyword
`trim!` takes ([§14.8][s14-8]). Not to be confused with an event *prior*
([§D.4][sD-4]).

<a id="g-condition"></a>**condition** — the datum that says "set this build to this state". It is a
path-addressed sparse overlay, on the declared defaults under `init!` and on a
stopped run's stores under `overlay!`. It covers `x`, `s` and `m` fields plus
root inputs by face, never outputs and never workspace ([§14.1][s14-1]).
[§14][s14] owns the word. A guard defines a *predicate* ([§D.4][sD-4]).

<a id="g-service-lifecycle"></a>**service lifecycle** — the `Simulation` states `built` / `initialized` /
`running` / `stopped` / `errored` ([§12.6][s12-6]) and each service's legality
against them. A `Model`'s own service forms gate instead on its statuses
`:built`, `:consistent` and `:inconsistent` ([§14][s14], [D-319][d-319]). A
violation is `ServiceLifecycle`, and no service accepts an `errored`
simulation ([§14][s14]).

<a id="g-taps"></a>**taps** — the three selector lists (`x`, `u`, `y`), built by `taps`,
declaring what linearization seeds and reports. Every tap names one scalar
leaf. Resolution checks the selectors as `ReadResolution` and the tap set's
own constraints as `TapResolution`. A tap set relocates via `at`
([§14.10][s14-10]).

<a id="g-trimproblem"></a>**`TrimProblem`** — the closed nine-field value
`guess`/`lower`/`upper`/`condition`/`reads`/`residuals`/`tolerances`/`checks`/`check_tolerances`.
It is an *implicitly specified* condition ([§14.9][s14-9]), solved as a square
root-find over named residuals ([§14.7][s14-7]). Its commit is an `init!` of
`override(baseline, condition(d*))` ([§14.8][s14-8]).
