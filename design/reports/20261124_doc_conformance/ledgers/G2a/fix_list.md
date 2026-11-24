# G2a: rows for the fixer

Each row: the site at the pinned tip 72b12836, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K8-018 (drift, clear=True)

- at: `design/companions/migration_outline.md:28`
- claim: The C172 AD audit's saturation rank-deficiency is 'LM-tolerated, reported'.
- evidence: src/trim.jl:703-714: _saturated lists only decisions sitting at their own lower or upper bound. src/trim.jl:312-318: LM floors a zero Jacobian column, so it tolerates the deficiency. Probe K8-018: a decision feeding an in-model clamp converges at u = 4.70 with the clamp saturated, and report.saturated == [].
- fix: Interpolations tables (prefer cubic knots), saturation rank-deficiency (LM-tolerated, shown in zero Jacobian columns rather than in the report), the gear identically zero airborne (Flight.jl's model alone, below)

## S8a-039 (deviation, clear=True)

- at: `design/spec.md:2621`
- claim: DeclarationShadowed message reads "`MyEngine`'s module defines its own `x_deriv`, distinct from `Redstone.x_deriv`; add `import Redstone: x_deriv`"
- evidence: src/diagnostics.jl:574-578. Probe P039 prints: "`c`: its module `Main.ForgottenImport.Update` defines its own `x_deriv`, distinct from `Redstone.x_deriv`; add `import Redstone: x_deriv` (§8.1)". The message opens with the component path and then names the module. It never takes the spec's "`MyEngine`'s module …" form.
- fix: Its message reads "`engine`: its module `MyEngine` defines its own `x_deriv`, distinct from `Redstone.x_deriv`; add `import Redstone: x_deriv`".
- note: The code has used the 'path: its module `M`' template since it first landed (b6793373, then spelled with Cadence). The spec quote came in with the ruling 351e6440 and was reworded in ef7f5dd8. D-246 (design/log.md:10084) gives no exact wording, so no entry backs the spec's text. The path `engine` in the fix is an illustrative value.

## S8b-071 (deviation, clear=True)

- at: `design/spec.md:3086`
- claim: A `::SomeType{Float64}` return annotation forces converts and hence `InexactError`.
- evidence: probe.jl:153 (ForwardDiff 1.4.6, probe.jl:158): `retann(x)::SVector{3,Float64}` at a Dual throws `MethodError: no method matching Float64(::ForwardDiff.Dual{...})`, not InexactError. The suite's own Dual sweep expects TypeError/MethodError (test/test_build.jl:2251). D-307 says only that the annotation "forces a convert".
- fix: 3. No `::SomeType{Float64}` return-type annotations on the continuous path, because they force converts, and `Float64` has no conversion from a `Dual` (a `MethodError`).

## S8b-167 (deviation, clear=True)

- at: `design/spec.md:3272`
- claim: A Dual-carrying construction of a struct with a hardcoded Float64 field fails with an `InexactError` naming the constructor.
- evidence: probe.jl:154: constructing `GCH(::Dual)` for `struct GCH; a::Float64; end` throws `MethodError: no method matching Float64(::Dual)`. probe.jl:155-157: inside a stage at ProbeDual it surfaces as UserCodeFraming "`c`: `y_state` threw during the build's probe" with that MethodError as its cause. The error is no InexactError, and it names `Float64`, not the GCH constructor.
- fix: Any `Dual`-carrying construction then fails inside the stage with a `MethodError` (`Float64` has no conversion from a `Dual`), which the probe reports as a `UserCodeFraming` naming the stage.

## S8b-197 (deviation, clear=True)

- at: `design/spec.md:3346`
- claim: Message for `q_nb::RQuat`: "declare the `SVector{4}` backing and cast where rotation semantics are wanted".
- evidence: src/diagnostics.jl:965 renders "is not a state leaf — declare the `SVector` backing and cast where the domain semantics are wanted (§7.1)". probe.jl:216 shows it for `q_nb::QWrap`, a 4-vector wrapper. The code is generic. It never says `SVector{4}` or "rotation", and has kept this wording since 30895256. No log entry records the difference.
- fix: - "`x_init` field `q_nb::RQuat` is not a state leaf — declare the `SVector` backing and cast where the domain semantics are wanted ([§7.1][s7-1])";

## S8b-200 (drift, clear=True)

- at: `design/spec.md:3351`
- claim: Message for `s_init` `label::String`: "store fields are isbits or `Symbol`s".
- evidence: src/diagnostics.jl:978 renders "is not a store value — store values are isbits or `Symbol`s; text and bulk data belong on the component instance (§7.3)". probe.jl:218 shows it for `label::String`. Commit ef569eab (bare stores) changed the code's "store fields are" to "store values are".
- fix: - "`s_init` field `label::String` is not a store value — store values are isbits or `Symbol`s; text and bulk data belong on the component instance ([§7.3][s7-3])".

## S8c-036 (deviation, clear=True)

- at: `design/spec.md:3474`
- claim: `x_init` holding a store and no `x_deriv` method, or `s_init` holding a store and no `s_update` method, is `StoreWithoutUpdate`
- evidence: src/assembly.jl:739-745 raises StoreWithoutUpdate only when neither x_deriv nor s_update exists, and the message at src/diagnostics.jl:548 says 'defines neither `x_deriv` nor `s_update`'. Probe P1: x_init holding a store with s_update and no x_deriv gives DeclarationOnWrongTier on x_init, not StoreWithoutUpdate. P1b: a store with no update law gives StoreWithoutUpdate.
- fix: A state declaration holding a store needs its update. `x_init` or `s_init` holding a store, on a primitive that defines neither `x_deriv` nor `s_update`, is a build error, `StoreWithoutUpdate`. A store beside the other tier's update law is `DeclarationOnWrongTier` (below).
- note: spec:3512 already rules the mixed case (an x_init on a primitive whose update law is s_update) as DeclarationOnWrongTier, which agrees with the code. The two sentences overlap, and only 3474 read literally disagrees.

## S8c-119 (deviation, clear=True)

- at: `design/spec.md:3656`
- claim: `Group((; plant = Plant(), ctrl = PID(kp = 2.0)); local_wires = (…))` builds a `PID` with keyword `kp`
- evidence: src/library.jl:2545 `function PID(; Kp, Ki = 0.0, ...)`. Probe P9: PID(kp = 2.0) throws UndefKeywordError for keyword argument `Kp`. PID(Kp = 2.0) builds.
- fix:     (; plant = Plant(), ctrl = PID(Kp = 2.0));
- note: Redstone.Library.PID has had Kp since it was added (06af43f0), and no record covers the spec's kp. The example also leaves the library PID's input r unwired (src/library.jl:2379-2384), so built as written it would add an UnconnectedInput.

## S8d-013 (drift, clear=True)

- at: `design/spec.md:3939`
- claim: Snapshot and log inspection walk instances (§13.3)
- evidence: Snapshot and log reads look up the layout's address table, not instances: src/dataplane.jl:576 port(snapshot, ...) -> src/build.jl:370 port_addr over layout.addr, refusals from layout.component_paths (src/build.jl:390). §13.3's table (spec.md inspection row) says 'the address table: a cell the structure has'. Commit b89e09e3 (conforming to D-414) moved that row from 'the instance walk' to 'the address table'. D-414 says 'inspection never walked declared types'. §8.6 was not swept.
- fix: Snapshot and log inspection read the address table (§13.3).

## S8d-037 (deviation, clear=True)

- at: `design/spec.md:3977`
- claim: Two entries producing the same output face remain the ordinary two-producers error (§6.1)
- evidence: Probe P4b: output_wires ("a/out" => "o", "b/out" => "o") is refused as FaceNameCollision(site = :assembly), not TwoProducers. src/structure.jl:764 checks allunique over input and output face names. The output loop (src/structure.jl ~690) never claims, so TwoProducers cannot arise for an output face. Nothing in the log records the change of error kind.
- fix: Two entries producing the same output face break face-name uniqueness and are refused as `FaceNameCollision`.

## S8d-078 (deviation, clear=True)

- at: `design/spec.md:4151`
- claim: In code, the sculling result is the sampler line `υ_c_sc = s.q'(u.V - s.V)`
- evidence: The spec's own sampler listing, spec.md:4229, reads `υ_c_sc = q_s'(u.V - s.V)`, with q_s = RQuat(s.q, normalization = false). No IMU code exists in src/, test/ or examples/ (rg 'IMU|RQuat' finds nothing). `s.q'` on the SVector{4} store is a row adjoint that cannot be called (a standalone check gives MethodError), so the prose quote names a line the listing does not hold.
- fix: In code, the sculling result is the sampler line `υ_c_sc = q_s'(u.V - s.V)`, with `q_s` the latched `s.q` cast to `RQuat`.
