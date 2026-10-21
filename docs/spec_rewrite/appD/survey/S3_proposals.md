<a id="g-boundary"></a>**boundary** — a published consistency point, where the [§10.6][s10-6]
macro-sequence completes and a snapshot goes out. Every grid point is a
boundary. A localized event time `t*` and
[boundary zero](#g-boundary-zero) ([§14.5][s14-5]) are boundaries but not
frame tops ([§10.1][s10-1]). The structural sense, a component's boundary and
its boundary declarations ([§8.6][s8-6]), is ordinary English, never linked
here.

<a id="g-boundary-detected"></a>**boundary-detected** — the detection policy a `Bool`-returning guard
declares. The framework checks the guard for a not-holding → holding edge at
boundaries only and never root-finds it ([§2.3][s2-3]). The policy is exact
for guards over modes, root inputs and held discrete outputs alone. Those
predicates cannot cross between boundaries ([§10.4][s10-4]).

<a id="g-due"></a>**due** — a discrete component is due at a boundary when its `(D, Φ)`
pair admits that boundary's [tick index](#g-tick-index),
`(tick − Φ) % D == 0` ([§10.5][s10-5]). A due component runs its stages in
the boundary sweep and its `s_update` after quiescence ([§10.6][s10-6]). The
due set is fixed for the boundary's event iteration. [§10.5][s10-5] gives it
per kind of boundary.

<a id="g-firing-budget"></a>**firing budget** — the rule bounding the boundary event iteration. Each
declared event fires at most `firing_budget` times per boundary. That is a
deployment keyword, an integer ≥ 1 that defaults to 4. A re-enabled event can
thus fire again at its true boundary. Exhaustion drops the event's further
edges there under a `FiringBudget` warning ([§10.6][s10-6]).

<a id="g-guard"></a>**guard** — the declared function that defines an event's predicate. It
pairs with a handler in the ordered, named `state_events` collection
([§8.2][s8-2]). Its return type declares its detection policy. A `Bool` guard
is boundary-detected, and a guard returning the nominal scalar is localized
([§10.4][s10-4]).

<a id="g-harmonic-grid"></a>**harmonic grid** — the rule that every discrete period is an integer
multiple of `Δt_base`, with `Δt_base` itself an integer multiple of `h`.
Ticks therefore land only on step boundaries. Grid times are indexed from the
frame count, never accumulated ([§10.5][s10-5], [§10.4][s10-4]). Every anchor
period and offset must be an integer multiple of `Δt_base` too
([§9.2][s9-2]).

<a id="g-input-epoch"></a>**input epoch** — a maximal span of constant root inputs, delimited by the
frame-top drains ([§11.4][s11-4]). Within an epoch a guard changes only
through the trajectory. At a seam it can jump without crossing. The
**θ = 0 validation**, a trial evaluation at `xₙ` under the frame's own `u`,
tells a trajectory-caused edge from an epoch-caused one ([§10.4][s10-4]).

<a id="g-prior"></a>**prior** — each event's stored sample of its predicate at the previous
boundary's quiescence. It is always an honest observation, never a
manufactured one. It is detection bookkeeping, absent from every state store,
though a checkpoint carries it. A boundary's first round tests edges against
it. Boundary zero sets every prior to not-holding ([§10.6][s10-6]).

<a id="g-schedule"></a>**schedule / `Schedule`** — the typed tick timing the `Deployment` carries.
The `Deployment` constructor builds it, one row per discrete component
carrying `(D, Φ, Δt)`, plus the rate-scope rows. It is the single source of
truth for `Δt`, and the substrate of the grid diagnostics and the hyperperiod
chart ([§9.2][s9-2], [§10.5][s10-5], [D-261][d-261]).
