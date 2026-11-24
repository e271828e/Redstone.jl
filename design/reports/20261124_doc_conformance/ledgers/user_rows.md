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
