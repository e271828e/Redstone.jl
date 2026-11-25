# G6b: rows for the fixer

Each row: the site at the pinned tip cb398676, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K6a-011 (drift, clear=True)

- at: `design/companions/event_visibility_walkthrough.md:44`
- claim: `y` gathers the component's own cells, its published ports and locals
- evidence: src/build.jl:1597 and src/build.jl:583: y gathers the component's declared ports (both stages) and nothing else. No local or private cells exist. design/log.md:2876 records it in an annotation: 'no local cells remain (D-165, D-194)'. D-194 (log.md:7734) retired the w channel, and intermediates became declared ports.
- fix: **`y` gathers the component's *own* cells** (its ports, of both stages);

## K6a-030 (drift, clear=True)

- at: `design/companions/event_visibility_walkthrough.md:71`
- claim: x_projection normalizes the latched stores
- evidence: src/executor.jl:456-463: _fire_project! calls entry.projection(entry.comp, reconstruct(XT, xbuf, entry.x_off)) and writes the flat state buffer back. It never touches the mode store that _latch! also wrote (executor.jl:446-447). src/declare.jl:585: 'x_projection takes the state alone'. The walkthrough's 'normalizes those stores' covers both latched stores, but x_projection projects the continuous state x only.
- fix: Latching writes *stores*, not cells; `x_projection` normalizes the continuous state store;
- note: The spec and D-074 (log.md:2550, 'x_projection alone stays positional', it takes one store) agree with the code, so only the companion is off. The record of the move is weak because this phrase may always have been loose. Read it as minor imprecision.

## K6b-039 (deviation, clear=True)

- at: `design/companions/library_inventory.md:149`
- claim: A component with one required parameter such as Constant(value) takes it positionally. Its docstring shows the keyword form, and its tests call it.
- evidence: Probe line 1: `Constant(value = 1.0)` throws MethodError. Constant has no keyword form, and its docstring (src/library.jl:330) shows `Constant(value)`. In the doc, 'Its docstring shows the keyword form, and its tests call it' follows the Constant sentence, so it reads as if about Constant. The sentence was written (64d83500) about the keyword-constructed component whose struct keeps its positional constructor, but its current place makes the claim false for Constant.
- fix: The struct keeps its positional constructor, while its docstring shows the keyword form and its tests call it. A component with one required parameter, such as `Constant(value)`, takes it positionally.

## K6b-100 (drift, clear=True)

- at: `design/companions/library_inventory.md:440`
- claim: Zero-Pole: roots real or complex; a product whose imaginary part is not zero to rounding is refused, which conjugate pairs pass, and the real coefficients then meet the existing refusals.
- evidence: src/library.jl:1172-1189 coefficients_from_roots pairs each complex root with its conjugate, within 1e-12 of the root's magnitude, before the expansion, and refuses a root with no partner ('has no conjugate'). Its comment says that checking the expanded coefficients' imaginary parts was dropped because it misread rounding on long products. Probe lines 43-46: an unpaired root is refused, a ring of 10 conjugate pairs passes, and a pair off by 1e-9 is refused as unpaired. Commit deb0bb38 ('pair conjugate roots before the expansion') records the change.
- fix: Roots real or complex; a complex root with no conjugate partner, to a tolerance relative to the root, is refused, and the real coefficients then meet the existing refusals.

## K6c-022 (deviation, clear=True)

- at: `design/companions/linear_systems.md:125`
- claim: When NU and NY are both one the ports are scalars, otherwise they are `SVector{NU}` and `SVector{NY}`
- evidence: src/library.jl:1041 port_type(width), with 1048-1049 applied to each port on its own; probe.jl:27 NU=1, NY=2 gives (Float64, SVector{2, Float64}); probe.jl:29 NU=2, NY=1 gives (SVector{2, Float64}, Float64); test/test_library.jl:1798-1799.
- fix: Each port's width decides its type: `u` is a scalar when `NU` is one and an `SVector{NU}` otherwise, and `y` likewise by `NY`, decided from the matrix shapes at construction.
- note: The per-port rule has been in the code since the first StateSpace commit dd552d5a (port_type per port). The StateSpace docstring at src/library.jl:1080-1081 already states it correctly.

## K6c-045 (deviation, clear=True)

- at: `design/companions/linear_systems.md:221`
- claim: The supertype arms read `x_deriv ... s.A * x + s.B * u`, `realization(c).C * x`, `s.C * x + s.D * u`
- evidence: src/library.jl:1050-1058 x_deriv is A * x + B * as_vector(u), y_state is as_port(realization(c).C * x), and y_direct is as_port(C * x + D * as_vector(u)). The section 6 block omits as_vector and as_port. The realization accessors at 1142 and 1296 match the block.
- fix: x_deriv(c::AbstractLinearSystem, (; x, u))        = (s = realization(c); s.A * x + s.B * as_vector(u))
y_state(c::AbstractLinearSystem{false}, (; x))    = as_port(realization(c).C * x)
y_direct(c::AbstractLinearSystem{true}, (; x, u)) = (s = realization(c); as_port(s.C * x + s.D * as_vector(u)))
- note: Section 9's discrete block already writes the edges with as_vector/as_port, so only section 6's block is stale.

## K6c-103 (deviation, clear=True)

- at: `design/companions/linear_systems.md:400`
- claim: The IMU sampler of [§8.7][s8-7] divides by `Δt` every tick
- evidence: design/spec.md:4232-4237 is the IMUSampler y_direct, which divides ϑ_c and υ_c by Δt. It sits under '### 8.6 Paths, wiring and faces' (heading at design/spec.md:3912), not under §8.7 (heading at design/spec.md:4333). spec.md:868 also says '§8.6 works the IMU in full'.
- fix: the IMU sampler of [§8.6][s8-6] divides by it every tick for the same reason.
- note: The pointer has been wrong since it was written in 10364763. At that commit the sampler was also in §8.6 (docs/design/spec.md:3364, with §8.7 at 3447). The fault is in the pointer, not the code. Re-run linkify.jl to add the s8-6 link definition.

## K6d-051 (drift, clear=True)

- at: `design/companions/lqr_tracker.md:214`
- claim: tracking adds v as the reference while a channel is limited or not engaged, own u while free
- evidence: src/library.jl:2350 makes v the reference at every code when there is no hold: correction_reference(::AbstractAntiWindupController{false, true}) = u.v. Only with the hold does a free channel fall back to its own u (2351-2352). Probe out.txt:22: with hold = false and tracking = true, channel 2's derivative reads (v - u_raw)/Tt = 8.85, not (u - u_raw)/Tt. The companion's bullet states the hold-and-tracking rule as tracking's general rule.
- fix: - **tracking** adds the input `v`, an `SVector{NU, Float64}`, as the correction's reference: without the hold in every channel, and with it while a channel is limited or not engaged, with the fallback to the own `u` while it is free.
- note: D-385's second ruling records the no-hold row ('Without the hold inputs the error passes and the reference is v where the block tracks'). Commit 17ad42da added the same qualifier to section 7's wiring sentence ('since without one v is the reference at every code') but missed this bullet.

## S6f-007 (drift, clear=True)

- at: `design/spec.md:2172`
- claim: A checkpoint holds x, s, m, the signal table, each event's prior and the clock with its origin (a complete list)
- evidence: src/checkpoint.jl:74-85 ModelState holds x, s, m, table, prior, stepper, t, t₀, deployment, layout; src/model.jl:1184-1187 fills `stepper` from checkpoint_stepper(exec.stepper); src/checkpoint.jl:129 restore_stepper!. probe.jl:94 prints those fields. The §7 list leaves out the stepper's carried state, which a restore needs to continue an adaptive run bitwise (test/test_adaptive.jl:116). §12.6 at spec.md:10637 lists it. Commit e7dacf9e added the field to ModelState (D-452, D-461).
- fix: It holds `x`, `s` and `m`, the signal table with its root-input levels and held discrete outputs, each event's [prior](#g-prior), the stepper's carried state, and the clock with its origin ([§12.6][s12-6], [D-274][d-274], [D-452][d-452]).
- note: The Checkpoint also carries the run's frame index and boundary ordinal (src/checkpoint.jl:106-110), plus the deployment and fingerprint, which serve as checks rather than state. The sentence could name the counters too, but §12.6 already places them beside the state.

## S6f-030 (deviation, clear=True)

- at: `design/spec.md:2212`
- claim: The layout has compile-time offsets into one contiguous Vector{T}
- evidence: The layout's offsets are build-time values held at run time, not compile-time constants. src/build.jl:1480 `x_offs = [first(r) - 1 for r in layout.xblocks]`, stored as a runtime field at src/executor.jl:77 `x_off::Int` and passed as an argument at src/executor.jl:130 `reconstruct($XT, xbuf, entry.x_off)`. Only the leaf offsets inside one component's block are fixed at compile time, by the @generated reconstruct/flatten! (src/leaves.jl:223, src/leaves.jl:388). The buffer is one contiguous Vector{T} (src/build.jl:1417). No log entry uses the term "compile-time offset".
- fix: It computes a flat layout at build time. The layout gives each component a block in one contiguous `Vector{T}` that the framework owns, the [buffer](#g-buffer), at a base offset fixed at build time, and each leaf an offset within its block fixed at compile time.
