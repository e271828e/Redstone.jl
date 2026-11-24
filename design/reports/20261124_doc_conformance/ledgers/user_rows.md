# Rows for the user

The audit's rows that wait on a ruling, by group. Each names the ledger row,
which holds the evidence and the proposed fix. Wording rows are drift or
deviations whose new text has more than one form. Defects are proposed with
the verifier's probe.

## G1a

- **S13b-205, wording.** §13.5's fixed order of stop sources is false at one
  boundary: requests are read at the publication, before the next frame top.
  Recommended: the verifier's text. Same topic as G1b's CV2-056.
- **S13c-213, wording.** §13.8's "evaluated once": a member whose global trace
  meets an undecidable branch is re-run at sampled states. Recommended: the
  verifier's text.
- **S13c-219, wording.** §13.8's "no layouts": `_classify` builds the nominal
  cell layout. Recommended: drop "no layouts".
- **S13a-040 with L13-017, defect.** Three tests assert message text against
  §13.2 and D-058. Recommended: move them into the rendering testset.
- **S13c-031, defect.** A hanging `unblock!` is not bounded by the join
  timeout. Recommended: run each `unblock!` on its own task within the deadline.
- **S13d-133, defect.** The descriptor writes no `function` for
  `BundleFieldError`. Recommended: add the `_function` method and a test, after
  checking the schema allows it.

## G1b

- **CV2-056, wording.** Same as S13b-205, seen from `src/sim.jl:2090`.
- **C1-047, wording.** Appendix C's "Declaration and wiring" group holds kinds
  that the cell layout and the probe raise, not the structure step alone.
- **C2-073, wording.** A binding kind's payload is the binding type and a
  `reason`, not the trait, method and direction.
- **C2-139, wording.** `UninitializedInputs` is listed as collected; the code
  raises one fail-fast diagnostic naming every uncovered face.
- **CV1-011 and CV1-025, citations.** diagnostics.jl:89 cites D-058 for the
  carrier, which D-222 replaced. :204 cites D-214 for plain `Float64` time
  payloads, which D-214 does not treat.
- **CV1-034, wording.** §13.4 omits `StepError`'s reproduction recipe for the
  `restore!` host and the interrupt's resuming door.
- **CV2-041, wording.** `ignore_stop_requests` reads each element through
  `string`, so a Symbol names a path. The spec and docstring say paths.
- **CV1-147, defect.** BS3's `:range` refusal renders through
  `ArgumentInvalid`'s `t_plus` arm. Recommended: a message arm for `:BS3`.
- **CV2-023, defect.** The global tracer's `Float64` conversion throws
  `Undecidable` on any tracer, though the docstring says only on a tagged
  operand. Recommended: decide through `_decide`, as `Int` and `Bool` do.
- **CV2-026, held.** A D-166 citation in tracer.jl, left to the CIT-D166
  finding.
- **CV2-030, unmarked rule.** The fixer added §13.8's 64-face limit on
  per-member tracing as an unmarked sentence: no entry rules it, and none was
  rejected. Like the trial's two sentences, it stays unmarked unless you want
  an entry.

## G2, §8

- **K8-027 and K8-046, wording.** The migration outline's counts: "roughly
  half of Flight.jl's type inventory" needs genericity (the verifier counts
  about a quarter of FlightPhysics' structs), and "about 7" scheduler
  components (the verifier counts about 10).
- **S8b-182, wording.** §8.2's `Pinned` hint names `F`; the message names the
  leaf. D-286 backs the doc's text, and L8b-070 repeats it in the log.
- **S8c-047, wording.** §8.2 lists `x_projection` among the continuous-only
  declarations checked in the structure step; the verifier's text names
  `m_init` and `state_events` instead.
- **S8c-106, wording.** §8.4's typo'd-wire message differs from the code's.
- **S8c-174, defect.** Two transparent containers on one type are said to be
  a declaration error; `_check_transparent` accepts a return naming several
  fields. Proposed: refuse it with a collected diagnostic. The doc-side option is CV8-048:
  a type names at most one, since the declaration returns one name.
- **S8d-042, defect.** "A face name contains no `/`" is said to be checked;
  `check_contract_names` lets a contract key with `/` through. Proposed:
  refuse it as `FaceNameIllegal` with invariant `:contains_slash`.
- **S8d-003, gap.** The shared path form across the HDF5 log tree is owed by
  `pending.md`; no action.

## G3, §9

- **S9a-029, S9a-039 and S9a-051, wording.** §9.1: materialization runs the
  `*_init` bodies and an activation, not "no user code"; the structure walk's
  five steps run in another order; the did-you-mean list holds the endpoint's
  faces, inputs and outputs alike.
- **S9b-112, wording.** §9.2: the refusal covers any value that is not an
  algorithm token, not an algorithm the seam does not know.
- **S9c-055, wording.** §9.4: after pre-materialization each lookup still
  takes the build's lock. D-135 backs the doc's text. (S9c-067 landed as
  G3b's CV9a-017.)
- **S9c-062, wording.** §9.4's reason the bare `Dual` is refused. D-099
  backs the doc's text.
- **S9c-139 and S9c-186, wording.** §9.5: struct-valued ports embed leaf by
  leaf, and the handler key check reuses the did-you-mean shape, not the
  `FieldError` machinery. D-287 backs the doc's text.
- **S9c-154, wording.** The `Pinned` hint again; rule it with S8b-182.
- **S9d-057, wording.** §9.7's compile-cost figures no longer match the
  measurements.
- **S9b-300, defect.** §9.3 says everything the probe writes is garbage
  after the build, but `init!` of a model at a non-nominal scalar leans on
  it. Proposed: establish the frozen discrete cells from a nominal round, as
  the services' seeded half does.
- **S9d, a thin inventory.** Its mid-tier inventory missed 3 of 9 sampled
  rows. A high-tier re-inventory of §9.7 and §9.8 is in G4b's args as S9d2.
- **CV9a-049, wording.** §9.3's probe-scoped values: `compile` seeds every
  fresh table from the probe's values. Rule it with S9b-300.
- **CV9a-050, wording.** Appendix C and D-431 say a misshapen return throws
  alone; that holds for the port check only.
- **CV9b-049, wording.** The scalar refusal is not always alone and before
  the keywords are read. D-320 backs the doc's text.
- **K9b-014, K9b-027, K9b-041 and K9b-052, wording.** The two walkthroughs:
  a loop closed through B is schedulable only through `y_state`; pinning the
  deck's output would also need a stripping stage; the grid copy is kept off
  by the shape rule, not D-263; `Freeze` cannot take a handle, its `V` being
  bounded at the type.

## G4, §10

- **S10b-224, wording.** §10.4's chattering example: the code keeps a
  latching predicate ungated on the mode, and gating it would chatter.
- **S10d-054, defect.** §10.7 says `margin = 2 ms` sleeps about 90% of a
  20 ms budget and lands within µs of the deadline. The coarse phase now
  overshoots more. Proposed: recalibrate the default to about 3 ms, after a
  measurement on the dev machine.
- **CV10-221, wording.** The `ExecutionCursor` docstring's account of when
  the cursor is written and read misses one store.
- **CV10-263, wording.** A named discrete store whose `s_update` returns the
  right field names with a wrong value type reports `:field_set`; Appendix C
  does not say so.
- **K10b-043, wording.** The limited-integrator companion's trial count for
  the minmax projection: about ITP's worst case, 21 or 22, not bisection's.
- **S9d2-042, wording.** §9.7 says `rhs` takes no index; it has a one-arg
  form that walks the same entries. D-147 backs the doc's text.
- **S9d2-074, wording.** §9.7 says `-O0` trajectories differ from `-O2`'s;
  the code shows they can, not that they must. D-289 backs the doc's text.
- **S9d2-107, gap.** The scheduled `GC.gc(false)` at frame boundaries is
  owed by `pending.md`; no action.
- **S10a-064, bold ruling.** §10.2's bold span says the distance is taken in
  equal steps "no longer than" the proposal. The code caps the count at
  `⌊r / h_min⌋`, so near `h_min` a step can be longer. The fixer added an
  unbolded sentence saying so; the bold ruling itself is yours to reword.

## G5, §11 and §12

- **K11b-023, K11b-137 and K11b-138, wording.** The inbound walkthrough's
  `RosterEntry` sketch has the wrong fields, and it says `run!` bakes widget
  liveness and specializes the drain; the GUI's loop bakes liveness through
  `port_views`, and the drain is compiled at the attach points and the door.
- **K11b-027, wording.** `attach!`'s order is identity, then face names,
  then claims; the walkthrough puts face names first. D-216 backs it.
- **K11b-082, wording.** The walkthrough says the drain is a known tuple with
  no dynamic dispatch; it iterates a vector of thunks, one dispatch each.
  D-374 makes the tuple a freedom, not an obligation.
- **S11a-185, wording.** §11.1 says pre-materialized workers synchronize on
  nothing; each activation lookup takes the build's lock. Rule it with
  S9c-055.
- **S11c-089, defect.** `BindingContractMismatch` messages do not name the
  `is_input` and `is_output` traits, as §11.6 says every violation report
  does. Proposed: name both traits in the `:neither_side`, `:claims_missing`
  and `:reads_missing` messages.
- **S11b-032 and S11c-107, gap.** The greedy standard GUI binding is owed by
  `pending.md`; no action.
