# Wide discrete stores compile superlinearly, 2026-11-06

Increment 89 added the taps form of `Delay`, an `SVector{K, V}` output
published off the ring store from stage 1. Its first run's compile time
grows about as `K³`. The sweep that found it, the controls that place the
cost in the framework rather than the block, and the profile that names
the compiler stage are recorded here. Nothing in `src/` changes for it; the
pending bullet "Wide discrete stores compile superlinearly" carries it.

Every figure is a fresh process on Julia 1.13.3 with `--startup-file=no`
and `JULIA_LOAD_PATH="@"`, `--project=test`, timing `Simulation`, `init!`
and `step!` over ten frames of `h = 1//100` separately. The model is one
`Constant` feeding the block under test in a `Group`. The scripts are the
session's scratchpad probes `probe_latency_K.jl`, `probe_variants.jl`,
`probe_latency_loop.jl`, `probe_wide.jl`, `probe_tiers.jl` and
`probe_profile.jl`, reproduced from this record.

## 1. The curve

The taps form of `Delay` against the plain one, totals and the `init!`
share:

| `K` | plain, total | taps, total | plain, `init!` | taps, `init!` |
|---|---|---|---|---|
| 1 | 1.49 s | 1.15 s | 0.37 s | 0.39 s |
| 2 | 1.68 s | 1.20 s | 0.38 s | 0.40 s |
| 5 | 1.54 s | 1.15 s | 0.39 s | 0.40 s |
| 10 | 2.07 s | 1.62 s | 0.50 s | 0.41 s |
| 20 | 1.84 s | 1.36 s | 0.42 s | 0.40 s |
| 50 | 1.69 s | 2.05 s | 0.40 s | 1.19 s |
| 100 | 1.44 s | 7.26 s | 0.35 s | 6.33 s |
| 200 | 1.36 s | 48.75 s | 0.33 s | 47.52 s |
| 400 | | 341 s | | 340.7 s |

The build and the ten frames stay between 0.5 s and 1.3 s and 0.2 s and
0.5 s at every `K`. The whole cost is `init!`, where the executor compiles
its sweeps for the first time. From 100 to 200 the time grows 7.5 times and
from 200 to 400 8 times, a cube. The vector form, `V = SVector{2, Float64}`
at `K = 200`, costs 338 s at `init!`, the same as the scalar form at
`K = 400`, so the driver is the number of leaves in the `taps` port, 400 in
both.

## 2. Not the rotation

The taps are the ring read backwards from the cursor, an `ntuple` over
`Val(K)`. Five spellings of that read, compiled alone in a fresh process
with the result used, all allocating 0 B:

| spelling | `K = 50` | 100 | 200 | 400 |
|---|---|---|---|---|
| `ntuple` over `Val(K)`, the shipped one | 0.06 s | 0.32 s | 0.31 s | 0.73 s |
| the `SVector{K}` generator constructor | 0.10 s | 0.20 s | 0.41 s | 0.88 s |
| a loop filling an `MVector` | 0.01 s | 0.01 s | 0.02 s | 0.01 s |
| a shift register by `pop(pushfirst(ring, u))` | 0.16 s | 0.21 s | 0.23 s | 0.32 s |
| a shift register by a loop | 0.01 s | 0.01 s | 0.01 s | 0.02 s |

The shipped spelling costs 0.3 s alone at `K = 200`, against 47 s in the
model. With the loop over an `MVector` in place of the `ntuple` in
`y_state`, the model's `init!` read 1.06 s, 5.65 s, 42.8 s and 340.7 s at
`K = 50`, 100, 200 and 400, unchanged. The body is not where the time goes.

## 3. The controls

A 100-wide and a 200-wide static value through four blocks, none with
taps:

| block, `N` leaves | `N = 100`, `init!` | `N = 200`, `init!` |
|---|---|---|
| `Fn{SVector{N}}(identity)`, stateless, the wide value a port | 0.37 s | 0.52 s |
| `Integrator(x0 = zero(SVector{N}))`, a wide continuous state published from stage 1 | 0.40 s | |
| `UnitDelay(zero(SVector{N}))`, a wide discrete store published from stage 1 | 7.39 s | 56.3 s |
| `DiscreteIntegrator(s0 = zero(SVector{N}))`, the same shape | 11.4 s | |
| `Delay(K = N)`, a wide ring store with a scalar output | | 0.30 s |

A wide port alone is cheap, a wide continuous state is cheap, and a wide
discrete store with a narrow output is cheap. A wide discrete store whose
value reaches a port from stage 1 is the expensive shape, and the taps form
is one instance of it. The trait predates the increment: a user reaches it
today with a `UnitDelay` over a hundred-element vector.

## 4. The profile

`Profile` over `init!` of the taps model at `K = 100`, 32600 samples at
5 ms. Every heavy frame is the compiler's: `typeinf_ext_toplevel`,
`finish_nocycle`, `optimize` and `ipo_dataflow_analysis!`, and under it
the escape analysis's lattice join `⊔ₑ` (1199 samples) whose leaf is
`union!` on sets (1185 samples of self time). The escape analysis tracks
an allocated object field by field, and a 100-element static tuple is a
100-field object; the join of per-field escape sets is where the cube
comes from. Which statement of the generated sweep hands the analysis the
wide object, and why the continuous tier's flat backing avoids it, is not
pinned down. The next probe is a `@code_typed` of the sweep's phase body
for a 100-wide `UnitDelay` beside the same for a 100-wide `Integrator`,
looking for the `%new` of the wide tuple.

## 5. What to do with it

Nothing yet. The library documents the trait on `Delay`'s taps keyword, the
only shipped block whose width a user sets by a keyword, and the pending
bullet names the shape. A fix in the executor is a separate increment,
after the probe above; candidates are a function barrier around the
store-to-cell copy, so the wide object never appears as an allocation
inside the sweep, or Julia's own improvement of the analysis's scaling.
