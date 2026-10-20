# Unit B1 rulings and findings

## Corrections proposed

### Adopted, ruling coordinator 2026-10-20

Applied in `new.md`; the open questions they answered are kept below as the
record.

- **Diagnostic kind names stay on B** (open question 1). D-226 makes a name
  public by standing on B, so narrowing the surface is the audit's call. Each
  kind B1 had dropped is back as one clause with its home citation:
  `UnknownFaceSelection` (`:multiple_selectors`) and `EmptyFaceSelection` on
  the passthrough helpers (§8.8); `FiringBudget` in the `firing_budget` row
  (§10.6); `ServiceLifecycle` on `checkpoint(model)` at a status other than
  `:consistent` (§14) and on `attach!` while `running` or `errored` (§11.3),
  with `detach!` keeping "Stopped-sim only, like `attach!`"; `CheckpointMismatch`
  on `restore!(model, …)` (§12.6); `BindingContractMismatch` and
  `EmptyGreedyClaim` after the binding-traits table (§11.6); `AlreadyAttached`
  and `ClaimConflict` on `attach!` (§11.3); `DeviceCrash` on the device's
  `init!` (§11.6). `Control` stays out.
- **Length** (open question 2). 67 % accepted; with the clauses above, B1 is
  now 1,694 words.
- **Positional names** (open question 3). The spec's spellings stay, `world`,
  `device` and `path`.
- **`activations = ()`** (open question 4). Accepted as `src/` spells it.
- **`Model(build, T = Float64; kw...)` and `Model(world, T = Float64; kw...)`**
  (open question 5). One entry beside `Model(deployment, …)`, as far as
  `src/model.jl:8–32`'s docstring states them: "`Model(build; kw…)` is
  `Model(Deployment(build; grid kw…), T; chunk_size)`, and `Model(root; kw…)`
  calls `build` first". Spelled `world` as §9.2 spells the `Simulation` form.
  No spec section states either form, so the entry carries no citation. The
  `ConditionPlan` methods, the scalar-mismatch restore and
  `incumbent_status`'s return stay out.
- **Frozen 14108** (open question 6). No change in B; carried to Appendix C's
  pass.
- **R12 terms** (open question 7). B2 links *trace header*, *selector*,
  *calling task* and *root-input totality*.
- **The `set` pointer** (open question 8). `init!`'s signature is followed by
  "(`set`, under Condition algebra)", a pointer to B2's group label.

### Adopted after verification, ruling coordinator 2026-10-20

Applied in `new.md` after `verify.md` (0 drift, 0 lost).

- **Stages and update laws.** "Its stages are `y_state` and `y_direct`, its
  update law `x_deriv`, and its event functions guard/handler pairs (…) and
  `x_projection`", and for the discrete leaf "Its stages are `y_state` and
  `y_direct`, and its update law `s_update`". §5.2 (frozen 1040) gives every
  leaf exactly two output stages; §8.2 (frozen 2281) speaks of "the stage and
  update-law names".
- **`running(handle)`** moved off §12.3's citation to §11.6's (frozen 8024).
- **`pending(handle, slot)`** moved into the panel-kit entry, §11.7 (frozen
  8393–8398).
- **The Assembly parenthetical** scoped to `transparent_container` alone:
  "`input_wires`, `output_wires` and `sample_times`, and the optional
  `transparent_container` (default `nothing`)", per §8.5 (frozen
  3204–3206). The other three's defaults stay unstated.
- **`stop_reason`** cited to §8.2 and D-316 in place of §13.5. §8.2's sentence
  (frozen 2913) states it, bold with D-316.
- **`Relative(K, Φ = 0)`** spelled with `Φ`, as §10.5 and D-185 do (ruling 3's
  spec spelling). This reverses the earlier `φ`, which followed
  `src/declare.jl:167`.
- **`DeviceHandle`** named in the device-handle entry, "The device handle,
  `DeviceHandle`", since `attach!`'s signature returns it.
- **C-132** cites D-319 beside §14. D-319's Position names it: "At `:built`
  or `:inconsistent` it is refused as `ServiceLifecycle` with `op =
  :checkpoint`".

Verifier findings left, with the reason:

- C-117 (D-317 on `init!` "into `:consistent`") and C-160 (D-317 on the
  convenience forms' keywords) are weak carriers the verifier accepted. No
  frozen spec sentence states either more directly: §12.6 (frozen 9441) says
  only that the model's own entry points write the status. `src/model.jl:156`
  and `src/sim.jl:145–150` state them, and a docstring is no citation.
- `input_faces(c)` and `linearize(model, taps; …)` keep the spec's positional
  names over `src`'s `comp` and `tap_set`, under ruling 3.
- The three M notes (C-141, C-147, C-177) are all MATCH; each held span
  stands, and the note names where the rest of the claim lives.

### Findings

- **Survey rows.** R1-63's home 3964 is `output_passthrough`'s consumer; the
  claim's home is frozen 3967 ("Both helpers take `child_path` naming an
  immediate child"), which `claims.md` uses. R1-04's home §8.1 2308 does not
  state "public by being here"; only D-226's Position does. R2-26's home §14
  11391 gates the model forms by status but names no `ServiceLifecycle` for
  them; `claims.md` uses Appendix D's service lifecycle entry.
- **Brief R10's sections.** `AbstractComponent` is §8.5's (frozen 3212,
  D-039), not §8.1's. The sample-time entries are §10.5's (frozen 6193–6220,
  D-185), not §8.6's or §9.2's. `new.md` cites §8.5 and §10.5.

## Citations added or replaced

- **D-226** on "Every name here is public by being here" (R6): "A framework
  name is public by standing on Appendix B's surface, reached by qualified
  name or per-name `import`."
- **D-090** on the handler return (R3, R9): "Handler returns are NamedTuples
  under the bundle law (§5.2, §9.5): `(; x, m)`, a key present iff the store
  exists AND the handler updates it". §7.1 joins the same sentence, carried
  over from the dropped `x_deriv` return rule.
- **D-317** on `init!` "into `:consistent`": "The model's status is
  `:built`, `:consistent` or `:inconsistent`, written only by the model's own
  doors and catch sites", with "The clock keeps `t` and `t₀` on the executor,
  and `init!` on the model sets both." It carries the claim by implication;
  `src/model.jl:156`'s docstring states it outright.
- **D-317** on "which settles through the hooks", replacing §14.6 (which went
  with the totality clause): "`init!` on the model takes the hooks too, so
  boundary zero publishes through `settled!`."
- **§13.4** replacing §10.4 on `frame!`'s gloss: "The `Model`'s `frame!`
  wraps each whole frame, every boundary it settles included" (frozen 10365).
  §10.4 never names `frame!`.
- **D-317** on `frame!`'s return and the hooks: "`frame!(model, k, hooks) →
  Bool` runs `frame_top!(hooks)` before it touches any state and
  `settled!(hooks)` at every settled boundary … A `true` from `settled!`
  abandons the frame's remainder and is `frame!`'s return. The hooks are one
  `FrameHooks` struct with concrete fields … and `NoHooks` does nothing and
  returns `false`."
- **D-317** on `port`, `state`, `modes` and `warnings(model)`: "The model's
  doors are `init!`, `apply!`, … `phase_bodies`, `warnings`, `port`, `state`
  and `modes`."
- **D-319** replacing §12.6 on `CheckpointMidFrame` for the model: "with the
  clock off the grid as `CheckpointMidFrame`, naming the frame the clock sits
  inside". §12.6 names it for `checkpoint(sim)` only; §12.6 stays on the
  entry's gloss.
- **D-318** on the stepping primitives (R5): "The stepping primitives
  `evaluate!`, `integrate!` and the boundary routines stay ungated internals
  that `frame!` and `init!` compose."
- **D-319** beside D-318 on `apply!`, Rationale only (below).
- **D-317** replacing §9.2 on the convenience forms' keywords: "`Simulation(deployment;
  …)`, `Simulation(build; …)` and `Simulation(root; …)` compose through a
  `Float64` model." That carries the pass-through only by composition;
  `src/sim.jl:145–150` lists the keywords. §9.2 stays on the forms' gloss.
- **§8.5, D-039** on `AbstractComponent` (R10): §8.5, "There is no
  `AbstractAssembly`, only one root `AbstractComponent`"; D-039's Position,
  "one root `AbstractComponent`". D-170 transferred D-039's marker role; its
  root-type clause stands, and only that clause is cited.
- **§10.5, D-185** on `Relative` and `Absolute` (R10): D-185, "`Relative(K, Φ
  = 0)` in scope ticks …, `Absolute(q, τ = 0)` in exact rational seconds …,
  `q` a `Period`/`Hz` quantity normalized to its rational period at
  construction".
- **§11.6, D-366** on the device functions (R7): "A device must define
  `loop(dev, handle)` … `init!`, `shutdown!` and `unblock!` are optional, each
  with a no-op default."
- **§11.6, D-268** on `stop!(handle)` (R10), Rationale only (below). §11.6
  (frozen 7873–7874) gives the handle "control access (observe running,
  request shutdown)".
- Moved, not new: §13.3 on `resolve`, §8.8 on the passthrough helpers, §9.2
  on the convenience forms, §12.6 on `checkpoint(model)`, `restore!` and
  `overlay!`, §11.3 on `attach!` and `detach!`. Each was the entry's own
  citation, left behind when the sentence after it moved out.

## Rationale-only rulings

- **D-319, Rationale**, `apply!` outside the API (decisions.md frozen 14484):
  "The `Model` block of Appendix B places the stepping primitives outside the
  API and outside the claim's gate, and `apply!` outside the API but inside
  the gate". D-317's Position still lists `apply!` among the model's doors.
- **D-268, Rationale**, `stop!(handle)` (decisions.md frozen 11498): "The
  verbs follow the stop's grammar, `stop!(sim)` beside `stop!(handle)`". No
  Position spells the handle's stop.

## Bold on the same entry elsewhere

None. B1 has no bold (R4), and neither has `units/B2/new.md`.

## Inbound citations affected

Every frozen spec sentence that cites Appendix B for B1's content still finds
it: 5626 (the `algorithm` row keeps "bound against the state buffer at
`Model` construction"), 6043 (the `Deployment` keyword table), 8969 (the
`join_timeout` row), 9369 (the four recording keywords, now with `overlay!`),
14870 (the `Model` block, its doors now "entry points"). 7810's `Deployment`
is the `Deployment` entry; its `t₀` is B2's `init!`.

Frozen 14108 cites B for "The `Model` and `Simulation` constructors' keywords
validate under `ArgumentInvalid`". Neither old nor new B says so. `src/`
does (`chunk_size` an integer ≥ 1, `join_timeout` a positive real, each
`ArgumentInvalid` `:range`). See the open questions.

## Open questions

All eight were ruled by the coordinator on 2026-10-20 (above, "Adopted").

1. **Diagnostic names leave B.** Dropping class 2 rows (R1) takes
   `UnknownFaceSelection`, `EmptyFaceSelection`, `FiringBudget`,
   `CheckpointMismatch`, `ServiceLifecycle`, `BindingContractMismatch`,
   `EmptyGreedyClaim`, `AlreadyAttached`, `ClaimConflict` and `DeviceCrash`
   out of B. All are Appendix C kinds. D-226 makes a name public "by standing
   on Appendix B's surface". Does C's kind set count, or should B carry one
   line naming the kinds as public through C? `Control`, a struct name, also
   leaves.
2. **Length.** New B1 is 1,551 words against old 2,331, 67 %, not half. The
   three verbatim or kept tables are about 450 of them. Further cuts would take
   the Authoring parentheticals, the hook sentences R5 keeps, or the
   signatures of the handle's capabilities.
3. **Positional names where the spec and `src/` differ** (R8, not fixed):
   `build(world)` and `Simulation(world; kw...)` (§9.2) against `src`'s
   `root` (build.jl:572, sim.jl:230, D-317's `Simulation(root; …)`);
   `detach!(sim, device)` against `src`'s `dev` (sim.jl:2010), with no spec
   spelling outside B; `resolve(assembly, path)`, typed `path::String` in
   §13.3 and `path::AbstractString` in `src`. `Relative(K, φ = 0)` followed
   `src` (declare.jl:167); §10.5 and D-185 spell `Φ`, now adopted (above).
4. **`build`'s default.** `build(world; activations = ()) → Build` follows
   `src` (R1, R8). The spec states the keyword only by its CI value; no
   section states the default `()`.
5. **Forms in `src` that B does not list**: `Model(build; …)` and
   `Model(root; …)` (model.jl:8–12), `init!(model, plan::ConditionPlan; …)`
   and `overlay!(model, plan::ConditionPlan; …)`, `restore!` at another
   scalar (`CheckpointMismatch` `:scalar`), and `incumbent_status`'s return,
   `→ WriterStatus | nothing`. Listing them is the audit's call.
6. **Frozen 14108.** Should the `chunk_size` and `join_timeout` rows say the
   constructor refuses a bad value as `ArgumentInvalid`, as the inbound
   sentence expects?
7. **R12 and B2.** B1's old text used, and B1's new text no longer uses, the
   linkable terms *trace header*, *selector*, *calling task*, *root-input
   totality*, *stop policy*, *root input*, *prior*, *execution order* and
   *walked*. `units/B2/new.md` uses the first four. Under R12 B2 leaves them
   unlinked, so B would carry no link for them. B2 should link them at its
   first use. B1 leaves *tier* unlinked, since its only use is the header of
   the verbatim bundle table.
8. **Define-before-use.** `init!` and `overlay!` on the model spell
   `condition = set()` (R8), and `set` is B2's condition-algebra entry, later
   in B.
