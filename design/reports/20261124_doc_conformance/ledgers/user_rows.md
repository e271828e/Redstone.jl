# Rows for the user

The audit's rows that wait on a ruling, by group. Each names the ledger row,
which holds the evidence and the proposed fix. Wording rows are drift or
deviations whose new text has more than one form. Defects are proposed with
the verifier's probe.

## G1a

- **S13b-205, wording.** §13.5's fixed order of stop sources is false at one
  boundary: requests are read at the publication, before the next frame top.
  Recommended: the verifier's text. Same topic as G1b's CV2-056. Settled,
  `cdf92a7f`.
- **S13c-213, wording.** §13.8's "evaluated once": a member whose global trace
  meets an undecidable branch is re-run at sampled states. Recommended: the
  verifier's text. Settled, `a991af00`.
- **S13c-219, wording.** §13.8's "no layouts": `_classify` builds the nominal
  cell layout. Recommended: drop "no layouts". Settled, `a991af00`.
- **S13a-040 with L13-017, defect.** Three tests assert message text against
  §13.2 and D-058. Recommended: move them into the rendering testset. Settled,
  `8b8ab49f`. `discard_reports` in test_trace.jl stays, since a discard past the
  final frame top reaches only the log.
- **S13c-031, defect.** A hanging `unblock!` is not bounded by the join
  timeout.
- **S13d-133, defect.** The descriptor writes no `function` for
  `BundleFieldError`. Recommended: add the `_function` method and a test, after
  checking the schema allows it. Settled, `dc884b91`.

## G1b

- **CV2-056, wording.** Same as S13b-205, seen from `src/sim.jl:2090`.
  Settled, `cdf92a7f`.
- **C1-047, wording.** Appendix C's "Declaration and wiring" group holds kinds
  that the cell layout and the probe raise, not the structure step alone.
  Settled, `a991af00`.
- **C2-073, wording.** A binding kind's payload is the binding type and a
  `reason`, not the trait, method and direction. Rule it with S11c-089: §11.6
  states what that defect asks of the code. Settled, `d6636cb0`.
- **C2-139, wording.** `UninitializedInputs` is listed as collected; the code
  raises one fail-fast diagnostic naming every uncovered face. Settled,
  `cdf92a7f`.
- **CV1-011 and CV1-025, citations.** diagnostics.jl:89 cites D-058 for the
  carrier, which D-222 replaced. :204 cites D-214 for plain `Float64` time
  payloads, which D-214 does not treat. Settled, `608662ac`.
- **CV1-034, wording.** §13.4 omits `StepError`'s reproduction recipe for the
  `restore!` host and the interrupt's resuming door. Settled, `a991af00`.
- **CV2-041, wording.** `ignore_stop_requests` reads each element through
  `string`, so a Symbol names a path. The spec and docstring say paths. Ruled
  2026-11-25: doc and code both stay.
- **CV1-147, defect.** BS3's `:range` refusal renders through
  `ArgumentInvalid`'s `t_plus` arm. Recommended: a message arm for `:BS3`.
  Settled, `fddc0c70`.
- **CV2-023, defect.** The global tracer's `Float64` conversion throws
  `Undecidable` on any tracer, though the docstring says only on a tagged
  operand. `Int` and `Bool` accept an untagged one. Held: a test of
  test_build.jl, from `a5ecf7f5`, pins the refusal on an untagged operand, since
  the value would leave the trace, and no entry backs either side. Caution: do
  not take this row as a clear fix. The session of 2026-11-25 did, and found the
  test only when it failed. The case for accepting an untagged operand, that an
  empty set has nothing to lose, is an argument no probe has tried to break. The
  probe in `probes/user_rows/` shows only what the refusal costs, a member
  traced at sampled states. Before reversing the test, look for a value that
  reaches the conversion untagged and still depends on an in-cycle input.
- **CV2-026, held.** A D-166 citation in tracer.jl, left to the CIT-D166
  finding.
- **CV2-030, unmarked rule.** The fixer added §13.8's 64-face limit on
  per-member tracing as an unmarked sentence: no entry rules it, and none was
  rejected. Like the trial's two sentences, it stays unmarked unless you want an
  entry. Ruled 2026-11-25: it stays unmarked.

## G2, §8

- **K8-027 and K8-046, wording.** The migration outline's counts: "roughly
  half of Flight.jl's type inventory" needs genericity (the verifier counts
  about a quarter of FlightPhysics' structs), and "about 7" scheduler
  components (the verifier counts about 10). Settled, `479ceea1`: both
  estimates deleted.
- **S8b-182, wording.** §8.2's `Pinned` hint names `F`; the message names the
  leaf. D-286 backs the doc's text, and L8b-070 repeats it in the log.
  Settled, `a991af00`.
- **S8c-047, wording.** §8.2 lists `x_projection` among the continuous-only
  declarations checked in the structure step; the verifier's text names
  `m_init` and `state_events` instead. Settled in the code,
  `7a300b9d`.
- **S8c-106, wording.** §8.4's typo'd-wire message differs from the code's.
  Settled, `cdf92a7f`.
- **S8c-174, defect.** Two transparent containers on one type are said to be a
  declaration error; `_check_transparent` accepts a return naming several
  fields. Proposed: refuse it with a collected diagnostic. The doc-side option
  is CV8-048: a type names at most one, since the declaration returns one name.
  Settled both ways, `57acc74a`: CV8-048's sentence, and the refusal.
- **S8d-042, defect.** "A face name contains no `/`" is said to be checked;
  `check_contract_names` lets a contract key with `/` through. Proposed: refuse
  it as `FaceNameIllegal` with invariant `:contains_slash`. Settled, `7e7b5da4`.
- **S8d-003, gap.** The shared path form across the HDF5 log tree is owed by
  `pending.md`; no action.

## G3, §9

- **S9a-029, S9a-039 and S9a-051, wording.** §9.1: materialization runs the
  `*_init` bodies and an activation, not "no user code"; the structure walk's
  five steps run in another order; the did-you-mean list holds the endpoint's
  faces, inputs and outputs alike. Settled, `a991af00`.
- **S9b-112, wording.** §9.2: the refusal covers any value that is not an
  algorithm token, not an algorithm the seam does not know. Settled,
  `21c08c17`.
- **S9c-055, wording.** §9.4: after pre-materialization each lookup still
  takes the build's lock. D-135 backs the doc's text. (S9c-067 landed as
  G3b's CV9a-017.) Settled, `a991af00`.
- **S9c-062, wording.** §9.4's reason the bare `Dual` is refused. D-099
  backs the doc's text. Settled, `a991af00`.
- **S9c-139 and S9c-186, wording.** §9.5: struct-valued ports embed leaf by
  leaf, and the handler key check reuses the did-you-mean shape, not the
  `FieldError` machinery. D-287 backs the doc's text. Settled, `a991af00`.
- **S9c-154, wording.** The `Pinned` hint again; rule it with S8b-182.
  Settled, `a991af00`.
- **S9d-057, wording.** §9.7's compile-cost figures no longer match the
  measurements. Settled, `479ceea1`.
- **S9b-300, defect.** §9.3 says everything the probe writes is garbage
  after the build, but `init!` of a model at a non-nominal scalar leans on
  it. CV9a-049 waits on it.
- **S9d, a thin inventory.** Its mid-tier inventory missed 3 of 9 sampled
  rows. A high-tier re-inventory of §9.7 and §9.8 is in G4b's args as S9d2.
  Settled: S9d2 ran with G4b and missed none of its 10 sampled rows.
- **CV9a-049, wording.** §9.3's probe-scoped values: `compile` seeds every
  fresh table from the probe's values. Rule it with S9b-300.
- **CV9a-050, wording.** Appendix C and D-431 say a misshapen return throws
  alone; that holds for the port check only. Settled, `a991af00`.
- **CV9b-049, wording.** The scalar refusal is not always alone and before
  the keywords are read. D-320 backs the doc's text. Settled, `cdf92a7f`.
- **K9b-014, K9b-027, K9b-041 and K9b-052, wording.** The two walkthroughs:
  a loop closed through B is schedulable only through `y_state`; pinning the
  deck's output would also need a stripping stage; the grid copy is kept off
  by the shape rule, not D-263; `Freeze` cannot take a handle, its `V` being
  bounded at the type. Settled, `a991af00`, except K9b-041, which waits on
  S6c-001 and S6c-004.

## G4, §10

- **S10b-224, wording.** §10.4's chattering example: the code keeps a
  latching predicate ungated on the mode, and gating it would chatter.
  Settled, `a991af00`.
- **S10d-054, defect.** §10.7 says `margin = 2 ms` sleeps about 90% of a
  20 ms budget and lands within µs of the deadline. The coarse phase now
  overshoots more.
- **CV10-221, wording.** The `ExecutionCursor` docstring's account of when
  the cursor is written and read misses one store. Settled, `a991af00`.
- **CV10-263, wording.** A named discrete store whose `s_update` returns the
  right field names with a wrong value type reports `:field_set`; Appendix C
  does not say so. Settled in the code, `06a2e8fa`: a successor pairs
  by name (D-151), and the reasons name the fields.
- **K10b-043, wording.** The limited-integrator companion's trial count for
  the minmax projection: about ITP's worst case, 21 or 22, not bisection's.
  Settled, `a991af00`.
- **S9d2-042, wording.** §9.7 says `rhs` takes no index; it has a one-arg
  form that walks the same entries. D-147 backs the doc's text. Settled,
  `a991af00`.
- **S9d2-074, wording.** §9.7 says `-O0` trajectories differ from `-O2`'s;
  the code shows they can, not that they must. D-289 backs the doc's text.
  Settled, `a991af00`.
- **S9d2-107, gap.** The scheduled `GC.gc(false)` at frame boundaries is
  owed by `pending.md`; no action.
- **S10a-064, bold ruling.** §10.2's bold span says the distance is taken in
  equal steps "no longer than" the proposal. The code caps the count at
  `⌊r / h_min⌋`, so near `h_min` a step can be longer. The fixer added an unbolded
  sentence saying so; the bold ruling itself is yours to reword. Settled,
  `608662ac`: the bold ends at "equal steps".

## G5, §11 and §12

- **K11b-023, K11b-137 and K11b-138, wording.** The inbound walkthrough's
  `RosterEntry` sketch has the wrong fields, and it says `run!` bakes widget
  liveness and specializes the drain; the GUI's loop bakes liveness through
  `port_views`, and the drain is compiled at the attach points and the door.
  Settled, `a991af00`.
- **K11b-027, wording.** `attach!`'s order is identity, then face names,
  then claims; the walkthrough puts face names first. D-216 backs it. Settled,
  `a991af00`.
- **K11b-082, wording.** The walkthrough says the drain is a known tuple with
  no dynamic dispatch; it iterates a vector of thunks, one dispatch each.
  D-374 makes the tuple a freedom, not an obligation. Settled, `a991af00`.
- **S11a-185, wording.** §11.1 says pre-materialized workers synchronize on
  nothing; each activation lookup takes the build's lock. Rule it with
  S9c-055. Settled, `a991af00`.
- **S11c-089, defect.** `BindingContractMismatch` messages do not name the
  `is_input` and `is_output` traits, as §11.6 says every violation report does.
  Proposed: name both traits in the `:neither_side`, `:claims_missing` and
  `:reads_missing` messages. C2-073 waits on it: Appendix C and §11.6 promise
  the trait, the method and the direction. Settled, `d6636cb0`.
- **S11b-032 and S11c-107, gap.** The greedy standard GUI binding is owed by
  `pending.md`; no action.
- **K11-002, wording.** The flight case studies say gain trajectories show
  in the log, the trace and replay; the trace holds only the drained writes,
  and replay recomputes the gains from it. Settled, `a991af00`.
- **S12a-010, wording.** §12.1 bounds a control change's delay by one frame
  budget; that holds only while the run keeps pace. D-269 backs it. Settled,
  `a991af00`.
- **S12a-020, wording.** §12.2 says the explicit `yield()` covers only frames
  without a coarse-phase sleep; the loop yields at every frame top with
  devices attached. D-027 backs it. Settled, `a991af00`.
- **S12b-117, wording.** §12.4's init-bracket block calls a bare
  `shutdown!`; the bracket calls the guarded `_shutdown!`, which warns on a
  throw and forwards an interrupt. Settled, `a991af00`.
- **S12c-129, wording.** §12.6: `step!` returns the full count when the stop
  falls in the last requested frame, not fewer. Settled, `a991af00`.
- **S12d-058, wording.** §12.7's replay checks: a checkpoint mismatch
  reports the recorded value beside the target's, not a did-you-mean. Settled,
  `a991af00`.
- **S12b-236, defect.** §12.4 says a forced interrupt outside a frame is a
  stop like a deferred one. A raw interrupt in `_run_body!`'s or `step!`'s
  masked bookkeeping can cut it short.
- **K11-001, gap.** The flat state vector's uses are owed by `pending.md`;
  no action.
- **CV11a-004, wording.** `KindCounts` is named only as "the per-kind
  counter record" in §11.8 and the `WriterStatus` docstring; its fields and
  their order go undescribed. Waits on the exported-name audit, which settles
  which fields are public; `design/increments/roadmap_api_audit.md` lists it.

## G6, §1 to §7

- **S6b-239, wording.** §2 says guard-driven handlers are the sole writers
  of continuous state; `x_projection` writes `x` back at every boundary too.
  D-141 backs the doc's text. Settled, `a991af00`.
- **S6c-001 and S6c-004, code or doc.** §4.3 and D-237 refuse a mutable type
  anywhere in a port value. The leaf walk exempts a mutable `Real` such as
  `BigFloat`, and never enters an opaque leaf. K9b-041 waits on it: the
  handle-walk companion and §8.2 say the mutable-parameter rule refuses a
  `Matrix{Dual}` grid copy, and the probe built one without error.
- **K6c-064, K6c-072 to K6c-074, K6d-115, K6d-118, K6d-119, measured
  figures.** The verifiers re-measured the linear-systems and LQR
  companions' tables: the last-bit lag output (…266, not …265), the
  allocation bytes of `step!` over 0.1 s (8,800 B where the doc says 8,208),
  and the tracker's switchover bumps (0.65 and 0.003, not 0.70 and 0.002).
  The figures depend on the machine and on how the setup is rebuilt.
  Proposed: take the re-measured values, noting the Julia version. Settled,
  `df6f03f8`: rounded, the tables being dated probes.
- **K6d-122, wording.** The LQR companion says `Tt = 0` follows exactly on
  the discrete tier; `u_raw` lands on the tick's `v` one tick later. Settled,
  `a991af00`.
- **K6a-013, wording.** The event-visibility walkthrough says no cell is in
  both the `y` and the `u` set; a component wiring its own stage-1 port to
  its own input has one. Settled, `cdf92a7f`.
- **K6b-012, K6b-019, K6b-022 and K6b-101, wording.** The library inventory:
  what walks under `Dual` (pinned and discrete entries do not follow the
  scalar), a fourth status "not admitted", port names beyond `in1…inN`, and
  shipped rows beyond the first two tranches. Settled, `a991af00`.
- **K6e-058, K6e-081 and K6e-087, wording.** The PID companion: the hold
  beats ungated tracking on peak but settles later; the shared methods are
  not "eleven"; the list of vector components is incomplete. Settled,
  `a991af00`.
- **CV6a-020, CV6c-006 and CV6c-043, code_map.md.** The leaves.jl entry omits
  the shape walk; the library.jl entry's Spec line and its PID helper list are
  off. Internal, but the new text is not fixed one way. CV6a-020 and CV6c-043
  settled, `608662ac`. CV6c-006 ruled 2026-11-25: no change, since no rule makes
  a Spec line list every citation in its file.
- **CV6b-019, a runtime string.** A user-visible `@warn` in library.jl cites
  §7.1 for a claim §7.1 does not make. Changing it changes a message. Settled,
  `ea8f9ee8`.
- **CV6a-033, held.** A D-166 citation in leaves.jl, left to CIT-D166.
- **S6c-002, a bold ruling reworded.** §5.2's ruling now reads "a primitive has
  at most two output stages", where it said every primitive provides two. The
  code requires neither stage. D-006 backs the old text and is in the log
  ledger. §2's roadmap (line 137) and §8.1 (line 2491) still say "two output
  stages per primitive". Settled, `608662ac`.

## G7, the appendices and the user-facing docs

- **SA-025 and SA-051, wording.** Appendix A: the shipped instance of a
  commanded reset is `Integrator(; reset = true)`, not weight-on-wheels
  (D-141 backs the doc); and the build never compares instances of a type,
  so a value-dependent contract goes unnoticed for that reason. Settled,
  `a991af00`.
- **SB-289, wording.** Appendix B says `LevenbergMarquardt()` takes no
  keywords; it takes `maxiter` and `λ₀`. Settled, `a991af00`.
- **SD1-129 and SD3-166, wording.** The glossary's cell entry omits the root
  inputs' cells; its claim-enforcement entry omits the harness's
  `OutOfClaimEntry` on an unknown face. Settled, `a991af00`.
- **SD1-001, defect.** Appendix D says its entries are alphabetical within each
  group; several groups are not. Proposed: reorder them, or drop the claim.
  Settled, `608662ac`: reordered.
- **SD3-071, SD3-111, SD3-143 and SD3-144, gap.** The glossary states GUI
  behaviour the inspector's cockpit still owes; `pending.md` records it. The
  verifier proposes marking each as owed.
- **K7a-296 and K7a-297, measured figures.** The longitudinal aircraft
  companion's loop errors during the maneuver: about 0.015 once the fast
  part is over, and a few hundredths of a radian however short `Tt` is.
  Settled, `df6f03f8`.
- **K7b-084, K7b-085, K7b-158 and K7b-175, wording.** The store-at-rest
  walkthrough: a checkpoint's stores are also reachable component by
  component; `state(model, path)` is the one path-addressed read at rest;
  `overlay!` raises the discontinuity notice where `init!` resets the
  stepper; the implementation offers two bundles, not one flag. Settled,
  `a991af00`.
- **SD4-138, wording.** The glossary says a payload carries paths and names
  as strings; names are symbols. D-058 backs the doc's text. Settled,
  `a991af00`.
- **CV7a-003, CV7a-024, CV7a-028, CV7a-038 and CV7a-057, undocumented surface.**
  The artifacts' one-line `show` forms, the `Deployment` REPL heading's extra
  fields, `show(::FrameworkStatus)`, the public `TraceBatch` record and its
  `code_map.md` entry have no doc text. Each needs new text, more than one
  wording of which would do. D-476 and D-454 back parts. Settled, `608662ac`,
  except CV7a-038, which waits on the exported-name audit as CV11a-004 does.
