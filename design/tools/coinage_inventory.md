# Coinage inventory

The working list of the spec's coined terms. It governs the first-use gloss +
glossary link per section and feeds `tools/check_glossary.jl`. A working
document: the initial list came from the Appendix D extraction plus a heuristic
head-noun sweep of the body ("the X rule/sweep/law/…"), and it grows as later
reading uncovers coinages the sweep missed.

**Triage rule.** A coinage used in three or more places, or used far from its
definition, gets a glossary entry (bucket C until approved). A one- or two-use
local coinage gets an inline gloss at the use site only (bucket D). Aliases of
an existing entry link to that entry (bucket B).

## A. Canonical terms

The bold entries of Appendix D. Not duplicated here —
`check_glossary.jl` extracts them live from the spec, so the glossary remains
the single home. Multi-alias entries ("stage function / two-stage outputs")
split on "/" for matching.

## B. Aliases — link to the owning entry

Coined spellings that name an existing glossary concept. They link to the
owning entry's anchor; no new entries needed.

| Coinage in body | Owning entry |
|---|---|
| frame-top drain, un-pause drain | drain |
| frozen roster | roster |
| stepper seam, backend seam | seam |
| honest priors | prior |
| interior sweep, boundary sweep, arrival sweep | sweep (each is bold-defined inside that one entry) |
| frame top | frame (a sub-term of the entry) |
| event round | quiescence (a sub-term of the entry) |
| terminal snapshot | snapshot (a sub-term of the entry) |
| probe chain | probe (a sub-term of the entry) |
| nominal evaluation | nominal (a sub-term of the entry) |
| published-boundary ordinal | boundary counter (a sub-term of the entry) |
| graceful entry, abnormal entry | tail (sub-terms of the entry) |
| bundle law | bundle (the entry states the law: a name is present iff the store exists) |
| name-transparent container | container children (the entry states the naming opt-out `transparent_container` declares) |

Compositional uses of the §D.10 meta-vocabulary ("device contract", "face
contract", "authoring contract", "mid-run mutation doctrine") are ordinary
compositions of *contract* / *doctrine* with a qualifier, not separate
coinages: link the meta-term or the owning section, whichever the
context wants.

## C. Promoted coinages — settled

| Term | Uses | Notes |
|---|---|---|
| handler return law | 3 | §5.2; never defined in glossary prose |
| termination record | 13 | defined in §13.5; also §11.8, §12.1, §12.4, §12.6, §13.2, §13.6 and Appendix C |
| scratch | 45 | promoted to an Appendix D entry (`g-scratch`) with D-213; bucket A from here on |
| `Structure` | — | D-253's structure-step artifact; Appendix D entry `g-structure`, bucket A from here on |
| `Outputs` | — | D-253's nominal-evaluation artifact, `Dataflow` until D-261's 2026-09-21 extension; Appendix D entry `g-outputs`, bucket A from here on |
| `Events` | — | D-253's other nominal-evaluation artifact; Appendix D entry `g-events`, bucket A from here on |
| `Deployment` | — | D-254's artifact between the build and the simulation; Appendix D entry `g-deployment`, bucket A |
| `Schedule` | — | D-254's typed tick timing; folded into the existing `g-schedule` entry rather than given one of its own |
| `Run` | — | D-255's run state; Appendix D entry `g-run`, bucket A from here on |
| `StopPolicy` | — | D-255's per-advance policy value; Appendix D entry `g-stop-policy`, bucket A |
| leaf address | 7 | D-276's selector argument; §4.2, §4.3, §14.4, §14.7, §14.10, Appendix B; Appendix D entry `g-leaf-address`, bucket A from here on |
| bare store | 11 | D-435's store declared as one leaf; §5.2, §7.1, §7.3, §8.2, §9.1, §9.5, §14.1, §14.3, §14.4, Appendix B, Appendix C; Appendix D entry `g-bare-store`, bucket A from here on |
| bare contract | — | D-436's contract declared as one type; §4.3, §5.2, §6.1, §8.2, §8.6, §8.8, §9.1, §9.5, §13.3, §13.9, §14.4, Appendix B, Appendix C; Appendix D entry `g-bare-contract`, bucket A from here on |
| descriptor | — | D-432's rendering of an artifact to data; §9.2, §13.9, Appendix B; Appendix D entry `g-descriptor`, bucket A from here on |
| kind marker | — | D-432's per-face marker in a descriptor; §13.9; Appendix D entry `g-kind-marker`, bucket A from here on |
| local wire | 11 | D-303's child-to-child wire, named by D-314, defined in §6.1; nine body uses in §3.3, §6.1, §8.6, §8.8, §11.7 and §14.2, two in Appendix D; Appendix D entry `g-local-wire`, bucket A from here on |
| Appendix D's gap check | — | promoted by Appendix D's gap check of 2026-10-21, each a coined name used in three or more sections: auto-bubbling, bound law / walk clause, branch-shape rule, export chain, locality law / one-level rule, opaque leaf, fused idiom, hand-down, hop / dead hop, boundary sequence / macro-sequence, trial evaluation, shadowing check, door, heartbeat, inspection read / integration read, levels doctrine, tail, fingerprint, read set, stopped-sim; bucket A from here on |
| artifact | — | D-250's criterion word; Appendix D entry `g-artifact` in D.10, bucket A |
| state | — | D-250's other criterion word; Appendix D entry `g-state-single-owner` in D.10, bucket A |

The nine rows above are the pipeline redesign's coinages (D-250 through
D-258). Each went straight to an Appendix D entry, because each names a type
or a criterion the spec states in several chapters. `Schedule` is the one
exception: the glossary's existing "schedule" entry now names the type, so the
coinage has no entry of its own.

Two entries were **retired** by the same commit. "auto-published port" went
with the port class D-252 removed. "warning streams" went with the two streams
D-250 replaced by the artifact criterion; its content is now the two D.10
entries above.

The handler return law is a §5.2 hand-off law, sibling of the bundle law
(bucket B). Settled the third way: it got its own `####` sub-heading in §5.2,
and the body cites the section rather than a glossary anchor.

The termination record went the ordinary way: promoted by D-203 to an
Appendix D entry (`g-termination-record`), so it is bucket A from here on and
this row is the record of the promotion.

## D. Low-frequency coinages — inline gloss only

One or two uses each; promote to bucket C only if usage grows:
post-transition sweep, sampling seam, getfield walk, active-widget contract,
the by-allocation convention, misplaced pin, and the epoch rule (§10.6's,
which is not the input epoch). Appendix D's gap check of 2026-10-21 left
these here too, each local to one or two sections: the gate form, blocked
event, constraint pool, canonical residue, grid diagnostics, pairing by name,
convert-on-write, store form, probe-scoped, deliberate stripping, hybrid
sleep-then-spin, event registers, the FFI door, fan-out meet, step barrier,
framing, service walk, guarded sequence, pre-sweep doctrine, probe-value
barrier, committed-state residuals, shim, port view, unmask point, state
what-if, tail residue, run's-end sweep, sticky stopped status and the
re-anchor; and the remedy ladder and the granularity guideline, at three uses
each.
