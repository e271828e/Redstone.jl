# Unit A rulings: chapter 13 heading and opening, §13.1, §13.2

## Corrections proposed

None outside the rulings. Applied under R6 as dictated: F4 (old 9979–9980),
F5 (9938–9942), F6 and F7 (the sketch), F9 (10117–10119), F10 (10163–10164),
F22 (9950), F28 (10047), F29 (the second `#g-diagnostic-cell` link). Two
dictated wordings held a mid-sentence colon, which the style forbids. F5
becomes four sentences. R11's "is rejected: a warning is" becomes "is
rejected, since a warning is".

Wording changes made for the reserved words and the glossary, no claim
changed:

- Opening, "the seam between "the model reached a terminal state" and "the
  run should end"" becomes "the distinction between …". *Seam* is reserved
  for a narrow, named interface.
- 9992–9993, "That index is the artifact the §8.4 acceptance tests …
  are written against" becomes "the reference". *Artifact* is
  `#g-artifact`, which the same section defines later, and Appendix C's index
  is not one.
- 10052, "One class of exception" becomes "One exception type, the
  `FieldError`". 10067, "The wrong-tier class" becomes "The wrong-tier miss".
  *Class* is reserved for primitive versus assembly.
- 10088, "the unknown `except` entry" becomes "the unknown name given to
  `except`". 10138, "The write-surface and entry violations" becomes "The
  write-surface and batch-entry violations". Bare *entry* is reserved.
- 10047, "§13.4's one catch site" becomes "the one runtime catch site
  (§13.4)". No possessive citations.
- Opening, "ground it" becomes "ground this chapter". After the roadmap
  sentence "it" would read as §13.8.

R8's index keeps the write-surface line as one line naming its three kinds.
They share "all raised at staging" and "The drain checks nothing". Under R24
each kind carries its own section, as Appendix C gives them:
`OutOfClaimEntry` (§11.3), `ClaimedFaceEntry` (§11.3, §11.4) and
`EntryTypeMismatch` (§11.4).

After verification: the runtime-carrier sentence reads "The runtime carrier
`StepError{C}` takes a parameter of its own, the type of its `cause`". Without
the species clause, "follows the same rule" read as "the parameter spells the
policy" (D-222 against D-225). The chattering line keeps the old comma,
"chattering, or localization-budget exhaustion".

## Citations added or replaced

- §13.1–§13.8 (opening): R1's roadmap, each section by subject. §13.3 and
  §13.6 take their subjects from their titles.
- D-057 (§13.1 bold, "Declarative checks over collected structure collect,
  and user-code evaluation fails fast"): Position, "declarative checking
  passes batch …; the first user-code exception (…) aborts the phase". R5
  counts two D-057 rulings in this unit, the populations and no cascade
  suppression. So the two bold list lead-ins join in one bold sentence above
  the list, and each item opens with a plain topic sentence. Strictly, the
  Position's semicolons make the two policies two rulings.
- D-057 (§13.1, "There is no cascade suppression within a step"): Position,
  "no cascade suppression within a stratum". The citation moves from the
  next sentence into the bold's.
- D-259 (§13.1, "The build's steps are barriers"): bullet 2, "Each step is a
  barrier, as each stratum was". Plain; §9 bolds D-259.
- D-229 (§13.1 bold, "Collection reaches the step barrier, under a
  dependency rule"): Position, ""Collected" reaches the stratum barrier. A
  declarative pass runs when the results it reads are clean …". The citation
  moves from the paragraph's last sentence to its bold first sentence.
- D-214 (§13.2, Appendix C's fields): Position, "splits into three:
  severity (the kind's), raised (the stage an occurrence surfaces in …) and
  policy (how it is reported …)".
- D-214 (§13.2 bold, "Severity is a property of the kind, not of the
  occurrence"): Position, "A kind's severity, a property of the kind read as
  `severity(d)`, is `error` or `warning`, nothing else."
- D-058 (§13.2, "Tests match on kind plus payload fields, never on message
  text, so messages are pure presentation"): bullet 4, "Tests match kind +
  payload, never message text."
- D-058 (§13.2, "Two rendering rules are doctrine, not style"): Position,
  "paths and names as strings"; bullet 3, "The didactic style is policy."
- D-222 (§13.2 bold, "The carrier's type parameter spells the policy"):
  Position, "the diagnostic's kind for a fail-fast throw, `Vector{Diagnostic}`
  for a collected one". The citation moves two sentences back, from the test
  spelling to the bold.
- D-248 (§13.2 bold, "The framed set is every user-authored method the build
  invokes"): Position, "The build frames every user-authored method it
  invokes through one framing accessor".
- D-215 (§13.2, the `InternalInvariant` gloss, F28): bullet 4, "Internal
  invariant checks are not diagnostics: they raise a distinct
  `InternalInvariant` exception outside the kind set."
- D-341 (§13.2 bold, the `FieldError` recognition): bullet 3, "A failed
  destructuring is diagnosed from the structured `FieldError` matched against
  the bundle's own NamedTuple type, with did-you-mean against the legal set."
- D-250 (§13.2 bold, "A warning raised while producing an artifact lives on
  that artifact"): Position, the same sentence. The citation moves two
  sentences back, from "Logging is presentation".
- D-251 (§13.2, `EmptyFaceSelection`): bullet 2, "the warning
  `EmptyFaceSelection`, a build-stage warning through D-250's channel".
- D-254 (§13.2, `GridUtilization`): bullet 3, "`GridUtilization`, the last as
  a deployment warning under D-250".
- D-250 (§13.2, `EmptyGreedyClaim`): bullet 5, "`EmptyGreedyClaim` moves from
  a log line to the roster entry's diagnostic cell, since `attach!` mutates
  the roster". Repeated because M3 moves the paragraph away from the
  criterion's citation.
- D-136 (§13.2, "The per-writer diagnostic cells carry it"): Position, "the
  runtime diagnostic stream and the liveness heartbeat get one mechanism, one
  per-writer diagnostic cell". Plain; §11.8 bolds D-136.
- §11.6 (§13.2 index, `DeviceCrash`): F10's dictated pointer.
- D-105 (§13.2 index, `MalformedDatum`): Position, "tolerated in the loop body
  (catch, stage nothing, `report(handle, MalformedDatum(cause))`, continue)".
  Plain; §11.6 bolds D-105.
- D-401 (§13.2 index, `ThreadBudget`, at the line's head): Position, tight
  when `nthreads()` is "less than the run's roster plus one". It does not
  carry "once per run, at `run!` or `replay!`", which stays uncited.
- §11.3, §11.4 (§13.2 index, the write-surface kinds, R24): each kind's
  section per Appendix C.
- D-255 (§13.2 index, `UnboundedRun`): kept, now only for the loop's-cell
  clause, which bullet 5 states ("raises `UnboundedRun` into the loop's
  diagnostic cell"). The bullet's "`Inf` and no faces" condition is not
  cited. It moved to §13.5 with the rest of the condition.

## Rationale-only rulings

- D-250, Rejected, "*Promoting build warnings to errors under a CI switch:*
  §13.2 already rejects it; an empty selection is a fact about the model
  worth knowing, not a defect" (log 9967–9969). R11's sentence cites it
  plain.
- D-250, Rationale and Rejected ("a `TrimReport` is an artifact", log
  9945–9948, 9970–9972): "A stopped-sim service returns an artifact, so its
  warnings live on it." Not newly cited. It sits under the criterion's D-250
  citation as before.

## Bold on the same entry elsewhere

Checked in the frozen spec's other chapters and the sibling units' `new.md`.
No ruling is bold in two places.

- D-229: §9.2 (4462) bolds bullet 4, deployment validation collected. This
  unit bolds the Position's first sentence and states bullet 4 plain.
- D-250: §9.2 (4574, 4588) bolds bullets 1 and 4. This unit bolds the
  Position's criterion; row 59 goes plain (R4, R5).
- D-341: §5.2 (1094) bolds bullet 1, the bundle law. This unit bolds bullet
  3.
- D-136 (§11.8), D-084 (§6.1), D-105 (§11.6), D-259 (§9), D-251 (§8.8) and
  D-254 (§9.2) are bold elsewhere and plain here.
- D-057, D-058, D-214, D-222 and D-248 are bold nowhere else.

## Inbound citations affected

None break.

- M9 (§9.2 holds the build's warnings): spec 4577, 13206, 14735 and 14775 rely
  on the criterion and on `warnings(x)`, which hold here and at §9.2.
- M8 (the runtime index): spec 7226 relies on the write-surface kinds, which
  stay. Spec 8015, 8025 and 8416 rely on the stream, which stays. Spec 8478
  and log 4616 quote "rate-limited wherever its source can repeat", which
  stays verbatim.
- M1: spec 13226 (Appendix C) relies on tests matching kind and payload,
  which stays.
- F4: D-229 bullet 1 (log 8950) says the unfed input is reported "beside it
  (§13.1's worked example)". That still holds: both are reported in the one
  throw. D-057's Rejected "adjacent path-sorted pairs are self-explanatory"
  (log 1839) now disagrees with §13.1. Track 2 could annotate it.
- R11: D-250's Rejected "§13.2 already rejects it" (log 9967) is now true.
  D-058's Rejected "blocks a warnings-as-errors switch" (log 1866–1867) still
  values the switch. Track 2 annotates it under R11.
- R1: spec 9904 (Part IV) says "§13 fixes only how a failure is reported
  once it happens". The opening now adds "and what the framework offers
  around it". The Part IV roadmap is the front matter's (R1).
- Already wrong before the rewrite, unchanged: spec 4706 (§9.3) cites §13.1
  for `UserCodeFraming`, which is §13.2's. Spec 12181 (§14.8) cites §13 for a
  §13.5 doctrine.

## Open questions

None.
