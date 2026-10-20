### D-415 — Carry the operation, the current status and the legal statuses in `ServiceLifecycle`

**Status.** ratified

**Position.** A `ServiceLifecycle` carries the operation refused, the current
status and the statuses that admit the operation.

**Spec.** §14

**Rationale.** This restates D-108's Rationale, "one kind `ServiceLifecycle`
(operation, current status, legal statuses)", which no Position carries.
D-319's second bullet spells two of the three, `op = :checkpoint` and
`legal = [:consistent]`, without listing them, and the code names the fields
`op`, `status` and `legal`. The kind's sharing with `attach!` and `detach!` is
D-232's Position. The entry decides nothing new.

**Rejected.** None beyond D-108's list.

### D-416 — Extend the caller-computable escape to environment queries

**Status.** ratified

**Position.** D-064's caller-computable escape covers environment queries. A
condition needing one constructs the handle the sweep will produce and calls
the query function the consuming component calls, with no pre-sweep and no
new mechanism. The handle comes by one of two routes.

- The condition applies the component's value-level constructor (D-139) to
  the values its `baseline` writes into the environment component's root
  inputs.
- In a rig where an isbits handle is itself a root-input value (D-364), the
  condition holds the value the `baseline` wrote there.

**Spec.** §14.1

**Rationale.** This restates D-139's Rationale, "§14.1's caller-computable
escape is extended to cover environment queries", with the two routes it
gives, the second as D-139's annotation of 2026-10-13 narrows it. No Position
carries it. D-064's Position states the escape for swept outputs, and D-139's
the constructor alone. The environment-free fallback the same Rationale
records, promoting the eliminated state coordinates to decision variables, is
D-064's equilibrium case and takes no bullet. The entry decides nothing new.

**Rejected.** None beyond D-139's list.

### D-417 — Never let a trim problem author the environment

**Status.** ratified

**Position.** A trim problem never authors the environment. Its handles arrive
through the user parameter record, and the problem receives the environment
and never writes it.

**Spec.** §14.9

**Rationale.** This restates D-139's Rationale, "Trim problems never author
the environment", which no Position carries. The same passage gives the
reason. A condition entry naming a wired input fails resolution by name
(§14.2), so a problem that wrote an environment face would apply only to rigs
where that face happens to be unconnected. Receiving the environment keeps one
problem valid across a full world and a thin rig. The entry decides nothing
new.

**Rejected.** None beyond D-139's list.

### D-418 — Match a face selector's head against the level's face list

**Status.** ratified

**Position.** On `get_input` and `get_face`, a binding's reads included, the
head of a leaf address is matched against the level's face list rather than
parsed.

- The head is the longest face name that is a prefix of the address and is
  followed by the end, a `.` or a `[`. Where faces `a` and `a.b` both exist,
  the longest wins.
- A `Symbol` leaf names the face whole, with no steps.
- The path selectors parse the head as before, a field name being an
  identifier.

**Spec.** §14.4

**Rationale.** This restates D-276's annotations of 2026-09-30 and 2026-10-01
on its first bullet, which no Position carries. A face name may contain a dot
(§8.6), which a parse of the head would split. The match costs nothing, since
resolution needs the face list for the face's type anyway and every reader
resolves its address against a build. The first annotation names a binding
read beside the two selectors, and since D-406 a binding's reads are
selectors under the one read resolver. The entry decides nothing new.

**Rejected.**
- *Reserving `.` in face names, so the head parses:* the cleaner grammar, but
  reserving `.` alone would not make the head a parse. §8.6 bars only `/`, so
  a face `gear[1]` beside a vector face `gear` gives `"gear[1]"` the two
  readings `"a.b"` has, and a parsed head needs face names to be identifiers,
  which reverses D-046. A build warning for a face name that is also an
  address into another face stays addable after a release, which a
  reservation does not.

### D-419 — Refuse two taps at one site, and name the tier of a tier-pinned root input

**Status.** ratified

**Position.** Tap resolution makes two more refusals.

- Two taps resolving to one site are refused at resolution with both labels
  in hand.
- A root input read by a discrete consumer is unseedable by tier, and its
  refusal names the tier rather than an entry to promote.

**Spec.** §14.10

**Rationale.** Each bullet restates a ruling of D-272's annotation of
2026-09-28, which no Position carries. A second seed at a site overwrites the
first, and the earlier label's column would read as zeros, the silent zero
§14.10 refuses elsewhere. The tier pin is §8.2's wholesale pin under D-168's
meet, so no entry exists to promote, and the next move is the continuous cell
that consumer drives or the recorded step map. D-296's fourth bullet is the
sibling for a root input a consumer's entry pins. The entry decides nothing
new.

**Rejected.**
- *Admitting a tier-pinned root input as a true zero column:* the column reads
  as "no effect" where the effect is temporal and held.

### D-420 — Admit `t0` only beside `about`

**Status.** ratified

**Position.** `linearize` admits `t0` only beside `about`. A `t0` passed
without `about` is refused as `ArgumentInvalid` rather than silently ignored.

**Spec.** §14.10

**Rationale.** This restates the third ruling of D-272's annotation of
2026-09-28, which no Position carries. D-272's fourth bullet and D-319 place
`t0` beside `about` without refusing it alone. The default operating point
carries its own time, the checkpoint's since D-274, so a `t0` beside it would
set nothing. The kind is the one §14.10 states, and the code's reason is
`:t0_without_about`. The entry decides nothing new.

**Rejected.**
- *Ignoring a `t0` passed without `about`:* the caller's argument would be
  dropped silently.

### D-421 — Translate the tolerances into each backend family's stopping language

**Status.** ratified

**Position.** The translation of the tolerances into each backend's stopping
language is the service's, per backend family.

- Under Levenberg–Marquardt the tolerances feed the per-residual test
  directly.
- For the derivative-free scalar fallback the service normalizes each residual
  by its tolerance, minimizing $\sum_i (r_i/\mathit{tol}_i)^2$ at
  `stopval = 1`.

**Spec.** §14.8

**Rationale.** This restates D-150's Rationale, "The tolerance translation
into each backend's stopping language is the service's too, per backend
family", which no Position carries. D-158's Position names "D-150's
per-backend translation" without stating it. The squaring is D-069's fifth
bullet, and the fallback is designed and unbuilt (§14.8). The normalized
objective is dimensionless and well scaled, where a raw $|r|^2$ sums forces
against moments. Its stopping sphere is inscribed in the tolerance box, since
$\sum_i (r_i/\mathit{tol}_i)^2 \le 1$ implies every
$(r_i/\mathit{tol}_i)^2 \le 1$. A fallback stopping at `stopval` therefore
passes the service's box test, and D-150's re-check stays the single
authority. The entry decides nothing new.

**Rejected.** None beyond D-150's list.

### D-422 — Refuse an inverted box and a non-positive tolerance as `TrimProblemInvalid`

**Status.** ratified

**Position.** Setup refuses two more malformed problems as
`TrimProblemInvalid`, collected with the rest.

- A decision whose `lower` exceeds its `upper` is reason `:inverted_box`, with
  the decision and both bounds in hand.
- A tolerance or check tolerance that is not finite and positive is reason
  `:nonpositive_tolerance`, with the field, the key and the value in hand.

**Spec.** §14.8

**Rationale.** No entry records either reason. Both entered the code in
`415ed0b` and moved into `src/trim.jl` in `3408028`, and the landed §14.8
lists both cases. The code's comments give the reasons. An inverted pair is a
box no projection can honor, so `clamp` would answer the upper bound and the
report would name a saturation nobody authored. A tolerance is the half-width
of its residual's or check's box, so zero and negative name no box, and a
non-positive residual tolerance sends the acceptance test to `Inf` or `NaN`
and stalls the solve at the guess. The box check runs per decision, over the
pairs that pass the key-set and type checks. This entry records the two
reasons as §14.8 and the code state them, and decides nothing new.

**Rejected.** None recorded.

### D-423 — Raise a drifted condition shape as `ConditionShapeDrift`

**Status.** ratified

**Position.** The specialized `apply!`'s shape check raises a drifted shape as
`ConditionShapeDrift`, failing fast.

- A tree of another type than the compiled one is reason `:tree_type`, with
  the compiled and observed tree types.
- A prefix string that differs at a node is reason `:prefix`, with the node
  position and both strings.

**Spec.** §14.4

**Rationale.** D-066's Position rules the check, "shape check via tree type +
literal `===` sweep", and no entry names its kind or reasons. The code raises
both (`src/conditions.jl`), and the landed §14.4 and Appendix C state them. A
structured error takes the place of silent corruption. This entry records the
kind as §14.4 and the code state it, and decides nothing new.

**Rejected.** None beyond D-066's list.

### D-424 — Limit a seeded tap to one index step and a `Float64` leaf

**Status.** ratified

**Position.** A seeded tap, in the `x` or `u` list, reaches its scalar through
one index step at most and never through a `.name` step, and its leaf is
exactly `Float64`. Resolution refuses any other seeded address as
`TapResolution`.

- A `.name` step, a second step or a leaf of another real type is reason
  `:unseedable`.
- A leaf that is not a real scalar is reason `:vector_tap`, as in every list.

**Spec.** §14.10

**Rationale.** No entry records the limits. The code checks them in
`_check_seedable` (`src/linearize.jl`), and the suite cites "§14.10, D-036,
D-276" for them, though neither Position states them. A seed is a `Float64`
direction written into a whole cell or one `SArray` component, and there is no
lens into a struct's fields, so the site is the state's buffer offset or the
root input's cell, as D-272's sixth bullet places it. The refusal of a tap
resolving to a vector or a bundle is D-272's annotation of 2026-09-30, and the
second bullet names its reason only. This entry records the limits as §14.10
and the code state them, and decides nothing new.

**Rejected.** None beyond D-272's list.

### D-425 — Admit `init!`, `trim!` and `linearize` under `about` on a `Model` at any status

**Status.** ratified

**Position.** On a `Model`, `init!`, `trim!` and `linearize` with an explicit
`about` take no status gate. Each is legal at any status of the model.

**Spec.** §14

**Rationale.** No Position states it. D-319's second bullet says it of
`restore!` alone, and its fifth puts the default `linearize` behind a
`ServiceLifecycle`. The three doors check no status (`src/model.jl`,
`src/trim.jl`, `src/linearize.jl`), and the lead of §14 states them beside
`restore!`. Each takes an authored condition and reads none of the model's
stores, D-108's ground for admitting `init!` and `trim!` from `built`. D-318's
claim gate is separate and stands. This entry records the forms as §14 and
the code state them, and decides nothing new.

**Rejected.** None beyond D-108's and D-319's lists.

### D-426 — Record the tooling over declared non-participation unbuilt

**Status.** ratified

**Position.** The tooling over the schema's declared non-participation is
recorded, not built. Each piece is additive when a consumer shows up, with no
flag day.

- Pinned-face validation by the tap declaration, where selecting a
  declared-frozen output is a warning.
- A feedthrough-graph lint, where a frozen output fed by participating inputs
  names the severed coupling.

**Spec.** §14.10

**Rationale.** Section 16.10 of the design text at `f990b63` recorded
declarative non-participation as not built, its vocabulary additive with no
flag day. Its three pieces were pinned-face declarations validated by the
linearization surface, a feedthrough-graph lint, and forbid-seeding slot
markers rejected at surface resolution. Until a real consumer showed up, the
sharp tool and the visible zero row would suffice. The schema has since
spelled both halves of non-participation (D-263, D-286), and a `Pinned` root
input is the forbid-seeding marker itself (D-295). Two pieces remain recorded,
as §14.10 states. D-073's Position records the sampled-data extension unbuilt,
not this tooling, and no entry carried it. The entry decides nothing new.

**Rejected.** None recorded.

