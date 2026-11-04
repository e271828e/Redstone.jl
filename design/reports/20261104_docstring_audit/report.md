# API docstring audit

Date: 2026-11-04. Range: `ac74239` to `15e0900`. Rules:
`design/rules/docstring_rules.md`.

The audit began with one question: did `LimitedIntegrator` and
`LimitedDoubleIntegrator` follow the sheet? They passed its mechanical rules and
failed its elaboration rules. Tracing why led to routing changes, new refusals in
the library, and a check of all 213 docstrings on the API page.

Line numbers below are at `0969a1c` unless stated. Names are the stable reference.

## 1. Why the docstrings drifted

| Point in history | `LimitedIntegrator` words | `LimitedDoubleIntegrator` words |
|---|---|---|
| Before the sweep (`f8663ce~1`) | 432 | |
| After the sweep and its review (`8e78b72`) | 529 | |
| After the glossary pass (`c5fa299`) | 487 | |
| Added (`1590a08`) | | 586 |
| Before the audit (`b6d6cdf`) | 687 | 705 |
| After the rewrite (`4739007`) | 563 | 569 |

Four causes acted together.

1. **Nothing routed a builder to the sheet.** Its opening line addressed only an
   agent rewriting a file and its reviewer. `implementation.md` never named it.
   Briefs 86 and 87 named it only for the reviewer. Brief 87 told its builder to
   write "a docstring in the file's style".
2. **The sweep kept the problems with the sheet in hand.** The text before the
   sweep already held the mechanism paragraph and the colons. The checklist said
   "one line per rule" but covered one of the four elaboration rules, and the
   sweep's reviewer worked from that checklist. "Nothing is deleted" and a
   citation-only mechanical check also favoured keeping text.
3. **The double integrator copied the single one**, so it began at 586 words.
4. **Every correction added text.** `LimitedIntegrator` gained 190 words in five
   commits on one day, and no step removed any. `implementation.md` sends
   behaviour to the docstring or a site comment, and brief 87's reviewer checked
   truth, not style. Its record reports no style result, though its brief asked
   for one.

## 2. What changed

| Commit | Content |
|---|---|
| `ac74239` | Binds the sheet to every new or edited docstring, names it in `implementation.md`, adds checklist lines 20 to 22 and the rule for findings |
| `4739007` | Both integrators' rewrites, the refusals below, the `Float64` wording fix |
| `9272f60` | `sim.jl` |
| `39c6043` | `declare`, `assembly`, `build`, `descriptor` |
| `55c93f9` | `devices`, `roster`, `bindings`, `trace`, `diagnostics` |
| `f676db5` | `model`, `deployment`, `checkpoint`, `frame`, `stepper`, `leaves`, `dataplane` |
| `5ccfa40` | `trim`, `readers`, `conditions`, `linearize` |
| `0969a1c` | `blocks` |
| `fe58c05` | The sheet's note on the meta-vocabulary, and what the broadcast bullet must carry over |
| `15e0900` | The cold review's fixes |

`brief_lessons.md`, in the memory repo, now routes a builder to the sheet.

**Refusals added in `4739007`, all `ArgumentError`:**

- `LimitedIntegrator`, `LimitedDoubleIntegrator` and
  `DiscreteLimitedIntegrator` refuse `lower` not strictly below `upper`, as their
  docstrings said.
- `PID`, `DiscretePID`, `LQRTracker` and `DiscreteLQRTracker` refuse `u_min`
  above `u_max`. Equal limits pass, since `clamp` computes them. A limit given as
  `AsPort()` is skipped.
- `RateLimiter` refuses a `rising` or `falling` that is not positive. Its
  docstring already said positive.

`4739007`'s message says "non-positive rates across the library". It covers
`RateLimiter` only, and section 5.2 holds the rest.

**The `Float64` wording.** `LimitedIntegrator(lower = -1f0, upper = 1f0)` builds
at `Float32`, so "`Float64` or a static array of `Float64`" was false on the
blocks that take `float` of their keywords. They now say "a floating-point type".
`PID` and `DiscretePID` really are `Float64` and kept their wording. The first
bullet of `design/pending.md` makes the promoting blocks `Float64` again, which
restores the old wording. That bullet records this.

## 3. Scope and method

The module exports nothing yet, so no export list exists to audit. The roster was
`docs/src/api.md`, the page the sheet's reader uses. This reaches further than
the sheet's provisional set, which leaves out the extension-only surface.

Six Opus agents worked from `audit_brief.md`, each on its own files, and changed
docstrings and `# Design:` comments only. The coordinator then ran its own checks,
and an independent Opus reviewer read the diffs.

| File | Checked | Changed | As they were |
|---|---:|---:|---:|
| `sim.jl` | 40 | 28 | 12 |
| `declare.jl` | 25 | 25 | 0 |
| `assembly.jl` | 6 | 6 | 0 |
| `build.jl` | 6 | 5 | 1 |
| `descriptor.jl` | 1 | 1 | 0 |
| `devices.jl` | 19 | 11 | 8 |
| `roster.jl` | 7 | 4 | 3 |
| `bindings.jl` | 3 | 3 | 0 |
| `trace.jl` | 1 | 1 | 0 |
| `diagnostics.jl` | 2 | 1 | 1 |
| `model.jl` | 14 | 8 | 6 |
| `deployment.jl` | 3 | 2 | 1 |
| `checkpoint.jl` | 2 | 2 | 0 |
| `frame.jl` | 1 | 1 | 0 |
| `stepper.jl` | 2 | 2 | 0 |
| `leaves.jl` | 1 | 1 | 0 |
| `dataplane.jl` | 4 | 4 | 0 |
| `trim.jl` | 6 | 5 | 1 |
| `readers.jl` | 12 | 7 | 5 |
| `conditions.jl` | 10 | 4 | 6 |
| `linearize.jl` | 5 | 4 | 1 |
| `blocks.jl` | 41 | 32 | 9 |
| **Total** | **211** | **157** | **54** |

The two limited integrators, rewritten by hand, bring the total to 213. The
agents' counts, not the diff, give this table. One agent misstated its totals and
corrected them in its report.

## 4. Verification and its limits

- **Code.** Outside `4739007`, every file's AST matches its base with docstrings
  stripped (`ast_check.jl`). This caught one coordinator slip, where a paragraph
  re-fill swallowed `port`'s closing quotes and the code below them.
- **Citations.** The `§` and `D-` set of each file is unchanged. This compares
  whole files, not single docstrings.
- **Forbidden tokens.** No roster docstring holds `§`, `D-nnn`, a predecessor's
  name or a companion pointer, and no summary reaches twenty words.
- **Documenter.** Green with doctests and cross-references. It caught two
  `artifact` links. The brief told agents to check anchors against the spec, but
  the glossary page skips Appendix D's meta-vocabulary. The sheet now says so.
- **Suites.** The gate passed 8708 of 8708 at `15e0900`. The examples passed 77
  of 77 at `0969a1c`, and later commits changed only docstrings and docs.

**What was not established:**

- The reviewer read every changed docstring. It read about 40 unchanged ones in
  full and scanned the rest, so rule breaks may remain in untouched text.
- Passive voice and paragraph focus were judged from the diffs, not exhaustively.
- No reviewer read `15e0900`. It had only the mechanical checks, the docs build
  and the gate.
- No mutant run covered the new refusals' tests.

## 5. Open decisions

### 5.1 False or imprecise claims

The agents reported these and left them. The reviewer judged each against the
code, and `results/` holds the probe output where a run settled it. Most predate
this work. The replacements are the reviewer's drafts, not yet applied.

| # | Docstring | Verdict | Evidence |
|---|---|---|---|
| 1 | `Unpack` | False | Wire `"src/y" => "un"` throws `UnknownPort` and `UnconnectedInput`; `"un/u"` works |
| 2 | `stale` | False, and imprecise | A device parked in `take!` from `t = 0` showed a 3.93 s lag and read stale |
| 3 | `trim!` | Imprecise | The seeded re-check calls only `_check_equations(:residuals, …)` |
| 4 | `running` | False | `_beat!` is absent from `stop!`, `binding` and `port_views` |
| 5 | `unblock!` | False | A polling loop ended on its own; a blocked one was abandoned at the timeout and its task stayed alive |
| 6 | `Trace` | False | One `attach!` took the schemas from one pair to three |
| 7 | `trace` | Imprecise | A batch at frame 1 with 5 frames stepped gives `frames = 5` |
| 8 | `LQRTracker` | False as a name | `get_state("t", :q)` is refused, and its field is `x`. `DiscreteLQRTracker`'s `q` is real |
| 9 | `Deployment` | Imprecise | The range sentence omits refusals that are not ranges, and no docstring says a float `h` is refused |

**Replacements:**

1. `Unpack`: "A wire names the input `u`, as in `"unpack/u"`."
2. `stale`: "The threshold is deliberately loose, so a device that returns to its
   handle within two seconds between blocking reads is not stale. A device parked
   longer reads stale, which is advisory and stops nothing. A device that has not
   beaten since attach holds `0.0`, which reads stale against any `time()`."
   Spec §12.2 carries the same "must tolerate" wish and may need the same fix.
3. `trim!`: "The second checks the residual and check returns at the guess
   evaluation, and the residual return again at the first seeded one."
4. `running`: "Each call refreshes the device's heartbeat, as `latest`, `pending`,
   `stage!`, `gather`, `report!` and `wait_next_snapshot` do."
5. `unblock!`: "A throw inside `unblock!` itself is logged as a warning. A loop
   still blocked then holds the shutdown until the `join_timeout` of its
   `Simulation`, which abandons the task and reports `DeviceJoinTimeout`."
6. `Trace`: "Every change to the roster appends one pair per current writer, and
   the list only grows."
7. `trace`: "The trace also holds the frame ordinal of the last drain, which every
   frame makes."
8. `LQRTracker`: "The block holds one bare continuous state, `q` below, the field
   `x`, the integral term in output units, one channel per control input."
9. `Deployment`, the `h` bullet: "`h`: the continuous step in seconds, exact as a
   `Rational`, an integer, a `Period` or an `Hz` value, required and refused as
   `DeploymentInvalid` when absent."

   `Deployment`, the range sentence: "A keyword outside its range is refused as
   `DeploymentInvalid`, and so is a `Δt_base` that is not a whole multiple of `h`,
   that disagrees with `N_base`, or that an anchor's period or offset does not
   divide. One throw reports the faults found together."

Two judged fine or left: `Deployment`'s `algorithm` bullet says `RK4` or `Heun`,
which is right for the public surface, and the promoting blocks' mixed-shape
`ErrorException` goes away with the broadcast bullet, so their docstrings need no
sentence now.

### 5.2 Possible code changes

**Time constants go unchecked.** `τ`, `τd` and `Tt` are called positive or
assumed so.

| Value | Result |
|---|---|
| `FirstOrderLag(τ = 0)` | `StepError{NonfiniteState}` at the first step |
| `FirstOrderLag(τ = -1)` | No error, and the output diverges |
| `PID(τd = 0)` | `StepError{NonfiniteState}`, even with `Kd = 0` |
| `PID(τd = -0.05, Kd = 1)` | No error, and `u_raw = 336140` after 5 frames |
| `PID(Tt = 0)` | `StepError{NonfiniteState}` |
| `PID(Tt = -1)` | No error, and `q` drifts |

The recommendation is an `ArgumentError` in the constructors. The check must skip
`AsPort()`, use `all(.>)` over vectors and allow `Tt = Inf`. `DiscretePID`'s
`τd = 0` is legal and documented, and it stays. Without a code change, the
docstrings could say the value is unchecked.

**Value reads on a bad path.**

| Call | Result |
|---|---|
| `port`, unknown path or name | `KeyError`, on model, simulation and snapshot |
| `modes`, no mode store | `MethodError: getindex(::Nothing)` |
| `state` and `modes`, unknown path | `InternalInvariant`, so a typo reads as a framework bug |
| `state`, no state | Returns `nothing` |

Selectors already refuse a bad path as `PathResolution`. The recommendation is
that these reads do the same and say so in one sentence.

### 5.3 Rulings on the sheet

- **A code-named glossary term with no API entry.** `should_abort`, `t*` and
  prose "stop policy" keep their glossary links, though the sheet routes a
  code-named entry through its API link only.
- **One public field.** `ControlRequestedStop`, `LoopError` and `MalformedDatum`
  keep theirs in prose, where a one-bullet list reads badly.
- **Which fields are public.** `Model` lists all of its fields, including
  `exec` and `frame_diag`. `Deployment` and `Schedule` list none, though tests
  read `deployment.h`. `Reads`, `Taps`, `Fragment`, `Scoped` and the `Get*`
  selectors describe theirs in prose.
- **"Leaf" for a condition node.** `set`, `Fragment` and `ConditionNode` say "the
  leaf of a condition". The sheet forbids it, and `g-fragment` itself says "leaf
  node".
- **`ControllerBlock`'s table.** The sheet bans tables for keywords and says the
  REPL mangles them. `PID`, `DiscretePID` and the trackers cite this one.
- **Prose after `# Keywords`.** The audit moved it all above the list, by the
  template. No checklist line covers it, so one may be worth adding.
- **Sibling pointers inside refusal paragraphs.** `stage!(handle)`, `reads(b)` and
  their siblings keep the form, for one voice.
- **Plan methods.** `init!(model, plan)` and `overlay!(model, plan)` state their
  role only in the comment, where line 13 asks for one sentence of prose.
- **Links to "bare" and "entry".** The agents left compounds outside the glossary
  unlinked, as in "bare state" and "bare value". A rule could link them.
- **The value-list form.** `lifecycle`'s state bullets keep two sentences, since
  the one-sentence rule names keywords and fields.
- **Mechanism kept.** `LinearBlock`'s "stages are defined once on the parent",
  the discrete controllers' `s_update` and `y_state` sentences, and `Group`'s
  executor paragraph stayed. A stricter reading of line 22 would move them.
- **Pages.** `LinearizeDual` and `DiagnosticError` are named by docstrings but
  absent from the API page, so they cannot be linked.

### 5.4 Smaller points, left as they were

- `stale`'s summary names the unexported `STALE_S`.
- `TrimProblem`'s "after the simulation has moved" also serves the `Model` method.
- `TrimProblem` says "finite and positive" only of `tolerances`, though
  `_check_tolerances!` applies it to `check_tolerances` too.
- `Deployment`'s "two deployments compare as values" omits that `==` skips the
  build, the grid and the warnings, which is deliberate per its code comment.
- `PIDBlock` says `V` is a `Real` or a static array of them, and `PID` says
  `Float64`. Both hold at different levels.
- `UnitDelay`'s "the store is isbits, which bounds `V`" was not traced.
- `output_passthrough` has no `# Keywords` list and defers to `input_passthrough`.
- `assembly.jl`'s `input_wires` example runs to 84 columns as an unbreakable span.
- `warnings` keeps a passive sentence, shared with its sibling in `deployment.jl`.
- `ws_init`'s "Declaring is allocating" and `Relative`'s "Scope ticks are the unit
  system" are aphoristic.
- `linearize` changed "no compile at the keyboard" to "no compile at the call",
  while `spec.md` and `test_linearize.jl` keep the old phrase.
- `sim.jl`'s comments near `Run` list `init!`, `restore!` and `replay!` as what
  builds a run. `overlay!` does too, and the `Run` docstring says so.
- `devices.jl`'s "framework wrapper" docstring describes `_wrap` but attaches to
  `_unblocks`. Both names are internal.
- Appendix B writes `Simulation(build; kw...)`, and the docstring now names the
  keywords. The sheet would call this a finding against B, though B may stand as
  an inventory.

## 6. Findings closed

**Fixed in `15e0900`, from the cold review:**

- `FrameHooks` read as if `frame!` always returned `true`. The rewrite had changed
  the meaning.
- A move out of `TableBinding` left no docstring saying a binding of your own
  writes `map_input`. `AbstractBinding` now says it.
- `init!`'s "at the bound" lost its antecedent, and now says `log_max`.
- `port(sim, …)` kept the old addressing sentence beside rewritten siblings.
- `Simulation`, `init!` and `run!` held grab-bag paragraphs left by moves.
- `LimitedDoubleIntegrator` lost which leaves each handler writes, and both
  integrators lost "bare" before "mode". The comments and the text now hold them.
- First mentions were linked: `should_abort`, "rostered", "feedthrough" and
  "events".
- The trackers' sentences straddling a code block now take `PID`'s form.
- `input_passthrough` and `output_passthrough` got their wrapped signatures back.
- Three semicolons and one passive went.
- `x_init`, `s_init` and `m_init` now return `NamedTuple, value or nothing`.

**Fixed while committing the audit:**

- `y_state`, `y_direct`, `x_deriv` and `s_update` said `-> NamedTuple`, though
  each also returns a bare value.
- `port`, `state` and `modes` took their method's form and `-> Any`.
- Six `sim.jl` docstrings and `stale` held prose after `# Keywords`, which moved
  above the list.

**Added by agents and reviewed as true:** `ws_init -> Any`, the wire functions'
`-> collection of Pair`, and `condition -> ConditionNode`. `condition`'s generic
has no methods, so its type comes from the prose. All are easy to revert.

Four block docstrings gained `# Keywords` lists copied from the siblings their
prose defers to: `DiscreteStateSpace`, `DiscreteTransferFunction`,
`DiscretizedStateSpace` and `DiscretizedTransferFunction`.
