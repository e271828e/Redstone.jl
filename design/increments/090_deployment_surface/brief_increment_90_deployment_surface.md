# Brief: increment 90, the deployment surface

One docs commit, one commit of this brief and the patch, one code commit
applied from the prototype, one cold review and a fixer if the review needs
one. Drafted on 2026-11-10 at c16c8a2 and landed after the docs commit
231869d, which touches nothing under `src/`, `test/` or `examples/`, so
every line range below still reads from `git show c16c8a2:file`. The
prototype is the implementation, built by a high-tier agent on a scratch
worktree detached at c16c8a2 under a peer session. This session adopted it,
re-ran the gate and the Documenter build on its own copy of the worktree,
and coordinates the rest. The patch lands as `prototype_increment_90.patch`
beside this brief, the prototype's diff from c16c8a2 as it was built. The
docs commit took its `spec.md`, `log.md` and `tools/row_baseline.txt` hunks
with the one amendment reading 9 names; the code commit takes its `src/`,
`test/`, `examples/`, `README.md` and `code_map.md` hunks. The user was
present: the rulings below are theirs, taken in the session of 2026-11-10.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The first of the five increments of `roadmap_variable_step.md`, under the
`pending.md` bullet "Variable-step integration". The roadmap's settled
bullets "Three quantities", "Ownership" and "Fixed-step divisibility" land
here in the spec and the log, docs commit first.

- **Three time quantities.** `Δt_frame`, the frame period, required and
  owned by the `Deployment`; `Δt_base`, the base lattice, defaulting to
  `Δt_frame`; `h`, the method's step, carried by the algorithm instance.
  `N_base` retires everywhere. New entry D-443; D-234 superseded by it.
- **The method is selected by instance.** `algorithm = RK4(h)`, with
  `RK4()` the default and its step resolved to `Δt_frame`. The deployment
  stores the resolved instance, so `RK4()`, `RK4(Δt_frame)` and
  `RK4(Hz(…))` deploy as one value. New entry D-442, landing the instance
  form D-227 deferred; D-227 superseded by it.
- **Fixed-step divisibility.** A fixed step divides `Δt_frame` and, when the
  tree has discrete components, `Δt_base`; refused as `DeploymentInvalid`
  with reason `:not_harmonic` otherwise.
- **Until increment 2, one step per frame and ticks on frame tops.** §10.4
  and §10.5 still say so, so §9.2 states two refusals as their
  consequence: `(:h, :subcycling)` for a step that divides the frame but
  is shorter, and `(:Δt_base, :not_frame_multiple)` for a base lattice off
  the frame tops. Increment 2 lifts both when it rewrites those sections.
  The log carries neither.
- **Annotations.** D-133, D-254, D-256 and D-283 annotated; `check_rows`
  re-baselined, since superseding D-227 drops its row (227 out, 439 to 443
  in).

## The shape built

Line ranges from `git show c16c8a2:file`.

- `src/deployment.jl`:
  - a section "the integration algorithm" before "the artifact" at 289:
    `abstract type AbstractAlgorithm`, the tokens `RK4` and `Heun` with one
    field `h::Union{Nothing,Rational{Int}}`, constructors from nothing, an
    integer or rational, and a `Period`; a float refused eagerly as
    `ArgumentInvalid(call = :RK4, reason = :inexact)`, as `Period` refuses
    one. `show` prints `RK4(1//100)` by `nameof`. `==` and `hash` are the
    defaults, probed equal across spellings.
  - `bind_schedule`, 175–287: takes `(build, Δt_frame, Δt_base, algorithm,
    diags)`; checks `Δt_frame` for `:missing`, exactness and `:range`;
    resolves the step; takes `Δt_base` explicit, defaulted or `:derive`;
    adds the lattice checks above; returns the resolved token and
    `frames_per_tick`. The `N_base` path and `:disagrees_with_n` go.
  - `Deployment`, 291–413: fields `Δt_frame`, `Δt_base`, `algorithm::
    AbstractAlgorithm`, the event parameters, `schedule`, `grid`,
    `frames_per_tick::Int`, `warnings`. `==` and `hash`, 415–428, exclude
    `frames_per_tick` as they exclude `grid`.
- `src/stepper.jl`: the runtime types renamed `RK4Stepper{T}` (47–67) and
  `HeunStepper{T}` (91–110), unexported; `bind_stepper(token, T, n_x)`
  replaces the `(T, n_x)` constructors. `integrate!` bodies untouched.
- `src/build.jl` 1607: `bind_stepper(algorithm, T, n_x)`.
- `src/frame.jl`: 62 steps by `Δt_frame`, 65–66 key ticks on
  `frames_per_tick`, 229–233 reference the tolerance to `Δt_frame`.
  `frame!`'s behavior unchanged.
- `src/model.jl` and `src/sim.jl`: the sugar constructors collapse to a
  `kw...` passthrough, leaving one keyword list, on `Deployment`; `.h`
  reads become `.Δt_frame` (model.jl 6 sites, sim.jl 8).
- `src/show.jl` 255–257, `src/checkpoint.jl` 172–183 (the walk names six
  parameters, the algorithm as one value), `src/diagnostics.jl`
  (`DeploymentInvalid` reasons and messages, `quotient` field gone;
  `ArgumentInvalid`'s `:RK4`/`:Heun` arm), `src/precompile.jl` 43 and 51.
- Tests: 28 files under `test/`, by a migration script (836 `h =` sites to
  `Δt_frame =`, 14 `algorithm = RK4` to `RK4()`) and hand edits (33
  `N_base` sites, 29 `deployment.h` reads, `test_trace.jl`'s walk
  assertions). `examples/test/test_longitudinal.jl` and `README.md`'s
  quick start.
- Docs: §2.2, §8, §9.2, §10.2, §10.4, §10.5, §11.5, §12.7, §13.5,
  Appendices B, C and D; D-442 and D-443; `code_map.md`'s deployment.jl,
  stepper.jl and frame.jl entries; `tools/row_baseline.txt`.

## Measurements

- **Bit-identity.** Five runs against a `git archive` of c16c8a2, old
  keywords there and new here: feedback under RK4 and Heun over 200
  frames, `MultiRate` at `N_base = 2`, the localized `Bouncer`, `Sawtooth`
  at `N_base = 2`. `repr(logged(sim))`, frame counts, the clock (`===`)
  and `xbuf` all equal. The pinned bitwise testsets pass.
- **Allocations.** No new figure: `frame!` reads two concrete fields in
  place of two others. The existing zero-allocation pins pass in the gate.
  Compile latency not measured; no loop signature changed.
- **Gate.** The prototype's full gate under the sandbox flags: 9556 pass,
  3 fail, 2 error, all in `test_trace.jl` on the old `:h` walk name, fixed
  there. The coordinator's re-run of the whole patch on its own copy of
  the worktree: 9576 pass of 9576 in 9m10s, on Julia 1.13.3. The
  Documenter build ran clean there, doctests included.
- **Examples.** `Longitudinal` 77/77.
- **Battery.** Green at the docs commit.

## Readings the prototype took

Every reading was put to the user on 2026-11-10 and ratified.

1. **Two types per backend.** The token `RK4(h) <: AbstractAlgorithm`, the
   public docstring, and the runtime `RK4Stepper{T} <: AbstractStepper`,
   internal, joined by `bind_stepper`. Rejected: one parametrized type
   (empty scratch fields or a `Nothing` parameter every comparison must
   skip), the step as a keyword beside a type token (meaningless to an
   adaptive backend), a required step (spells the frame twice), a callable
   token.
2. **A float step is refused at the token**, as `Period`, `Hz` and
   `Absolute` refuse one; a step at or below zero is collected at the
   deployment as `(:h, :range)`, one throw under D-229.
3. **The transitional refusals are spec, not a deviation.** §9.2 states
   them as consequences of §10.4 and §10.5, which still fix one step per
   frame. A `pending.md` deviation bullet would leave §9.2 contradicting
   §10.4 for an increment.
4. **`frames_per_tick` is a derived field on `Deployment`**, exact from the
   rationals, read only by `frame!`, compared nowhere. Three test lines
   read it; increment 2 deletes it with its lattice type.
5. **A base lattice off the frame tops with discrete work present raises
   two faults**, `:not_frame_multiple` and `(:Δt_base, :not_harmonic)`.
   Both are true; D-229 lists every fault.
6. **`:not_harmonic` is reused for the fixed-step relation**, the failing
   period as `parameter` and `related = h`, rather than a new reason.
7. **An old `h =` keyword fails as Julia's unsupported keyword**, with no
   migration refusal; the package is unreleased and exports nothing. An
   old `algorithm = RK4` is `(:algorithm, :range)` and the message names
   `RK4()`.
8. **`Δt_base`'s derivation stays the explicit `:derive`**; silence now
   means `Δt_frame`, the value `N_base = 1` gave, so no schedule moves.
   D-283 annotated, not superseded.
9. **D-443 states no transitional refusal**, the coordinator's amendment to
   the prototype's entry. The two refusals exist because of build order,
   which `log_rules.md` rule 9 keeps out of the log; left in the Position,
   increment 2 would have to annotate a design entry only because the code
   caught up. §9.2 and Appendix C state them.

## What the tests pin, by property

- **The method is a deployment binding by instance, `RK4()` the default**
  (§10.2, D-442), `test_stepper.jl`: the runtime types; the resolved token;
  spellings equal and hash-equal, unequal to `Heun`; the float refusal;
  `(:algorithm, :range)` for `4`, `Int`, `RK4` and `Heun` as types;
  `repr`. Storing the unresolved token, and an `==` that ignores the
  algorithm, turn it red.
- **A fixed step divides the frame and the base tick, and is the frame for
  now** (§9.2, §10.2, D-443), `test_stepper.jl`: each fault with its
  payload; the fault sets with and without discrete work. Dropping the
  discrete condition, and dropping the subcycling refusal, turn it red.
- **Two deployments compare as values** (§9.2), `test_discrete.jl`:
  `Δt_base` and `Δt_frame` each sever equality.
- **`Δt_base` has three sources** (§9.2, D-283, D-443), `test_discrete.jl`:
  the default equals the spelled `Δt_frame`; the refusal table on
  `Δt_frame`; the off-frame pair; the premises' independence. A default of
  `2·Δt_frame` turns it red with 28 failures.
- **The header is compared over the new set** (§12.7), `test_trace.jl`: a
  frame change reports `:Δt_frame`, `:Δt_base` and `:algorithm`; `Heun()`
  alone one `:algorithm` mismatch. A walk that drops `:algorithm` turns it
  red.
- **The new messages render** (Appendix C), `test_diagnostics.jl`: the first
  lines of `:not_harmonic`, `:subcycling` and `:not_frame_multiple`. The
  dropped-arm mutant was reasoned, not run.

## Bookkeeping

- The docs commit, beside the spec and the log: `roadmap_variable_step.md`,
  increment 1's line corrected (the descriptor item is empty, two log
  entries rather than one, the wider spec reach, 28 test files rather than
  29); the retired keywords swept from `companions/flight_case_studies.md`,
  `companions/sample_time_proposal.md` and
  `companions/trim_environment_walkthrough.md`.
- The code commit, beside the patch's code half:
  - `pending.md`: the variable-step bullet records increment 1 as landed
    and names what increment 2 lifts; the inspector's bullet names its six
    `h =` sites.
  - `code_map.md`: the deployment.jl, stepper.jl and frame.jl entries, the
    transitional refusals citing §9.2.
  - `rules/code_rules.md`: the two lines that named `t₀ + k * h` and
    `N_base`.
  - `companions/frame_walkthrough.md`: the six lines that quote `frame!`.

## Out of scope

- Subcycling, off-frame base lattices and the `localization_tol`
  re-reference: increment 2.
- A strict D-229 `bind_schedule`, where a step fault no longer skips the
  anchor loop: the increment 2 rewrite.
- A per-backend step resolution: `bind_schedule` reads the token's `h` and
  rebuilds the token from it, which holds for the two fixed-step backends.
  Increment 4's adaptive token has no `h`.
- The inspector's six `h =` construction sites (README 19 and 39,
  `test/test_server.jl` 74, `test/runtests.jl` 64, `scripts/fixtures.jl`
  58 and 66): they break at its next pin on the core, with the
  `"primitive"` rename already waiting there.
- The descriptor: its deployment body is the build body alone, so no
  format change.

## The cold review

An independent high-tier agent over the whole increment at the code
commit's tip: the full gate on the floor `Project.toml` declares; the
Documenter build; each new testset reverted alone on a scratch copy; the
bit-identity probe re-run against c16c8a2 outside the tree; the dropped-arm
rendering mutant; a grep for every surviving `N_base`, `.h` field read and
`h =` keyword across `src/`, `test/`, `examples/`, `docs/`, `README.md`,
the spec and the companions; D-442 and D-443 against `log_rules.md`; the
new docstrings against `docstring_rules.md`. "Empty is acceptable."

## The review's record

The cold review ran at 029cbab, an independent high-tier agent, and found
no correctness bug. The fixes landed as 23a82ab, built by the coordinator,
and the reviewer verified the delta with its context intact.

- **Gate.** 9576 of 9576 at 029cbab on Julia 1.13.3, the floor, against
  9540 at c16c8a2; the per-file totals are equal but for diagnostics (995
  to 1013), stepper (17 to 33) and trace (576 to 578), so no file lost an
  assertion. 9581 of 9581 at the fixes, the coordinator's run. The
  Documenter build clean and the examples 77 of 77, both times.
- **Bit-identity.** Ten runs against a `git archive` of c16c8a2, byte for
  byte on the frame index, the clock's bits, `xbuf` and `repr(logged(sim))`:
  the feedback model under RK4 and Heun, `MultiRate` at two and at five
  frames per tick, the localized `Bouncer` under both methods, a sampled
  loop at two and at three frames per tick, `Sawtooth` with a `Stamper`,
  and a `Dual` model over 50 frames.
- **Findings, all fixed in 23a82ab.**
  1. `CheckpointMismatch`'s deployment message counted seven parameters
     where the walk names six. Corrected and pinned.
  2. No test read the `RK4` float-step message. One rendering assertion.
  3. No test caught `Model(build; chunk_size)` dropping the keyword. One
     assertion beside the `Simulation` twin's.
  4. `bind_schedule` returns ahead of the anchor loop on a lattice or step
     fault, short of D-229. The code stays, by this brief's scope;
     `pending.md`'s deviation list records it for increment 2's rewrite.
  5. `RK4(1//0)` drew a false `:subcycling`, and `Δt_frame = 1//0` a raw
     `DivideError`, the second older than the increment. Both periods are
     now refused as `:range` unless positive and finite, §9.2's list and
     the message saying so. The reviewer had proposed a guard on the
     subcycling test and judged the range rule the better fix.
  6. Stale `h` as the deployment's parameter: §2.4's list, one sentence of
     §12.6, `docstring_rules.md` rule 14 and two `code_map.md` lines.
  7. Docstrings: `Deployment`'s summary at 21 words, the `RK4` and `Heun`
     signature lines without return types, `Δt_frame` unlinked in seven
     docstrings, and `RK4`'s silence on the interim refusal.
- **Mutants.** 22 in the first round, 19 killed. M08, the dropped
  `RK4`/`Heun` message arm, and M14, the dropped `chunk_size`, survived as
  missing tests; the fixes pin both, and both die in the second round. M20,
  the early return removed, survives and is acceptable: it is the strict
  D-229 form of finding 4. The brief's unrun dropped-arm mutant was run
  and dies. In the second round the two `isfinite` mutants and the count
  mutant die; a mutant on the wording "positive and finite" survives and is
  acceptable, message text being pinned in the rendering testset alone.
- **Handed to increment 2.** `Δt_base` has no range check of its own: a
  zero, negative or infinite value is refused only through
  `:not_frame_multiple`, which that increment lifts. The `pending.md`
  bullet names it.
- **Not done.** Compile latency and a separate allocation probe: no loop
  signature changed, and the gate's allocation pins pass.
- **After the delta check.** Three docstring passages of `deployment.jl`
  rewrapped, text unchanged, with this record.
