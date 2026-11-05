# API docstring audit, accuracy and compliance

Date: 2026-11-05. Base: `4a818b2`. Brief:
`design/increments/20261105_docstring_audit/brief_docstring_audit.md`. Rules:
`design/rules/docstring_rules.md`.

This records the read-only audit of all 213 docstrings on the API page, 36,474
words in 22 files. No docstring has changed yet. Section 6 lists the rulings the
sweep waits on, and section 7 records the answers.

## 1. Method

- **Calibration.** One agent audited `devices.jl`, `dataplane.jl` and `trace.jl`
  at `f50260d~1`, with `design/` removed and history off limits. It reported all
  four claims the 2026-11-04 audit had found false in those files: `running`,
  `unblock!`, `stale` and `Trace`. It then re-audited at the base, where those four
  hold.
- **Accuracy.** Eight agents read the code and probed what it does not show on its
  face. `ledgers/A1.txt` to `A8.txt` hold the rows.
- **Compliance.** Four agents walked rules 4 to 6, 17 to 22, 24 to 31 and 35 to 38,
  plus return types under rule 7. `ledgers/C1.txt` to `C4.txt` hold the rows.
- **Adjudication.** The coordinator re-ran each false row's probe at the base, and
  each reproduced. `probes/` keeps those scripts and the ones behind section 5, run
  from the repository root. It read every false row in full, and the `code` and
  imprecise rows to their claim and evidence, some cut at about 300 characters. It
  read compliance by rule tally and sample. It re-ran no imprecise row's probe.

## 2. Counts

| Group | Scope | False | Imprecise |
|---|---|---:|---:|
| A1 | `blocks.jl`, `Junction` to `Sequence` | 1 | 9 |
| A2 | `blocks.jl`, `LimitedIntegrator` to `Group` | 2 | 8 |
| A3 | `sim.jl`, through `linearize` | 1 | 18 |
| A4 | `declare`, `assembly`, `descriptor`, `leaves` | 1 | 10 |
| A5 | `devices`, `dataplane`, `trace`, `roster`, `bindings`, `diagnostics` | 7 | 25 |
| A6 | `model`, `deployment`, `checkpoint`, `frame`, `stepper`, `build`, `readers` | 2 | 26 |
| A7 | `trim`, `linearize`, `conditions` | 1 | 15 |
| A8 | `sim.jl`, from `replay!` | 0 | 22 |
| **Total** | | **15** | **133** |

| Group | Docstrings | Finding rows |
|---|---:|---:|
| C1 | 43 | 122 |
| C2 | 62 | 54 |
| C3 | 48 | 77 |
| C4 | 60 | 102 |
| **Total** | **213** | **355** |

Compliance rows by rule: 20 has 119, 25 has 71, 22 has 62, 26 has 29, 24 has 22,
21 has 15, 31 has 12, 6 has 8, 7 and 30 have 5 each, 5 has 4, 4 and 27 have 2 each,
28 has 1. A row citing two rules counts under both. The agents' tallies differ from
these by a few rows, since some rows carry no edit.

Yesterday's sweep brought the form close, and C2's result shows it, with 34 of 62
clean. `blocks.jl` carries the most rows, about 40% of them rule 22.

## 3. False claims

Fifteen rows make twelve distinct defects. `ledgers/false_rows.txt` holds them in
full, with evidence and replacements.

| Docstring | The claim | What happens |
|---|---|---|
| `Switch` | A `Relay` can produce `select` | The wire raises `WireTypeMismatch`, since `Relay` publishes a value |
| `DiscretePID` | It carries partials under a `Dual` activation | The discrete tier does not run there, so `C` is 0 |
| `Group` | `"plant/y"` is a read path | `port`, `state` and `get_output` refuse it as `PathResolution`. `declare.jl:204` says the same |
| `init!(sim)` | A rejection reaches the next run's first snapshot | It reaches the first frame's snapshot. Boundary zero's carries nothing |
| `m_init`, `modes` | Only handlers write modes | A condition writes them at `init!` and `overlay!`, and `restore!` does too |
| `DeviceHandle` | `gather` allocates nothing inside a `loop` | 32 B per call, because `latest`'s type is abstract. A function barrier gives 0 B |
| `init!(device)` | `shutdown!` runs after the `DeviceCrash` report | The order is reversed, visible only through the internal cell |
| `stop!(handle)`, `stop!(sim)` | The loop completes that boundary and publishes | The frame-top read returns with no further boundary. The last published one stands |
| `PortView`, `port_views`, `incumbent_status` | A produced port has no harness incumbent | The root's exported outputs read `"harness"`. `devices.jl:517` tests the path alone |
| `WriterStatus` | `totals` never decrease from one snapshot to the next | They reset at each door and at each `run!` or `replay!` |
| `Deployment` | A `Δt_base` is refused if an anchor's period "does not divide" it | The direction is reversed. With `T = 1//10`, `1//100` passes and `1//5` is refused |
| `linearize` | A listed activation means no compile at the call | The first call compiles for 0.65 s, and each new tap set for about 0.12 s. The listing saves the activation |

`linearize`'s sentence comes from `spec.md:13262`, "no compile at the keyboard",
D-272, so that finding reaches the spec.

## 4. Imprecise claims, by pattern

Most of the 133 rows fall into these families, so a family ruling settles them.

1. **`PathResolution` goes unnamed.** `init!`, `overlay!`, `taps`, `linearize`,
   `trim!`, `attach!`, `series` and `reads` name `ConditionResolution` or
   `ReadResolution` for a failure that a bad path reports as `PathResolution`.
2. **"Run" as the span of `run!`.** `running`, `loop`, `orphaned`,
   `wait_next_snapshot`, `task_state`, `DeviceHandle` and `stop!` read false for a run
   opened by a door and advanced by `step!`.
3. **Interrupts and hook throws.** `LoopError`, `init!`, `overlay!` and `Model` say a
   throw becomes a `StepError` or writes a status. An `InterruptException` and a throw
   from `settled!` do neither.
4. **A staged batch at a door.** `stage!` on both surfaces and `replay!` omit that a
   door drops a waiting batch silently, and that `:replay` discards it.
5. **A list that omits a case.** `port` omits input faces below the root, `h` omits
   its `Rational{Int}` limit, `Δt_base` omits integers, and `Absolute` omits `t₀`.
6. **Leading-order claims.** The limited integrators' `a h² / 2` holds to leading
   order, with 0.0073 against 0.0050 on a curved input.
7. **Ordinary single-sentence corrections**, each with its replacement drafted.

## 5. Defects in the code

The audit found these while reading docstrings. None is fixed, since each needs a
ruling.

| # | Defect | Evidence | Size |
|---|---|---|---|
| a | `λ₀ = 0` never returns when every trial is rejected, and `λ₀ = -1` raises `SingularException` | A7 `p_lm` | One refusal |
| b | A non-finite Jacobian over two decisions raises a raw `ArgumentError` instead of `:stalled` | A7 `p_lm`, `p_trim3` | A check before the solve |
| c | The root's exported outputs read `"harness"` as incumbent | A5 `p1_views` | One test at `devices.jl:517` |
| d | `port`, `state` and `modes` at a real component with no port say "`h` names no child `h`, its children are h" | A5, A6, A8 | The message's arm |
| e | `t0 = NaN` or `1e34` throws after boundary zero published, and `Inf` is accepted | A3 `p3_init`, `p6_edges` | One refusal |
| f | `x_projection(::C, x::Float64)` on a bare state never runs, with no refusal | A4 `p2_runtime` | `has_stage`'s lookup |
| g | An interrupt at RK4's last stage leaves the clock on a frame top, and `checkpoint` returns the stage point as the state | A6 `p8_misc` | Needs a look |
| h | `trim!`'s search runs at `t = 0` whatever `t0` is, while `linearize`'s `about` form sets the clock | A7 `p_trim` | Design call, spec silent |
| i | `linearize` on a model a running `Simulation` claims races the loop, with 5 of 300 calls raising `CheckpointMidFrame` | A7 `p_lin_running` | Docstring, or a refusal |
| j | `DiscreteLimitedIntegrator` publishes an out-of-limits `s0` unclamped at `t₀`, where `LimitedIntegrator` clamps | A1 `p2b` | Clamp or refuse |
| k | Values past `Int`'s range raise raw errors, as with `t_end = 1e300`, `frames = big(2)^70` and `log_every = big(10)^30`. `frames = typemax(Int)` overflows and returns 0. `replay!(; t_end = 1e300)` throws after writing | A3, A8 | One helper |
| l | `Model`'s gate admits `Dual{Nothing,Float32,1}` and a bare `Dual`, against its own reason | A6 `p1_model` | Tighten the gate |
| m | `Source` and `Freeze` strip one `Dual` layer, so a nested `Dual` is refused at build | A1 `p3_cont`, `p7_freeze` | Docstring clause |

## 6. Rulings wanted

Each has a recommendation. Sections 3 and 4 otherwise default to the drafted
replacement, and compliance rows to the proposed edit.

**Defects.**

1. Land a, b, c, d and e as loose fixes before the truth commit, each with its test.
2. Queue f, g and k as `pending.md` bullets.
3. Set the clock in `trim!`'s search (h), which needs a spec sentence. Until then the
   docstring states `t = 0`.
4. Correct the docstring for i, m and `DeviceHandle`'s `gather`. Refuse an
   out-of-limits `s0` for j, and tighten the gate for l.

**Accuracy.**

5. Drop `init!(device)`'s false row, since its order is invisible through the API,
   keeping the sentence without "then".
6. Drop `stale`'s row on `now = 1.0`, since the keyword asks for a wall-clock value.
7. Keep "at the scale of `Δt_base`" out of the findings on `UnitDelay` and `Delay`
   only if the spec's phrase stands. I recommend the replacement, "over the
   component's own period".
8. Replace `linearize`'s sentence and `spec.md:13262` with "no activation at the
   call", and annotate D-272.
9. Let families 1 to 4 take one wording per family, written once and reused.

**Compliance.**

10. **Rule 20.** Apply the splits where a sentence joins two independent facts, as
    the agents flagged them. These 119 rows are the arc's largest churn.
11. **Rule 22.** Apply, which also settles the 2026-11-04 report's open mechanism
    sentences. Reject the row on `FirstOrderLag`'s "The block stays for", which the
    comment above it records as a ruling of 2026-10-27.
12. **Rule 25.** Link "bare" to `g-bare-store` and `g-bare-contract`. Add to the sheet
    that a link follows the sense, so a homonym such as "the log" for logging takes
    none.
13. **Rule 26.** Unwind "instance data" and "scheduled parameter" as proposed. Treat
    "structure step" as carried by `g-structure`, which drops three rows.
14. **Rule 27.** Add prose "schedule" to the unlinked words, beside "run" and "model".
15. **Rule 7.** It does not reach a bare type line, as its own text says "one line per
    method". `loop`, `peek` and `claims` gain return types.
16. **Rule 8.** The audit left no owner for it. The coordinator's grep finds seven
    lines writing `Union`: `transparent_container`, `latest` twice, `pending`,
    `wait_next_snapshot`, `incumbent_status` and `termination`. Write them in words.
17. **Rules 5 and 6.** Add to the sheet that parallel names may share a bullet, as
    `Linearization`'s `A` to `D`, and that a slurped `kw...` the caller names takes
    prose. `TableBinding` and `reads` then drop out.
18. **Rule 24.** Move the address sentences out of `Get*`, `Scoped`, `Combined` and
    `Override`, since the functions building them carry those.
19. **Rule 31.** Add that a signature defines a parameter the user writes, as
    `Junction`'s `V`. Remove `Hold` and `Track` from the four leaf controllers' prose.
20. **`port(sim)`.** Fold it into `port(model)` under rule 12, as `state` and `modes`.
21. **`MalformedDatum`.** Reject the row moving its examples to the comment. A reader
    needs them.

## 7. Rulings

The user ruled on 2026-11-05: every item of section 6 as recommended. The sheet's
amendments from items 12, 14, 15, 17 and 19 landed with this record.

## 8. What was not established

- Real `SIGINT`s were not sent. Interrupts in probes are thrown from user code.
- `stage!`'s "from any task at any moment" and `stop!`'s "from any task" were not
  stress-tested for concurrency.
- `shutdown!`'s "an interrupt at the wrong moment calls it twice" was read, not probed.
- `localization_budget` exhaustion, `ChatteringBudget` and build warnings were read,
  not run. `pace!` mid-run and `margin!`'s sleep split were read from `wait_deadline!`.
- Replacements are the agents' drafts. Some imprecise rows' drafts add a clause, so
  rule 22 and the word counts still apply at the sweep.
- `docstring_roster.jl`'s "prose after `# Keywords`" check starts after the bullets,
  so it missed prose between the heading and the list, in `LQRTracker` and
  `DiscreteLQRTracker`. The sweep fixes its regex.
- A rule-by-rule second reading was not done. Each agent read each docstring once.
