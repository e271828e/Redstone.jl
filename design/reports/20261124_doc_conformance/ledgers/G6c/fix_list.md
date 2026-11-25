# G6c: rows for the fixer

Each row: the site at the pinned tip cb398676, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K6e-003 (deviation, clear=True)

- at: `design/companions/pid_anti_windup.md:69`
- claim: Saturated, back-calculation drives q so that u_raw settles at u + Tt·e
- evidence: src/library.jl:2566 q̇ = Ki·gate(e) + (ref - u_raw)/Tt, so q̇ = 0 gives u_raw = u + Tt·Ki·e. Probe '003' (PID Kp=1, Ki=0.5, Tt=1, limits ±1, r=3, y=0.5, run 40 s): u_raw = 2.25 = u + Tt·Ki·e, against u + Tt·e = 3.5. The same doc's section 11 and lqr_tracker.md section 7 write `v + Tt Ki e`.
- fix: Saturated, it drives `q` so that `u_raw` settles at `u + Tt·Ki·e`, just past the limit, and the output comes off the limit the moment the error reverses.

## K6e-010 (deviation, clear=True)

- at: `design/companions/pid_anti_windup.md:124`
- claim: during a saturation episode the excess the integrator accumulates is Tt·e
- evidence: src/library.jl:2566; the probe '003' line shows the saturated equilibrium u_raw - u = Tt·Ki·e (1.25 at Tt=1, Ki=0.5, e=2.5), not Tt·e (2.5). The excess the integrator holds over the reference scales with Ki.
- fix: Raising `Tt` weakens the coupling, but during a saturation episode the excess the integrator accumulates is `Tt·Ki·e`, and an episode shorter than `Tt` winds up almost freely.

## K6e-062 (deviation, clear=True)

- at: `design/companions/pid_anti_windup.md:322`
- claim: the ungated tracking variant adds the tracking pole A11 = -1/Tt, with dq̇/dv = 1/Tt, to the plain PID's matrices
- evidence: Probe '061/062' Hold=false, Track=true: A = [-1 -2; 0 -10], B = [-0.5 2.5 1.0; 0 10 0]. A11 = -1/Tt and ∂q̇/∂v = 1/Tt hold, but the q̇ row changes elsewhere too: A12 = -Kd/(τd·Tt) and B's first row becomes [Ki - Kp/Tt, -Ki + (Kp + Kd/τd)/Tt]; test/test_library.jl:2913-2914 pins the same matrices. The doc's sentence, after listing the plain matrices in full, reads as if only A11 and the v column differ.
- fix: the ungated tracking variant adds the tracking pole, `A₁₁ = -1/Tt`, with `∂q̇/∂v = 1/Tt`, and the correction's `-u_raw/Tt` also sets `A₁₂ = -Kd/(τd Tt)` and the first row of `B` to `[Ki - Kp/Tt, -Ki + (Kp + Kd/τd)/Tt]`.

## K6e-065 (drift, clear=True)

- at: `design/companions/pid_anti_windup.md:347`
- claim: DiscretePID is the PID of section 7 with s = (q, yf) in place of x
- evidence: src/library.jl:2693 s_init(::DiscretePID{V}) = (q = zero(V), yf = zero(V), saturated = zero(saturation_type(V))); probe '085' line prints (q = 0.0, yf = 0.0, saturated = 0). The store field was added by commit 4478f1af (increment 73 stage 1) and D-384, which section 11 of the same doc records.
- fix: `DiscretePID{V, Hold, Track, Fixed}` is the PID of section 7 with `s = (q, yf, saturated)` in place of `x`, the code `saturated` being section 11's addition.

## K6e-085 (drift, clear=True)

- at: `design/companions/pid_anti_windup.md:417`
- claim: s_init is (q = zero(V), yf = zero(V)) with no keywords
- evidence: src/library.jl:2693 s_init(::DiscretePID{V}) = (q = zero(V), yf = zero(V), saturated = zero(saturation_type(V))); probe '085' line. Added by commit 4478f1af and D-384; section 11 of the same doc records the store field.
- fix: And `s_init` is `(q = zero(V), yf = zero(V), saturated = zero(saturation_type(V)))` with no keywords, as the continuous PID's `x_init` is `(q = zero(V), yf = zero(V))`;
