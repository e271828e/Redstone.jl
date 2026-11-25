# G7a: rows for the fixer

Each row: the site at the pinned tip 62551b06, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## SB-028 (drift, clear=True)

- at: `design/spec.md:15016`
- claim: Relative and Absolute arguments are each an integer or a Rational
- evidence: src/declare.jl:438-441: Relative takes only Integer counts and throws ArgumentInvalid :not_a_count for any other Real; probe.jl:28-29 Relative(2//1) and Relative(1//2) both throw :not_a_count, while probe.jl:30-31 show Absolute taking Rationals of any integer type. The spec body (design/spec.md:4415-4417) and the D-459 annotation (design/log.md:19655-19663) say Relative refuses a rational.
- fix: Sample-time entries. `Relative(D, Φ = 0)` in scope ticks, its child's `Dₛ` and `Φₛ`, each an integer, and `Absolute(Δt, τ = 0)` in exact rational seconds, each an integer or a `Rational` ([§8.7][s8-7], [D-185][d-185], [D-469][d-469], [D-478][d-478]).
- note: The ruling (commit 2797c742, 2026-11-14, D-459 annotation, §8.7) came before this Appendix B sentence was rewritten in 5ed966f6 (D-469, 2026-11-20). That rewrite let 'each an integer or a Rational' cover Relative too. The code follows the ruling.

## SD1-005 (drift, clear=True)

- at: `design/spec.md:16108`
- claim: an abstract entry is illegal where the face surfaces as a root input (AbstractAtRoot)
- evidence: src/build.jl:916-933 raises AbstractAtRoot only when no consumer of the root input declares a concrete entry, and checks abstract co-consumers by the bound clause. probe.jl P1: _fv(VecReader(), SVecEntry()) builds with root input :in, the abstract AbstractVector{Float64} entry sitting beside a concrete one. test/test_build.jl:717-722 tests the same case
- fix: It is never needed for eltype genericity, and it is illegal where every consumer of a [root input](#g-root-input) declares one, since nothing then types the root input (`AbstractAtRoot`) ([§8.2][s8-2]).

## SD1-054 (deviation, clear=True)

- at: `design/spec.md:16193`
- claim: the families are y_state/y_direct/x_deriv/s_update/guard/handler/x_projection
- evidence: src/declare.jl:899-908 LEGAL_BUNDLE holds sets only for y_state, y_direct, x_deriv, s_update, guard and handler. src/declare.jl:585 says x_projection takes the state alone, not a bundle. src/executor.jl:263 calls x_projection(comp, reconstruct(XT, xbuf, off)). spec.md:1163 agrees
- fix: The families are `y_state`/`y_direct`/`x_deriv`/`s_update`/[guard](#g-guard)/handler, one closed set per name per [tier](#g-tier), the shared output stages taking one set on each ([§5.2][s5-2], [D-220][d-220]); `x_projection` takes the state alone, not a bundle.

## SD1-088 (drift, clear=True)

- at: `design/spec.md:16256`
- claim: every primitive provides exactly two output stages
- evidence: src/declare.jl:617-618 and 644: a component defines the stages it needs, and y_state is optional; y_direct is optional too (declare.jl:679). probe.jl P5: BareRamp, which defines y_state only, builds. spec.md:1140 now reads 'at most two output stages ... defines the ones it needs'
- fix: every [primitive](#g-primitive) has at most two output stages, `y_state` (no `u` in the [bundle](#g-bundle), hence structurally no [feedthrough](#g-feedthrough)) and `y_direct`, and defines the ones it needs.
- coordinator: Match G6's reworded §5.2 ruling: a primitive has at most two output stages.

## SD1-138 (drift, clear=True)

- at: `design/spec.md:16326`
- claim: a bare contract port has no face
- evidence: probe.jl P2: BareScale's port has the face u on input and y on output. src/structure.jl:780-781 says a bare contract takes its default face, u or y. log.md:18143-18148 (D-437) rules that the face is the declaration's letter
- fix: For a [primitive](#g-primitive) it is the port's own name, and a [bare contract's](#g-bare-contract) port wears the default face, `u` or `y`.

## SD2-077 (drift, clear=True)

- at: `design/spec.md:16756`
- claim: A Deployment is the build plus Δt_frame, Δt_base, the step bound h_max, the algorithm and the three event parameters.
- evidence: src/deployment.jl:541-553: struct Deployment also holds h_min (545) and attempt_budget (549) beside the build, Δt_frame, Δt_base, h_max, the algorithm, the three event parameters, the schedule, the lattice and the warnings.
- fix: the artifact the grid parameters fix: the build plus `Δt_frame`, `Δt_base`, the step bound `h_max`, the step floor `h_min`, the algorithm, the attempt budget and the three event parameters, carrying the `Schedule` and its own `warnings`.
- note: h_min and attempt_budget came in with commit 4367fa55 under D-460, and spec line 644 already lists both.

## SD2-084 (drift, clear=True)

- at: `design/spec.md:16767`
- claim: A Dual activation sees only the continuous output stages and x_deriv, never the discrete stages, s_update, guards or handlers.
- evidence: src/build.jl:1144-1166 probes x_projection at every activation, and build.jl:1606-1613 says projection lies 'inside every executable set'. Probe P4: at ProbeDual, y_state, x_deriv and x_projection see a Dual, and the guard and handler are never called.
- fix: A `Dual` activation sees only the continuous output stages, `x_deriv` and `x_projection`, never the discrete stages, `s_update`, [guards](#g-guard) or handlers ([§9.4][s9-4]).
- note: §9.4 (spec.md:5713-5714) already names x_projection, a change made by commit 2255b3c6. The glossary entry lags it.

## SD3-100 (deviation, clear=True)

- at: `design/spec.md:16987`
- claim: It uses the predicate loop counter > last_seen && running
- evidence: src/devices.jl:439 waits while `counter <= last_seen && !stopped`, so it returns when `counter > last_seen || stopped`; probe.jl:25 returns at once with stopped set and no new boundary. The doc's `counter > last_seen && running` as the predicate would never release at a stop.
- fix: plus one `Threads.Condition` under the canonical predicate loop (`counter > last_seen || !running`).

## SD3-181 (deviation, clear=True)

- at: `design/spec.md:17097`
- claim: The fingerprint holds each component's x type, every cell's address and type, and the event list
- evidence: src/checkpoint.jl:18-27 Fingerprint also holds component paths and each component's s and m store types (stypes, mtypes), and src/model.jl:1212-1240 compares them as CheckpointMismatch; probe.jl:15 prints the eight fields
- fix: It is the store layout and root-input faces the `Build` fixes, with what a copy by position relies on, each component's `x`, `s` and `m` types, every cell's address and type, and the event list in the order of the priors.
- note: §11.5 at spec.md:8851-8854 carries the same list and needs the same edit. stypes/mtypes date from eb863b3f; no log entry names them.

## SD3-211 (drift, clear=True)

- at: `design/spec.md:17129`
- claim: Run metadata names Δt_frame, Δt_base, h_max, the algorithm, localization_tol, localization_budget and firing_budget
- evidence: src/deployment.jl:539-553 Deployment also carries h_min (544) and attempt_budget (549); probe.jl:16 prints them
- fix: the trace header's `Deployment` and `t₀`, hence `Δt_frame`, `Δt_base`, `h_max`, `h_min`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` and `attempt_budget`.
- note: Recorded by D-460 and commit 4367fa55 (h_min and the attempt budget on the Deployment); §11.5 at spec.md:8848-8851 already lists both.
