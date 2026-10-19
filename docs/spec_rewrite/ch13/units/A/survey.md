<!-- Sliced from survey_1.md for unit A (§13, §13.1, §13.2) by checks/slice_survey.py. -->
# Survey of spec chapter 13, half 1, before its readability rewrite — 2026-10-19

Scope: `docs/design/spec.md` lines 9909–10442 at commit `1fee0fc`, 4,844
words: the chapter heading and roadmap (9909–9921, 97 words), §13.1
(9922–9981, 561), §13.2 (9982–10169, 1,629), §13.3 (10170–10253, 816) and
§13.4 (10254–10442, 1,741). Half 2 (§13.5–§13.8, 10443–11141, 5,791 words)
is the sibling survey's. The convention is `docs/design/tools/spec_style.md`;
the method is `docs/spec_rewrite/recipe.md` step 1; the model is chapter 12's
half-1 survey (`git show eb1d832:docs/spec_rewrite/ch12/survey_1.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h1/`
(`spec.md` and `decisions.md` at `1fee0fc`). Lines marked `log` are
`decisions.md` lines. Entry claims rest on the entry as read in full. `src/`
was read at the working tree where a name or a claim was in doubt. The script
that ran the half's code and claims is `scratch_survey/h1/run/blocks.jl`, its
output `run/output.txt`, and `run/bare.jl` one extra probe (part C, "Running
the half's code").

Classification codes used in part A, as in chapters 10 to 12:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry or clause.
- **R** ruled only in an entry's Rationale, Rejected list or annotation
  (whether or not the entry is cited).
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.** label, bold label (a
bold phrase opening a paragraph and acting as a heading, "**Where caught.**"),
bold lead-in (a bold sentence or clause opening a paragraph), bold sentence,
bold term, or plain.

Bold now: 43 spans and 181 words in the half. Heading 0; §13.1 4 spans (19
words); §13.2 19 (84); §13.3 8 (37); §13.4 12 (41). Labels: **Rule.** ×3
(§13.1 1, §13.2 2), no **Why.** or **Example.** Of the 43, ten are the
runtime index's list labels (§13.2), four are table cells (§13.3), seven are
bold labels acting as headings (§13.4), four are list lead-ins (§13.1,
§13.2), five mark a term, a link or a single word, three are the **Rule.**
labels, and ten are bold sentences. No bold headline clause carries its D-citation in its own
sentence: the **Rule.** sentence at 9988 cites D-058, and the bold sentences
at 9975 and 10010 are cited in the sentence after.

Three entries that rule much of the half are cited nowhere in it: D-214
(severity and the raised/policy split, §13.2), D-136 (the runtime stream's
cells, §13.2) and D-398/D-394 (the forced throw and masking, §13.4, both cited
only in §12.4). D-130 is cited in §13.3 but its client table now disagrees
with the code (F1, serious).

## A. Per section

### §13 heading and roadmap (9909–9921, 97 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 9911–9913 | "§8.4 fixed what must be caught and where. §9 fixed when each fact is checked. This section fixes how failures are *reported*." | plain | — | framing; "This section" names the chapter |
| 2 | 9913–9917 | "It covers the reporting policy, the diagnostic representation, the runtime failure story, the seam between … and the diagnosis of a rejected cycle." | plain | — | roadmap; no section numbers; omits §13.3 (build primitives) and §13.6 (abnormal shutdown) |
| 3 | 9917–9921 | "Two lessons FlightCore paid for ground it. The first is the compact-backtrace discipline … The second is the `SimulationTermination` machinery, which §13.5 replaces." | plain | D-058 Rejected (`compact_backtrace`), D-060 | framing, history; FlightCore named, so it needs nothing |

Glossary terms: none linked. Appendix C kinds: none.

The Part IV roadmap (9891–9897) describes §13 as the collect/fail-fast
policy, the diagnostic value, the catch site and cursor, termination as state
and cycle diagnosis; it also omits §13.3, §13.6 and §13.7, and 9902–9904 says
"§13 fixes only how a failure is reported once it happens", which §13.3, §13.7
and §13.8 exceed (q1).

### §13.1 Reporting policy: collect the checks, fail the evaluations fast (9922–9981, 561 words)

Purpose: the two failure populations and their policies, the step barrier and
the dependency rule, no cascade suppression.

Subheadings: none. A context paragraph opens (9924–9926) but does not name
the parts. Bold: two list lead-ins (9928, 9938), one **Rule.** (9953), one
bold sentence (9975).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 4 | 9924–9926 | "The build's failure sites split into two populations. That split settles the choice between fail-fast and compiler-style reporting." | plain | D-057 Position | U (context) |
| 5 | 9928 | "**Declarative checks over collected structure collect.**" | bold lead-in | D-057 Position | C, adjacent (D-057 at 9947) |
| 6 | 9928–9931 | "These are the checks for unconnected inputs, two producers, wire typos and type mismatches, face-name uniqueness, `y_types`/state-field consistency and `sample_times` validation." | plain | — | N; an inventory, Appendix C's rows are its home |
| 7 | 9931–9934 | "Each is a pass over a list. … Reporting every violation is the natural output of such a pass, and truncating to the first would be extra work." | plain | D-057 Position ("the full violation list is the pass's natural output") | C, adjacent |
| 8 | 9934–9937 | "These failures also cluster in practice. A freshly written assembly has five unwired inputs, and a renamed port breaks three wires." | plain | D-057 Rejected (log 1835); D-229 Rationale (log 8967–8968) | R |
| 9 | 9938 | "**User-code evaluation fails fast.**" | bold lead-in | D-057 Position | C (9947) |
| 10 | 9938–9942 | "User code runs in three places. The first is the interface-connection bodies in the structure step … The other two are the stage-1 probes and the probe chain of the nominal evaluation (§9.1)." | plain | D-057 Position ("`exports` bodies, probes"); D-248 Position (every declaration framed) | B: U by D-057; undercounts against D-248 (F5) |
| 11 | 9942–9946 | "When user code throws, there is no meaningful rest of the collection to report. A failed `input_wires` leaves the parent's face derivation undefined. A failed stage-2 probe starves every downstream probe …" | plain | D-057 Rejected (full batching, log 1836–1838) | R |
| 12 | 9946–9947 | "The first user-code exception aborts the phase (D-057)." | plain | D-057 Position | C |
| 13 | 9949–9950 | "The build's steps are barriers. A step that produced any error-severity diagnostic, of either kind, throws before the next step begins." | plain | D-057 ("strata are barriers"); D-259 bullet (log 10447), stated in §9's bold sentence at 4095–4097 | U; "of either kind" misuses *kind* (F22) |
| 14 | 9950–9951 | "Probing against unresolved wiring would be meaningless." | plain | — | N (reason) |
| 15 | 9953–9956 | "**Rule.** Collection reaches the step barrier, under a dependency rule. A declarative pass runs when the results it reads are clean. … Every pass that ran merges into the barrier's one throw (D-229)." | **Rule.** | D-229 Position | C |
| 16 | 9958–9961 | "Whether a pass can run past a failure follows from what it reads. … A wire that fails to resolve is recorded and claims nothing, so the obligation check reports its input as unfed." | plain | D-229 bullet 1 | C, adjacent |
| 17 | 9961–9962 | "Tier and event checking read only the component list, so they run and merge." | plain | D-229 Rationale (log 8968–8971) | R |
| 18 | 9962–9964 | "A structural failure leaves the subtree behind it unknown. An unreadable or mixed class or a malformed container is such a failure. … it throws alone." | plain | D-229 bullet 2 | C, adjacent |
| 19 | 9965–9967 | "In the two evaluating steps the probe chain consumes each check's subject as it goes. A check that reads a failed probe does not run …" | plain | D-229 bullet 3; Rationale (log 8976–8978) | C, adjacent |
| 20 | 9967–9969 | "Outside the build the unit is the call. Deployment validation (§9.2) runs every check whose premise holds and throws once." | plain | D-229 bullet 4, bold at §9.2 4462 | C, adjacent; double of §9.2 (part B) |
| 21 | 9969–9973 | "The only partial results ever carried past a failure are violation lists and a claim table with the failed wires absent. … That machinery was the cost that kept this decision open, and it never materializes." | plain | D-057 Rejected (log 1836–1838); D-229 Rationale | R; history ("kept this decision open") |
| 22 | 9975–9976 | "**There is no cascade suppression within a step.** This is a deliberate simplification (D-057)." | bold sentence | D-057 Position | C |
| 23 | 9976–9979 | "A wire typo'd as `:throtle` produces two errors. One is a did-you-mean error … The other is an unconnected-input error for the intended `throttle`." | plain | D-229 bullet 1; D-057 | C, adjacent (example); confirmed by the suite (`test_assembly.jl` 842–846) |
| 24 | 9979–9980 | "Both are reported. They render adjacently, because diagnostics sort by path, and the pairing explains itself." | plain | D-057 Rejected ("adjacent path-sorted pairs are self-explanatory", log 1839) | R; false in general, the render groups by kind first (F4) |

D-057 is cited three times (9947, 9976) and D-229 once (9956); between them
they rule every row but 6 and 14. D-259 (each step a barrier) is §9's bold
and stated plain here.

Descriptions that read like rules: row 6 (the list of collecting checks),
row 21 (no partial-result machinery, a consequence).

Display-block candidates: none.

Glossary terms in §13.1 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| collect the checks, fail the evaluations fast | 9922 (title) | no; the section never links its own anchor | yes |
| face | 9930 | yes, no gloss | yes |
| assembly | 9935 | yes, no gloss | yes |
| port | 9936 | yes, no gloss | yes |
| probe | 9941 | yes, no gloss | yes |
| nominal | 9941 ("the nominal evaluation") | no | loose: the entry (14244, `#g-nominal`) is the `Float64` activation; "nominal evaluation" is the build's second step |
| probe value | 9945 | yes, no gloss | yes |
| kind | 9950 ("of either kind") | no | **no**: the entry is a diagnostic's identity in the closed set; here it means "either population" (F22) |
| tier | 9961 | no | yes (continuous/discrete) |
| did-you-mean | 9977 | yes, glossed | yes |
| `Structure` / structure step | 9939, 9959 | no | yes |

Appendix C kinds cited to §13.1: none as owning section. Appendix C's
preamble cites §13.1 for the error severity and the collected and fail-fast
policies (13240, 13263, 13269). The section names no kind; its worked example
describes `UnknownPort` and `UnconnectedInput` (9977–9979) without naming
them, though neither cites §13.1.

### §13.2 Diagnostics: structured values, one carrier exception (9982–10169, 1,629 words)

Purpose: the diagnostic value, its kinds and severity, the carrier and its
policy parameter, user-code framing, the `FieldError` recognition, the
rendering doctrine, and where warnings live, with the runtime warning index.

Subheadings: none, though the section holds two topics of about equal size:
the diagnostic and its carrier (9984–10088, 843 words) and the warning homes
(10090–10168, 786 words). The context paragraph (9984–9986) names no parts.
Bold: two **Rule.** labels (9988, 10090), a bold link (9989), two bold list
lead-ins (10080, 10085), one bold sentence ruling (10010), three bold
paragraph lead-ins (10097, 10109, 10123) and ten bold list labels in the
runtime index (10131–10165).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 25 | 9984–9986 | "Both reporting policies move the same thing. … The shape of that value decides what an acceptance test can assert and what a user reads." | plain | D-058 Position | U (context) |
| 26 | 9988–9989 | "**Rule.** A diagnostic is a plain value from a small closed set of kinds (D-058)." | **Rule.** | D-058 Position | C |
| 27 | 9989–9993 | "**Appendix C** enumerates that set normatively. For each kind it records the kind name, the payload fields, the owning section, the severity, where the kind is raised and under which policy. That index is the artifact the §8.4 acceptance tests … are written against." | bold link | D-058 (closed set); D-214 Position (the three fields) | B: C by D-058 for the set; U by D-214 for the fields; the bold marks a link, not a ruling |
| 28 | 9993–9997 | "Each kind carries its own structured payload. The payload holds endpoint paths, face names, expected and observed types, and the *list-in-hand* …" | plain | D-058 Position | C, adjacent |
| 29 | 9997 | "A kind *is* a Julia type." | plain | D-222 Rationale (the kind in the parameter); D-058 Rejected (kinds are not exception types) | B: U by D-222 bullet 1 by implication; no Position states it |
| 30 | 9997–10000 | "Severity is a property of the kind, not of the occurrence. It is `error` or `warning` … read as `severity(d)` and never stored per occurrence." | plain | D-214 Position | U |
| 31 | 10000 | "The severity field of Appendix C is derived from it." | plain | D-214 Position | U |
| 32 | 10000–10005 | "Where an occurrence surfaces … and how it is reported … are the *raised* and *policy* fields … `BundleFieldError`, for example, is raised at the probe and as a `StepError` species thereafter." | plain | D-214 Position, Rationale (log 8213–8214) | U |
| 33 | 10007–10009 | "Checking passes return diagnostics. The step barrier … throws a single `DiagnosticError` wrapping the collection. A fail-fast site throws the same carrier holding one diagnostic." | plain | D-058 Position (one carrier); D-222 Position | C, adjacent (D-222 at 10013) |
| 34 | 10010–10013 | "**The carrier's type parameter spells the policy.** It is the diagnostic's kind for a fail-fast throw and `Vector{Diagnostic}` for a collected one. A test therefore asserts policy and kind at once with `@test_throws DiagnosticError{Kind}` (D-222)." | bold sentence | D-222 Position; Rationale for the test | C |
| 35 | 10013–10015 | "The runtime carrier follows the same rule. `StepError{C}` carries the type of its `cause`, so a species is `StepError{Kind}` (§13.4, D-225)." | plain | D-225 Position | C; double of §13.4 10313–10316 (part B) |
| 36 | 10016–10017 | "`showerror` renders a collection compiler-style, grouped by kind and sorted by path. It renders a single diagnostic as its own line." | plain | D-058 Position ("compiler-style rendering"); D-222 bullet 1 | U; mechanism (part H) |
| 37 | 10019–10032 | the `Diagnostic`/`DiagnosticError` sketch | code | D-222 | code; omits `warnings` (F6); "a barrier's batch" (F7) |
| 38 | 10034–10035 | "A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`, with the original exception as `cause`." | plain | D-058 bullet 1; D-248 Position | C, adjacent (D-248 at 10039) |
| 39 | 10035–10039 | "The frame carries the component path, the function that threw, and the probe context … and the synthesized inputs as a spelling, never as values (D-248)." | plain | D-248 Position, bullet 2 | C |
| 40 | 10039–10040 | "The didactic frame therefore renders first and the raw throw second." | plain | — | N; "didactic" is defined at 10085, after this use |
| 41 | 10040–10043 | "The framed set is every user-authored method the build invokes. The declarations of §8.2 and the probed functions of §9.3 are framed alike, each reached through one framing accessor …" | plain | D-248 Position, bullet 1 | C, adjacent |
| 42 | 10044 | "A declaration takes no bundle, so only the plain frame applies to it." | plain | D-248 Rationale (log 9815–9816) | R |
| 43 | 10044–10047 | "Three exceptions pass through the frame unwrapped … a `DiagnosticError` carrier a check inside the call threw, an `InternalInvariant`, and an `InterruptException`." | plain | D-248 bullet 3; D-215 bullet 4 (`InternalInvariant`) | C, adjacent; `InternalInvariant` reader-cold (F28) |
| 44 | 10047–10050 | "At runtime the same throw reaches §13.4's one catch site instead. There a `FieldError` matched as below becomes a `BundleFieldError` species, and any other exception rides as the `StepError`'s `cause`." | plain | D-248 bullet 4 | C, adjacent; D-248's "`UserCodeFraming` stays build-only" is implied, not said |
| 45 | 10052–10053 | "One class of exception is recognized rather than merely framed. A `FieldError` carries its type and field as data (Julia ≥ 1.12)." | plain | D-341 bullet 3; D-074 Rationale | U |
| 46 | 10053–10056 | "At the probe the framework matches them against the bundle's own NamedTuple type … At the runtime catch site it matches them against the bundle's field names … (D-248)." | plain | D-248 bullet 4 | C |
| 47 | 10057–10058 | "A tuple the author builds with the bundle's own names is indistinguishable from the bundle at either site, and the diagnosis stays true of it." | plain | — | N |
| 48 | 10058–10061 | "The result is the bundle-law did-you-mean (§5.2). It carries the legal field set and classifies the miss as an undeclared store, a wrong tier, or a field illegal for this function. Nothing is recovered by reading message text." | plain | D-341 bullet 3; D-074 Rationale | U |
| 49 | 10063–10066 | "The probe raises the result as `BundleFieldError` (Appendix C, D-248). An example message is … The message names the component by its path." | plain | D-248 bullet 4 | C; the example matches the code's message (part C) |
| 50 | 10066–10067 | "One law covers tier facts, stage legality and declarations alike." | plain | D-341 bullets 1, 2 | B: U by D-341; what "one law" names is unclear |
| 51 | 10067–10070 | "The wrong-tier class covers the state letters too (D-195). `x` and `m` are continuous-only, and `s` and `Δt` are discrete-only …" | plain | D-195 bullet 2; D-362 (`m` continuous-only) | C |
| 52 | 10070–10072 | "The bundle stays a bare NamedTuple (D-074, D-341). A getproperty-wrapper spelling is the recorded fallback … (D-341)." | plain | D-341 bullet 3 | C |
| 53 | 10074–10076 | "The §8.4 walkthroughs, run as acceptance tests, target diagnostics. Tests match on kind plus payload fields, never on message text. Messages are therefore pure presentation." | plain | D-058 bullet 4 | U; double of row 27 and of Appendix C's bold (13225) (M1) |
| 54 | 10078 | "Two rendering rules are doctrine, not style." | plain | D-058 | U |
| 55 | 10080–10084 | "**Strings, never instances.** Diagnostics carry paths and names as strings, never component instances and never component types. This is the `compact_backtrace` lesson. Expected and observed *port* types are the one payload exception …" | bold lead-in | D-058 Position; Rejected (log 1865) | U |
| 56 | 10085–10088 | "**The didactic style is policy.** Every diagnostic states the fix or the lists-in-hand, not just the violation." | bold lead-in | D-058 bullet 3 | U |
| 57 | 10090–10092 | "**Rule.** A warning raised while producing an artifact lives on that artifact. A warning raised while mutating state lives in that state's status. Logging is presentation and never a home (D-250)." | **Rule.** | D-250 Position | C |
| 58 | 10092–10095 | "An artifact is an immutable pure function of its inputs. State is single-owner and mutated in place. That one criterion places every warning the framework raises." | plain | D-250 Position | C, adjacent |
| 59 | 10097 | "**The build produces artifacts, so its warnings live on them.**" | bold lead-in | D-250 bullet 1, bold at §9.2 4574 | C, adjacent; a consequence bolded |
| 60 | 10097–10099 | "`Build` and `Deployment` … carry `warnings`, and `warnings(x)` reads the list (§9.2)." | plain | D-250 bullets 1, 4, bold at §9.2 4588 | U; omits `Model` and `Simulation` (F31) |
| 61 | 10100–10102 | "A step that throws renders its warnings with the collection it throws. One that completes carries them on the artifact, and the entry point logs each once at return." | plain | D-250 bullet 1 | U; double of §9.2 4574–4577 (part B) |
| 62 | 10102–10104 | "The build's warning set holds `EmptyFaceSelection` (§8.8), and the deployment's holds `GridUtilization`." | plain | D-251; D-254; D-250 Rationale | U |
| 63 | 10104–10106 | "The unconnected-output warning stays rejected (§6.1, D-084), so the *collected*-warning slot stays open and empty." | plain | D-084 Position; D-250 bullet 3 | C |
| 64 | 10106–10107 | "A warnings-as-errors CI switch could be added, but is not built." | plain | D-250 Rejected (log 9967–9969); D-058 Rejected (log 1866–1867) | R; contradicts D-250's Rejected (F8) |
| 65 | 10109 | "**The runtime mutates state, so its warnings live in that state's status.**" | bold lead-in | D-250 Position | C, adjacent |
| 66 | 10109–10112 | "The stream is per-occurrence. The per-writer diagnostic cells … carry it (§11.8)." | plain | D-136 Position | U |
| 67 | 10112–10115 | "The rate limit lives in the cells, as a structural bound … a bounded ring plus per-kind suppressed counts, drained at frame top. So 'rate-limited wherever its source can repeat' holds of every kind below …" | plain | D-136 Position; Rationale (log 4614–4617) | U; double of §11.8 8478 |
| 68 | 10115–10117 | "The stream surfaces through the published framework status (§11.2)." | plain | D-136 Rationale (log 4623–4630) | R |
| 69 | 10117–10119 | "The §10.7 pacer diagnostics and the §12.2 liveness heartbeats ride in the same cells and surface beside it." | plain | D-136 Position (the heartbeat in the cell) | U; the pacer record is not in the cells (F9) |
| 70 | 10119–10121 | "The stream is never collected, since there is no collection to join. Nothing in the argument of D-084 applies to it. That decision is about what the *build* warns on." | plain | D-084 Position | B: C for D-084's scope; N for "never collected" |
| 71 | 10123 | "**A stopped-sim service returns an artifact, so its warnings live on it.**" | bold lead-in | D-250 Rationale (log 9945–9948); Rejected (log 9970–9972) | R |
| 72 | 10124–10126 | "`trim!` returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` are that report's fields (§14.8). The line the call prints at return is presentation." | plain | D-250 Rationale; D-262 | R |
| 73 | 10126–10128 | "`attach!` is the other side of the criterion. It mutates the roster, so `EmptyGreedyClaim` lands in the roster entry's cell (§11.6)." | plain | D-250 bullet 5 | U |
| 74 | 10128–10129 | "The committed runtime warnings, in one place, are these." | plain | — | N (an index) |
| 75 | 10131–10133 | "**Chattering, or localization-budget exhaustion** (§10.4). A localized event's bracketing budget runs out at a boundary." | bold label | §10.4's entries (D-133, D-181) | U, pointer; kind `ChatteringBudget` unnamed |
| 76 | 10134–10135 | "**Firing-budget exhaustion** (§10.6). An event has spent its `firing_budget` at a boundary …" | bold label | D-181; D-292 | U, pointer; `FiringBudget` unnamed |
| 77 | 10136–10137 | "**Forgiven-debt re-anchor** (§10.7). The pacer abandons its accumulated debt and re-anchors its schedule." | bold label | D-133; D-294 bullet 4 | U, pointer; `DebtReanchor` unnamed |
| 78 | 10138–10146 | "**The write-surface and entry violations** (§11.3, §11.4), all raised at staging. The drain checks nothing. `OutOfClaimEntry` … `ClaimedFaceEntry` … `EntryTypeMismatch` …" | bold label | D-044; D-104; D-192; D-105 Rationale | U, pointer; kinds named |
| 79 | 10147–10150 | "**A tolerated device-side datum failure** (§11.6, §13.4). `MalformedDatum` is emitted by the author's loop via `report!(handle, …)` … It succeeds `InputMappingError`." | bold label | D-105 Position | U; `InputMappingError` reader-cold (F27) |
| 80 | 10151–10153 | "**Staging discarded during replay** (§12.7). `ReplayDiscardedStaging` reports a live batch found staged while the trace feeds the drain." | bold label | D-218 bullet 1 | U, pointer |
| 81 | 10154–10155 | "**Thread-budget tightness** (§12.2). Raised once per run, at `run!` or `replay!`, against the frozen roster." | bold label | D-401; D-392 | U, pointer; `ThreadBudget` unnamed |
| 82 | 10156–10161 | "**Device join timeout** (§12.4). A device task exceeds the shutdown join timeout and is abandoned by name … collected into the termination record and presented through the logging backend, never carried into a status (D-201, D-203)." | bold label | D-201 Position; D-203 bullet 4 | C; `DeviceJoinTimeout` unnamed |
| 83 | 10162–10164 | "**Device crash** (§12.4, §13.4). The framework wrapper catches a device task's failure, and the sim continues with the device absent." | bold label | D-097; D-102 Rationale; should_abort: D-381, D-030 annotation | U; `DeviceCrash` unnamed; omits the `should_abort` stop (F10) |
| 84 | 10165–10168 | "**Unbounded run** (§13.5). `run!` is called in `:live` with `t_end = Inf` and no honoured stop request. A `run!` in `:replay` is bounded by the recording and raises nothing. `UnboundedRun` lands in the loop's own cell, because `run!` mutates state (D-255)." | bold label | D-255 bullet 5 and Rationale (log 10263–10264); D-316 (stop requests); D-218 bullet 2 | C; double of §13.5 10545–10553 (part B) |

D-214 (rows 27, 30–32) and D-136 (rows 66–69) rule the section and are cited
nowhere in it. D-250 is cited once, at the warning **Rule.** (10092), and
rules rows 57–65 and 71–73. Every runtime-index bullet (rows 75–84) is a
pointer to its owning section; only row 82 and row 84 cite an entry.

Descriptions that read like rules: row 36 (the render order), row 47 (a tuple
built with the bundle's names), row 69 (what rides in the cells), row 74's
index.

Display-block candidates: the two test spellings, `@test_throws
DiagnosticError{Kind}` (10013) and §13.4's `@test_throws
StepError{ConformanceFailure}` (10317), are what a reader copies; a two-line
fence in each section, or none. An addition the inventory declares.

Glossary terms in §13.2 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| diagnostic, kind | 9985, 9989 | *kind* yes, no gloss | yes |
| payload | 9990 | yes, no gloss | yes |
| face | 9994 | yes, no gloss | yes |
| did-you-mean | 9996 | yes, glossed | yes |
| species | 10005 | yes, no gloss; defined in §13.4 | yes |
| carrier exception | 10009 ("the same carrier") | **no**; `#g-carrier-exception` is never linked in the half | yes |
| batch | 10028 (code comment, "a barrier's batch") | no | **no**: `#g-batch` is a device's staged write set and says "Error reporting *collects*" (F7) |
| component | 10036 | yes, no gloss | yes |
| probe | 10037 | yes, no gloss | yes |
| bundle | 10037 | yes, glossed | yes |
| frame | 10035 ("The frame carries …") | no | **no**: `#g-frame` is a loop iteration; here it is the framing diagnostic (F23) |
| tier | 10060 | yes, no gloss | yes |
| port | 10082 | yes, no gloss | yes |
| artifact | 10093 | yes, glossed by the sentence | yes |
| state | 10094 | yes (`#g-state-single-owner`) | yes |
| `Build` | 10097 | no | yes |
| `Deployment` | 10098 | yes, glossed | yes |
| diagnostic cell | 10110 | yes, glossed; **linked again at 10118** | yes |
| framework status | 10116 | yes, no gloss | yes |
| chattering | 10131 | yes | yes |
| localized | 10132 | yes, no gloss | yes |
| boundary | 10133 | yes, no gloss | yes |
| drain | 10139 | yes, no gloss | yes |
| batch | 10144 ("a pending batch") | yes | yes |
| root input | 10145 | yes, no gloss | yes |
| device | 10147 | yes, no gloss | yes |
| replay, trace | 10151, 10153 | yes, no gloss | yes |
| roster | 10155 | yes, no gloss | yes |
| termination record | 10159 | yes, no gloss | yes |
| stop request | 10166 | no | yes |

Appendix C kinds cited to §13.2, checked row by row (lesson 20):

| kind | Appendix C | named where §13.2 states its condition |
|---|---|---|
| `BundleFieldError` | 13450 (§5.2, §13.2) | yes, 10063 |
| `UserCodeFraming` | 13458 (§13.2) | yes, 10034 |

The runtime index (rows 75–84) names `OutOfClaimEntry`, `ClaimedFaceEntry`,
`EntryTypeMismatch`, `MalformedDatum`, `ReplayDiscardedStaging` and
`UnboundedRun`, and states the conditions of `ChatteringBudget`,
`FiringBudget`, `DebtReanchor`, `ThreadBudget`, `DeviceJoinTimeout` and
`DeviceCrash` without their names. None of those six cites §13.2 in
Appendix C, but an index that names half its kinds is uneven (F11, q5).

### §13.3 Build primitives: `resolve` and the face-list accessors (10170–10253, 816 words)
(§13.3 is another unit's; see the full survey.)

### §13.4 Runtime failures: one catch site, an execution cursor (10254–10442, 1,741 words)
(§13.4 is another unit's; see the full survey.)

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| heading | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| §13.1 | 21 | 11 | 2 | 0 | 5 | 2 | 1 |
| §13.2 | 59 | 21 | 26 | 0 | 5 | 3 | 4 |
| §13.3 | 21 | 4 | 10 | 0 | 3 | 1 | 3 |
| §13.4 | 65 | 30 | 23 | 1 | 5 | 4 | 2 |
| total | 166 | 66 | 61 | 1 | 18 | 10 | 10 |

The count leaves out seven rows that are framing or code (1, 2, 3, 37, 115,
131, 134), and classes each row by its first code. "C, adjacent" counts as C,
so the C column overstates how often a rule carries its own citation: in
§13.4, 10 of the 30 C rows carry it in the sentence itself.

The U rows cluster in entries the half cites seldom or never: D-214 (4 rows,
never cited in the half), D-136 (4, never), D-130 (7 in §13.3 without a
citation at the spot), D-059 (8 in §13.4 beyond its one citation), D-128 (4,
never in §13.4), D-105 (4, never), D-207 (2, never in §13.3), D-398/D-394 (2,
cited only in §12.4), and the runtime index's pointers (9 rows). The R rows
are mostly reasons living in D-057's and D-229's Rationales and Rejected
lists (§13.1), D-250's Rationale (§13.2) and D-130's Rationale (§13.3). One
S: the cursor's `Outputs` clause cites D-253, whose `Dataflow` clause D-261
supersedes (row 110). One cited bold (row 164's "first act") repeats D-157's
own bolded Position text.

Bold weight now: 43 spans, 181 words. Labels: **Rule.** ×3. Bold labels
acting as headings: seven in §13.4, two in §13.1, two in §13.2, ten list
labels in §13.2's index. Whole-sentence bolds: rows 22, 34, 59, 65, 71, 89,
93, 100, 126, 135. Bolds on a term or link: rows 27, 109, 117.

## B. Overlaps

Numbered H1–H20. "Home" says which text keeps the statement; the other
becomes a pointer. For chapters 5 to 12, the home is the one the rewritten
text already chose.

### Inside the half

- **H1. `StepError{C}`, twice.** §13.2 row 35 (10013–10015) and §13.4 rows
  126–128 (10313–10318) both state D-225's parameter and the species
  spelling. Home: §13.4, D-225's section and the carrier's. §13.2 keeps one
  clause, "the runtime carrier follows the same rule (§13.4)" (M4).
- **H2. How a collection renders, twice and in conflict.** §13.1 row 24
  ("render adjacently, because diagnostics sort by path") and §13.2 row 36
  ("grouped by kind and sorted by path"). The code follows §13.2
  (`_groups`, `src/diagnostics.jl` 111–119). Home: §13.2; §13.1's sentence is
  corrected (F4).
- **H3. Tests match on kind and payload, three times.** §13.2 row 27
  (9992–9993), row 53 (10074–10076), and Appendix C's bold (13225–13226,
  "**Tests match on kind plus payload fields, never on message text**").
  Home: §13.2, once (M1). Appendix C's bold is a double for the appendices'
  rewrite to settle.
- **H4. The interrupt inside boundary zero before the interrupt arm.** Row
  139 (10359–10362) relies on the stop path that rows 149–150
  (10386–10389) define later. Order, not content (M6).
- **H5. Boundary zero's disposition before the loop's.** Row 144
  (10374, "differs from the loop's as well") precedes rows 154–159
  (10398–10408). Order (M6).
- **H6. The device crash path, twice, both without `should_abort`.** §13.2
  row 83 (10162–10164) and §13.4 row 171 (10436–10438). Home: §11.6 bolds
  the failure policy (8000–8004) and §12.4 (6) states the disposition
  (8936–8945); both §13 sentences become pointers with the condition right
  (F10).
- **H7. `MalformedDatum`, twice.** §13.2 row 79 and §13.4 row 172. Home:
  §11.6, which shows the loop body (7960–7964); §13.4 keeps the
  domain-separation sentence, §13.2's index the kind name.

### With half 2

- **H8. `UnboundedRun`.** §13.2 row 84 (10165–10168) and §13.5
  10545–10553 state the same condition, the `:replay` exemption and the
  loop's cell. Home: §13.5, the kind's owning section (Appendix C cites
  §13.5). §13.2's index keeps the name and a pointer (q5).
- **H9. Retained mid-boundary stores.** §13.4 row 147 (10381–10383, "as an
  errored simulation's are (§13.6)") and §13.6 10716–10722. Home: §13.6 for
  the errored case, §13.4 for boundary zero; the pointer stands.
- **H10. The bare-value throw's disposition.** §13.4 row 130 says only that
  the framework does not handle it; §13.5 10597–10603 says a loop fault
  outside the frame closes the run `stopped` under `LoopError` with the
  `Model` consistent. The run in part C shows a bare throw takes that path.
  Home: §13.5; §13.4 gains a pointer (F30).
- **H11. The disposition and the tail.** §13.4 rows 154–159 say an
  unattended run "rethrows after the shutdown tail completes"; §13.6
  10683–10709 defines the abnormal entry into that tail. Home: §13.6 for
  the tail, §13.4 for the rethrow-or-return disposition. No change.
- **H12. The interrupt.** §13.4 rows 149–153 and §13.5 10608–10610 ("a tag
  on an ordinary stop"). Consistent. Homes: §12.4 for masking, §13.5 for the
  record's tag, §13.4 for the catch site's discrimination.
- **H13. The inspection doctrine.** §13.3 rows 98 and 101 and §13.5
  10652–10664 ("Inspection is human-facing … Output devices are the other
  half of the same doctrine. Their reads are inspection bindings on snapshot
  paths (§11.2)"). Both rest on D-083 and D-130 and both meet F1 for device
  bindings. Rule jointly with the sibling (q2).

Nothing in half 1 moves across the split, and no half-2 sentence needs to
move into half 1.

### With other chapters

Part I. No sentence of half 1 restates Part I at Part I's depth. Part I says
"A failure ends it otherwise (§13.6)" (531) and names the interrupt as an
external stop (545–549); half 1 gives the catch site, the carrier and the
disposition, which is mechanism and spelling. The nearest candidate is row
161 (NaNs defeat guards), a constructive reason that argues in Part I's
terms but states no law; it may stay.

- **H14. §9 and §9.2: barriers, deployment validation, build warnings.**
  §9 4095–4097 states each step a barrier in a bold sentence (D-259), and
  §9.2 4462 bolds deployment
  validation collected (D-229); §13.1 rows 13 and 20 state both plain. §9.2
  4574 and 4588 bold D-250 bullets 1 and 4 (a completing step carries its
  warnings; `warnings(x)`); §13.2 rows 59–61 restate them, row 59 in bold.
  Home chosen by the rewritten text: §9 and §9.2. §13.1 keeps its plain
  statements as the policy's statement (they are its subject); §13.2 makes
  row 59 plain and reduces rows 60–61 to a pointer (M9).
- **H15. §9's step table against §13.1's "three places".** §9 4100–4102
  says the structure step runs "declaration bodies only", the nominal
  evaluation "every user function once", and the activation at `T` the
  continuous tier's functions. §13.1 row 10 names three places, two of them
  inside the nominal evaluation. Home: §9 (rewritten); §13.1 is corrected to
  agree (F5).
- **H16. §6.1's one-level rule.** §6.1 1541–1542 bolds "Every connection
  endpoint names an immediate child and one of its faces" (D-207). §13.3
  rows 90 and 96 restate it as the wiring duty. Home: §6.1; §13.3 states the
  duty with a pointer, citing D-207 (it now cites no entry for it).
- **H17. §8.6 and §8.8 on `resolve`.** §8.8 3856 comments `resolve` as
  "getfield walk along "/" segments" and defers the signatures to §13.3
  (3897); §8.6 3410–3413 says the read side "resolves a path with `resolve`
  under the instance walk (§13.3)". Home of the signatures: §13.3. §8.6's
  sentence is wrong against the code twice over (F1, F3; part D).
- **H18. §11.2 on binding reads.** §11.2 7105–7119 (rewritten) bolds D-083
  and D-406, says binding selectors "reach any cell, since inspection reads
  admit deep paths", and cites D-130. §13.3's inspection row restates it.
  Both meet F1.
- **H19. §12.4 on the interrupt.** §12.4 bolds the masking (9149, D-132,
  D-394), names the unmask points with the pause block (9160–9162), says
  "The catch site (§13.4) therefore never sees a single interrupt"
  (9164–9165), and bolds the forced throw reaching the defensive arm (9199,
  D-268, D-398), with its disposition and the stores' reset (9201–9205).
  §13.4 rows 151–153 restate all of it. Home: §12.4, which the rewrite
  chose. §13.4 keeps the catch-site clause ("a single interrupt never
  reaches the branch; the branch stays for Julia's forced throw and
  defensively") and points to §12.4 (M7). Inbound 9164 and 9201 rely on
  §13.4 keeping that clause.
- **H20. §12.6 and §12.7 on boundary zero and reproduction.** §12.6
  9424–9433 states `MissingInit`, the alternative doors and the
  boundary-zero throw leaving `built`, citing §13.4 and D-223; §12.7
  9666–9677 bolds the replay bound (D-218) and the halt (D-128), and
  9750–9752 describes the reproduction workflow, citing §13.4. §13.4 rows
  132–148 are the home of the catch-site facts (pointer, host, recipe,
  boundary-zero catch), and §12.6–§12.7 already point here. No change beyond
  citing D-128 and D-218 at rows 132–133.

Two other-chapter glosses repeat a half-1 error and are recorded in part D:
§10.6 6531–6532 calls the cursor "the loop-state field" and §9.5 5094 calls
the nonfinite check "loop-level" (F20).

## C. Proposed structure

No section is renumbered and none is retitled. 266 inbound rows point at the
half's sections (part D). No file links a `####` anchor of chapter 13's half
1, since the half has none (checked with `rg 'spec.md#13'` over `docs/`: only
section-level link definitions), so `####` labels can be added freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | "Tests match on kind plus payload fields, never on message text. Messages are therefore pure presentation." | §13.2 10074–10076 (row 53) | merged into the Appendix C sentence (9992–9993, row 27), one statement | no |
| M2 | the two rendering rules, strings never instances and the didactic style | §13.2 10078–10088 (rows 54–56) | up, directly after the carrier block (10032) and before `UserCodeFraming` (10034), so "didactic" (10039) and "never as values" (10038) follow their rule | no |
| M3 | the service paragraph and `attach!`'s `EmptyGreedyClaim` | §13.2 10123–10128 (rows 71–73) | up, between the build paragraph (ends 10107) and the runtime paragraph (10109), so the artifact cases come first and the runtime index follows the runtime paragraph it lists; the diagnostic-cell link moves with `EmptyGreedyClaim`'s cell | no |
| M4 | `StepError{C}` | §13.2 10013–10015 (row 35) | trimmed to a clause pointing to §13.4 (H1) | no |
| M5 | "The two ways of applying one plan (§14.4) use the same arrangement" | §13.3 10203–10204 (row 94) | merged into 10244–10246 (row 104), which says it again | no |
| M6 | the interrupt carve-out, then the disposition | §13.4 10386–10396 and 10398–10408 (rows 149–159) | up, after the `StepError` sketch (ends 10333) and before "Reproducibility" (10335), in that order, so boundary zero (10350–10384) follows the stop path and the loop's disposition it contrasts with (H4, H5) | no |
| M7 | the masking and forced-throw restatement | §13.4 10389–10394 (rows 151–152) | trimmed to the catch-site clause with a pointer to §12.4 (H19) | yes, q4 |
| M8 | the runtime warning index | §13.2 10128–10168 (rows 74–84) | kept as an index, one line per kind, each named, with its owning section (q5) | yes, q5 |
| M9 | the build's warnings on its artifacts, `warnings(x)` | §13.2 10097–10102 (rows 59–61) | row 59 plain; rows 60–61 reduced to a pointer to §9.2 (H14) | yes, q4 |

All moves stay inside one section, so each stays inside one unit.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **Chapter opening (q1).** One context sentence (§8.4 fixed what is caught,
  §9 when, this chapter how a failure is reported and what the framework
  offers around it), one roadmap sentence naming §13.1–§13.8 in order, then
  the FlightCore lessons sentence. "This section" becomes "This chapter".
- **§13.1.** Unchanged order: context, the two populations, the barrier,
  the **Rule.** and its pass-by-pass yield, no cascade suppression with the
  example. The context gains one sentence naming the parts. No subheadings
  at 561 words.
- **§13.2.** Two `####` labels (q3): "The diagnostic and its carrier" and
  "Where warnings live". First: context; the value, kinds, payload, severity
  and the raised/policy fields (with M1); the carrier and its parameter (with
  M4); the sketch; the rendering rules (M2); `UserCodeFraming`; the
  `FieldError` recognition and `BundleFieldError`. Second: the criterion
  rule; the build (M9); the service and `attach!` (M3); the runtime
  paragraph; the index (M8). `species` (10005) keeps its link and gains a
  gloss, since §13.4 defines it.
- **§13.3.** Unchanged order: the primitives, the two duties, the client
  table, the warrants, the principle, the internal-fact sentence (with M5),
  `resolve_terminal`'s standing (as ruled under F2). The context gains a
  parts sentence. No subheadings at 816 words.
- **§13.4.** `####` labels from the bold labels (q3), in this order: "Where
  a failure is caught" (the try, the cursor, its sketch); "The runtime
  carrier" (`StepError`, the species rule, the parameter, the sketch); "The
  interrupt" (M6, with M7); "Disposition" (M6); "Reproduction" (rows
  132–134); "Boundary zero" (rows 135–148); "The nonfinite check" (rows
  160–169); "Device-side failures" (rows 170–173). A context paragraph opens
  the section: a runtime failure is model code throwing inside a frame or
  boundary zero, caught once, framed by the cursor, and reproducible by
  replay. Checked: "stop path" and "graceful tail" (interrupt) precede
  boundary zero's raw propagation; the loop's disposition precedes boundary
  zero's; the recipe precedes "the halt-then-`step!` recipe above".

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 9909–10169: heading, roadmap, §13.1, §13.2 | M1–M4, M8, M9 within | — | 2,287 |
| B | 10170–10442: §13.3, §13.4 | M5–M7 within | — | 2,557 |

Total 4,844 words. Units C to E are unused.

A falls just under the 2,500-word floor. The alternative, A′ = 9909–10253
(3,103 words, adding §13.3) and B′ = 10254–10442 (1,741, §13.4 alone),
moves the shortfall to B′ and parts §13.3 from §13.4, which cites nothing of
it, so either cut is clean. A and B are closer to even; recommendation A and
B (q9).

### Code blocks, charts and tables

The half holds four code blocks and one table, and no chart:

- 10019–10032: `Diagnostic` and `DiagnosticError`, a `julia` fence of
  pseudo-code (`…` for the payload). Carry verbatim except as ruled under F6
  and F7 (the `warnings` field; "a barrier's batch").
- 10206–10210: the client table, three rows, bold row names and one bold
  cell. Carry; the inspection row waits on q2; the bold cells become plain
  (q3).
- 10279–10285: `ExecutionCursor`, a `julia` fence of pseudo-code. Carry; its
  comment "component path (execution-order index)" shares F13.
- 10323–10333: `StepError`, a `julia` fence; real field names, `cursor`
  untyped where the code has `CursorFrame`. Carry; the comment "the boundary
  time" shares F12.
- 10345–10348: the reproduction recipe, two calls. Carry verbatim.

Lists: §13.1's two populations (9928–9947), §13.2's rendering rules
(10080–10088) and runtime index (10131–10168), §13.3's primitives
(10175–10185). Inline arrows: `integrate → project → event iteration → ticks
→ publication` (10258–10259).

### Running the half's code

Loaded with `test/repl.jl` inside `module H1Check` (script
`scratch_survey/h1/run/blocks.jl`, run with `julia --project=test -t 2`;
output in `run/output.txt`). Each check printed its result; none failed.

- **10019–10032, the diagnostic sketch: cannot run** (pseudo-code). Checked
  against the code: `Diagnostic` is abstract and `WireTypeMismatch <:
  Diagnostic`; `DiagnosticError`'s bound is `Union{Diagnostic,
  Vector{Diagnostic}}` as sketched, but its fields are `(:carried,
  :warnings)`, not `carried` alone (F6).
- **10279–10285, the cursor sketch: cannot run** (pseudo-code).
  `ExecutionCursor` is mutable with fields `(:comp, :fn, :phase, :index)`
  (`src/executor.jl` 17–23): `comp` is the component's index in walk order
  (F13), and `phase` takes eight values (F14).
- **10323–10333, the `StepError` sketch: passed as a shape check.** Fields
  `(:cursor, :t, :boundary, :host, :cause)`, types `CursorFrame`, `Float64`,
  `Int64`, `Symbol` and the bound `Union{Exception, Diagnostic}`.
- **10345–10348, the recipe: ran and passed.** A `Tripwire(0.35)` armed by a
  staged write failed at frame 4 with pointer `k = 3`, host `:loop`; on a
  fresh twin `replay!(sim2, trc; to_boundary = 3)` left `(:initialized,
  :replay)`, and `step!(sim2; frames = 1)` raised the same `StepError`
  (cursor, pointer and cause type equal), leaving the twin `errored`.
- Claims checked in passing:
  - §13.1's worked example with two typo'd wires (`g1/ot`, `g2/ot`): the
    carrier held `UnknownPort g1, UnknownPort g2, UnconnectedInput s1,
    UnconnectedInput s2`, and `showerror` printed them in that order, so
    neither pair is adjacent (F4).
  - §13.2's message: `x_deriv` destructuring `m` with no `m_init` raised
    `DiagnosticError{BundleFieldError}`, reason `:undeclared`, rendering
    "`` `plant`: `x_deriv` destructures `m`, but `plant` declares no `m_init`
    `` — the bundle carries {x, y, t} (§5.2)", the spec's example shape.
  - **`StepError.t` is not the boundary time**: a `Tripwire(0.05)` at `h =
    0.1` failed with `t = 0.05`, cursor `("c", :x_deriv, :integrate, 2)`,
    pointer 0 (F12).
  - Boundary zero: a `Mine` armed by the condition raised
    `StepError{Detonated}` from `init!`, pointer 0, host `:boundary_zero`, `t
    = 0.0`, lifecycle `built`, no termination record; `trace(sim)`, `run!`
    and `step!` each refused with `DiagnosticError{MissingInit}`. **`restore!`
    of an earlier checkpoint was legal and left the simulation
    `initialized`** (F17).
  - Disposition: deviceless `run!` rethrew `StepError{Tripped}`, lifecycle
    `errored`; with a `Pad` rostered `run!` returned `nothing`, lifecycle
    `errored`, the record's source `LoopError`; `step!` with the `Pad`
    attached rethrew.
  - Nonfinite: the `Diverger`/`Consumer` pair raised
    `StepError{NonfiniteState}` naming `div`, leaf `q`, `t = 0.1`, boundary
    0, never the downstream `con`.
  - **A bare `throw(42)`** inside `x_deriv` escaped `run!` as a
    `MethodError` (the constructor's), and the run closed `stopped` with
    `LoopError(MethodError(StepError, …))` on its record and the `Model`'s
    status `:consistent` (`run/bare.jl`; F30).
  - §13.3: `resolve(SampledLoop(), "plant")` returned the `Plant`;
    `resolve(Group((; i = SampledLoop())), "i/plant")` refused with
    `PathResolution`, reason `:reaches_past` (F3); `resolve_terminal` split
    `"plant/u"` into the plant and `"u"`; `input_faces(Sum()) == ["a",
    "b"]`, `output_faces(SampledLoop()) == ["y", "cmd", "power"]`.
  - **A device read binding past a generic seam is refused**: `attach!(sim,
    Pad("t"), Readout(q = get_state("inner/plant", :q)))` on a
    `GenericHold(SampledLoop())` threw a collected `DiagnosticError` holding
    `PathResolution`, reason `:past_generic` (F1).
  - `warnings` has methods on `Build`, `Deployment`, `Model` and
    `Simulation` (F31).

## D. Inbound citations

The rows analysed are the 266 rows of `inbound.tsv` whose target is §13,
§13.1, §13.2, §13.3 or §13.4 (copied to `scratch_survey/h1/mine.tsv`). The
eight bare §13 rows belong to half 1; three of them rely on half-2 content
(below).

By file: `decisions.md` 138 (Spec 70, Rationale 28, Position 22, Rejected
12, Annotation 6), `spec.md` 89, `implementation.md` 29, companions 7
(`frame_walkthrough.md` 4, `event_visibility_walkthrough.md`,
`linearization_walkthrough.md` and `sample_time_proposal.md` 1 each),
`pending.md` 2, `extensions.md` 1. The 89 `spec.md` rows: Part I 2, Part II
14, Part III 27, §14 9, Appendix A 2, Appendix B 3, Appendix C 19, the
glossary 13.

By target: §13 8, §13.1 43, §13.2 77, §13.3 37, §13.4 101 (in `spec.md`
alone: 5, 13, 28, 11, 32).

Ranges recorded at their ends only: `implementation.md` 875
("§13.4–§13.6") also covers §13.5, the sibling's. No other range touches the
half.

### Citations relying on moved or trimmed content

M7, the interrupt restatement (§13.4 10389–10394):

| file:line | fact relied on | after M7 |
|---|---|---|
| spec 9164–9165 (§12.4) | "The catch site (§13.4) therefore never sees a single interrupt" | holds if §13.4 keeps "a single interrupt never reaches the branch" |
| spec 9201 (§12.4) | "That is the one way the branch §13.4 keeps is reached" | holds if §13.4 keeps "the branch stays for the forced throw and defensively" |
| log 4342 (D-132 Rationale) | §13.4's catch site never wraps an `InterruptException` | holds; row 149 stays |
| log 11355, 15878 (D-268 annotation, D-398 bullet 2) | the forced throw reaches §13.4's defensive arm | holds as above |

M9, the build's warnings (§13.2 10097–10102):

| file:line | fact relied on | after M9 |
|---|---|---|
| spec 4577 (§9.2) | "Logging is presentation and never a home (§13.2)" | holds; the criterion rule (row 57) stays |
| spec 13206 (Appendix B) | `warnings(x)` on `Build`, `Deployment`, `Simulation` (§9.2, §13.2) | holds through §9.2 |
| spec 14735, 14775 (glossary, artifact and state) | a warning lives on its artifact or in its state's status (§13.2, D-250) | holds; row 57 |

M8, the runtime index (§13.2 10128–10168):

| file:line | fact relied on | after M8 |
|---|---|---|
| spec 7226 (§11.3) | a batch entry outside the surface "is discarded with a runtime warning (§13.2)" | holds if the index keeps the write-surface kinds |
| spec 8015, 8025, 8416 (§11.6, §11.8) | the runtime warning stream (§13.2) | holds; row 66 |
| spec 8478 (§11.8) | rate-limiting "wherever its source can repeat" (§13.2) | holds if row 67 keeps the quoted phrase |
| log 4616 (D-136 Rationale) | the same phrase | as above |

M1–M6 reorder within their sections; no row names a moved sentence by
position.

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to their own chapters.

| file:line | claim | what half 1 or the code says |
|---|---|---|
| spec 3410–3413 (§8.6) | the read side "resolves a path with `resolve` under the instance walk (§13.3)" | the public `resolve` is one level (`src/assembly.jl` 354–365), and binding reads walk the strict service walk (F1, F3) |
| spec 12831–12833 (Appendix B) | `resolve` "enforces the one-level rule for wiring and the generic-holding rule for deep reads, at the primitive (§13.3)" | the generic-holding rule is `resolve_authored`'s (`src/assembly.jl` 1494–1534), not `resolve`'s (F3) |
| spec 7108–7110 (§11.2) | binding selectors "reach any cell, since inspection reads admit deep paths" | refused past a generic seam since D-406's code (F1) |
| spec 4706 (§9.3) | "a `UserCodeFraming`-wrapped build failure (§13.1)" | `UserCodeFraming` is §13.2's (row 38); §13.1 states the fail-fast policy only. Minor |
| spec 6531–6532 (§10.6) | the cursor is "the loop-state field recording where execution stands (§13.4)" | the cursor is the model's, on the executor (D-317 bullet 6) |
| spec 5094 (§9.5) | "the loop-level nonfinite-state check" | the model's, inside `integrate!` (F20) |
| spec 12181 (§14.8) | "exceptions-are-broken-machinery line (§13)" | the doctrine is §13.5's (10447–10448), not the chapter's opening |
| spec 14690–14691 (glossary, execution cursor) | "the component path as an index into the `Outputs`'s execution order" | the index is into walk order (F13) |
| spec 13617–13620 (Appendix C, `StepError`) | "boundary time"; the phase list | the clock at the catch (F12); eight phases (F14) |
| log 5919 (D-159 Position) | "§13.2's two-stream partition stands" | D-250 replaced the two streams (log 9916); D-214 left two severities. D-159 carries no annotation |
| log 9967–9969 (D-250 Rejected) | the CI switch: "§13.2 already rejects it" | §13.2 says it "could be added, but is not built" (F8) |
| log 9508–9509 (D-242 Position) | "device read bindings … resolved by the instance walk" | the code walks them strict since D-406 (F1) |
| log 4244–4252 (D-130 Position) | inspection = device read bindings and GUI panels, instance walk, drift loud as `ReadBindingUnresolved` | strict for bindings (F1); `ReadBindingUnresolved` retired (D-406 bullet 2); the GUI parked (D-310) |
| log 3711, 3734 (D-114) | the boundary index carried in the snapshot "what §10.4/§13.4's" counter indexes | historical since D-230 (chapter 12's survey recorded it) |
| log 4298, 4319 (D-131) | §13.4 counts the five lifecycle states | §13.4 enumerates none; §12.6 does. Minor |

### Log entries whose Spec field would change

- Under M1–M9: none; every move is inside its section.
- Spec fields stale before any move, entries that rule half 1 without
  listing its section (track 2):
  - D-058: lists Appendix C alone; rules §13.2 (rows 25–28, 33, 38, 53–56).
  - D-261: lacks §13.4 (rows 110, 117: the `Outputs` rename, `StepError`'s
    time and boundary).
  - D-274: lacks §13.4 (rows 119, 140–143), though §13.4 cites it at 10369.
  - D-203: lacks §13.2 (row 82), though cited there.
  - D-255: lacks §13.2 (row 84), though cited there.
  - D-224: lists §14.8 alone; rules row 148.
  - D-394, D-398: list §12.4 (and §12.1) alone; rule rows 151–152.
  - D-294: lacks §13.4 (row 151's unmask points).
  - D-389: lacks §13.4 (row 159).
  - D-401: lacks §13.2 (row 81).
  - D-406: lacks §13.3 (row 99), though cited there.
  - D-022: lacks §13.4 (row 173).
  - D-251, D-254: lack §13.2 (row 62).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-214 (rows 27, 30–32; never cited in the half),
D-136 (66–69; never), D-130 (93–98, 104; cited only at 10198 and 10239),
D-207 (90, 96; never in §13.3), D-242 (94, 95), D-059 (109–113, 116–117,
132, 154–155, 160, 162; cited once), D-128 (117–118, 132–133; never in
§13.4), D-218 (133; never), D-398 (152, in place of D-268's annotation),
D-394 and D-294 (151), D-105 (79, 170–172; never in the half), D-022 (173),
D-235 (121), D-317 (138, 149), D-389 (159), D-401 (81), D-251 and D-254
(62), D-057 (4, 13), D-259 (13), D-341 (45, 48, 50), D-261 (110, in place of
D-253).

### Superseded and half-superseded citations

- **D-253** (cited 10269, row 110): its clause keeping the `Dataflow` name
  is superseded by D-261's rename (log 10645–10647), and D-261 is where the
  execution order becomes component indices beside the rows (log
  10598–10601). Cite D-261.
- **D-268** (cited 10394, row 152): the forced-throw disposition is in its
  annotation (log 11354–11358), which D-398 bullet 2 (log 15878–15881) now
  states as a Position. Cite D-398 beside or instead.
- **D-255** (cited 10168, row 84): bullet 5 says "`Inf` and no faces"; the
  condition is "no honoured stop request" since D-316 (D-203's annotation,
  log 7766–7769, notes the same replacement). The clause the row relies on,
  the advisory in the loop's cell, stands.
- **D-130** (cited 10198, 10239): its Position names `ReadBindingUnresolved`
  (log 4252), retired by D-406 bullet 2, and GUI panels (parked, D-310),
  with no annotation for either. Its inspection-client clause is F1.
- **D-058** (cited 9989): its Position says "a single `BuildError`" (log
  1847); D-222 renamed the carrier and says "the log keeps its vocabulary"
  (log 8682–8683). No repair needed beyond an annotation pointer.

### Rulings that need an entry stating them in a Position

1. "Tier and event checking read only the component list, so they run and
   merge" (row 17): D-229 Rationale (log 8968–8971).
2. The no-partial-results argument (row 21) and the clustering reason (row
   8): D-057 Rejected, D-229 Rationale. A reason, not a ruling; may need
   none.
3. A declaration takes no bundle, so only the plain frame applies (row 42):
   D-248 Rationale (log 9815–9816).
4. A warnings-as-errors switch (row 64): D-250 Rejected (log 9967–9969)
   against the spec's "could be added" (F8).
5. A stopped-sim service's warnings live on its report (rows 71–72): D-250
   Rationale (log 9945–9948) and the Rejected "superseded position" (log
   9970–9972). D-250's Position names `Build`, `Deployment` and `attach!`,
   never `trim!`.
6. The stream surfaces through the framework status (row 68): D-136
   Rationale (log 4623–4630).
7. The walk's two duties (rows 89–90): D-061's annotation of 2026-10-12 (log
   1955–1961), which restates D-207 for the primitive.
8. The scoping principle and its cost argument (rows 100–102): D-130
   Rationale; constructive rationale, may need none.
9. The test spelling `@test_throws StepError{ConformanceFailure}` (row 128):
   D-225 Rationale.
10. The branch kept defensively (row 153): D-132 Rationale (log 4343).
11. The boundary-zero remedy, a corrected condition (row 145): D-223
    Rationale (log 8733–8734).
12. The interrupt routed to the stop path at the catch site (row 149): D-132
    Rationale (log 4341–4343); D-317 bullet 8 states "never wrapped" only.
13. The compact-frame rendering (row 120): D-058 Rejected (the
    `compact_backtrace` lesson).

### Rulings with no entry at all

The list of collecting checks (row 6, an inventory); "probing against
unresolved wiring would be meaningless" (row 14, a reason); the didactic
frame rendering first (row 40); the author's own tuple with bundle names
(row 47); a kind *is* a Julia type (row 29, by implication only); the
stream never collected (row 70); the index sentence (row 74); the cursor
covering "the environment closures" (row 114, F15); `resolve_terminal`'s five
clients (row 105, F2); the service-path remedy by declaring the concrete
type (row 103; `test_readers.jl` 279–283 cites D-125, whose Position was not
checked to state it); NaNs defeat guards and the cheapness of the pass (rows
161, 163, 167, reasons). Descriptions with no entry, needing none: rows 6,
74, 114.

### Stale entry text and Spec fields

- D-058 Position (log 1847): "`BuildError`"; "Warnings ride the same stream
  and never throw" (log 1852), which D-250 replaced with the artifact
  criterion. No annotation.
- D-097 Position (log 3096–3099): "device id" in `DeviceCrash`; annotated
  2026-10-15 (log 3108–3112). Done.
- D-130 Position (log 4250–4252): GUI panels, `ReadBindingUnresolved`, the
  instance walk for bindings (above, F1).
- D-159 Position (log 5915–5920): "a sixth severity" and "§13.2's two-stream
  partition stands", both overtaken (D-214's two severities, D-250's one
  criterion). No annotation and no supersession line.
- D-242 Position (log 9508–9509): bindings by the instance walk (F1).
- D-250 Rejected (log 9967–9969): "§13.2 already rejects it" (F8).
- D-255 bullet 5 (log 10232): "`Inf` and no faces" (above).
- D-261 bullet (log 10637): "`StepError`'s time and boundary beside
  `NonfiniteState`'s payload stay as they are"; the time is the clock at the
  catch (F12). The entry is right; the spec's word "boundary time" is not.
- Spec fields: part D's list.

### Findings carried from earlier chapters

`docs/spec_rewrite/README.md` 43–80 lists three "Chapter 13" bullets
holding five items; one item of the first bullet falls in half 1. One
Appendix D item also touches it.

- **§13.4's unmask points add the pause block (B83, B35).** Confirmed: 10391
  says "a frame-top or wait unmask point". §12.4 9160–9162 names "the frame
  top … and points inside its wait and pause blocks"; D-294 bullet 1 (log
  12895–12897) "beside the frame top and the pause block"; the glossary
  (`#g-operator-interrupt`) "a frame-top, wait or pause-block unmask point".
  Proposed: "a frame-top, wait or pause-block unmask point (§12.4)", citing
  D-294 (F19).
- **§13.5's stop policy pointer and "GUI stop button" (B82, B83), §13.7's
  D-311 bold and `Constant` admission.** Half 2's.
- **Appendix D: `#g-entry` lacks the wiring entry that §6.1 and §13.3
  use.** Confirmed for half 1: 10179 ("the entries of `input_wires(c)`") and
  10232 ("A wiring entry is carried by the declaring *type*"). The glossary
  (13856, `#g-entry`) says "never used bare" and lists table, input,
  executor, roster, batch and condition entries. §13.2 also uses "the
  unknown `except` entry" (10088) and "entry point" (10102), neither listed.
  The glossary fix is Appendix D's; the rewrite keeps "wiring entry" and
  writes "entry point" as is, or "door" where chapter 12's R14 reading
  applies (a door builds a run; the build's entry point is not one).

### Factual problems in half 1

- **F1. Device read bindings no longer take the instance walk — serious.**
  §13.3's table puts "device read bindings, GUI panels, snapshot and log
  inspection" under "the instance walk" (10210, row 95), and 10221–10223
  says "A generic seam is not an error for a client that never claimed
  substitutability" (row 98). D-130's Position (log 4250–4252) and D-242's
  (log 9508–9509) say the same. §11.2 7108–7110 (rewritten) says binding
  selectors "reach any cell, since inspection reads admit deep paths", and
  §8.6 3410–3413 says the read side resolves "under the instance walk".
  Against it: since D-406, attach resolves a binding's reads through the one
  read resolver (log 16087–16094), and that resolver walks every path
  selector with `resolve_authored` (`src/readers.jl` 505–506), the strict
  service walk that refuses a segment past a generically held field
  (`src/assembly.jl` 1525–1532). The run in part C attached
  `Readout(q = get_state("inner/plant", :q))` to a `GenericHold` and got
  `PathResolution`, reason `:past_generic`. Before D-406's code commit
  (`a630dea`) the binding resolved against the layout's address table, an
  instance-level lookup. D-406's Position and Rationale discuss face aliases,
  root inputs and collection, never generic seams, and D-130's own Rejected
  list (log 4263–4266) refused a single strict rule because "the shipped
  XPlane binding, GUI panels and the log all traverse generic seams". Two
  Positions and the rewritten §11.2 state one behavior, the code another,
  and no entry rules the change. Two readings: D-406 meant to make bindings
  strict like trim reads, and §13.3, §11.2, §8.6, D-130 and D-242 lag; or
  the strictness is an unintended side effect, and the resolver should walk
  instances under a binding (or a live-store) source. Either answer changes
  the code or a ratified Position. Proposed: escalate (q2). Whatever the
  ruling, "GUI panels" goes from the table (D-310 parked the GUI).
- **F2. `resolve_terminal`'s five clients.** 10248–10252: "five clients share
  it across the three rules … Condition addressing (§14.3) and tap
  resolution (§14.10) are service clients. Device-binding validation (§11.2)
  and snapshot inspection are inspection clients. The result is one
  splitter and one did-you-mean site." In the code `resolve_terminal` has
  two callers, both wiring (`src/assembly.jl` 547, 573), plus its public
  form (375). Conditions walk with `resolve_authored` (`src/conditions.jl`
  199), taps and binding reads go through the read resolver
  (`src/readers.jl` 488, 506), and snapshot inspection reads the address
  table. No entry states the five-client claim. Proposed: "`resolve_terminal`
  is public because a declaration body needs it, as §8.8's helpers do. The
  services and the readers split their own paths through the service walk
  (§14.3, §14.4)", or cut the paragraph to its first clause.
- **F3. `resolve` is one level, and the walk is two.** 10175 calls `resolve`
  "the getfield walk along `/`-segments", and 10187–10196 gives "the walk"
  both duties. The public `resolve` names an immediate child and refuses
  anything deeper (`src/assembly.jl` 345–365, docstring citing D-207); the
  run refused `"i/plant"` as `:reaches_past`. The generic-holding duty
  belongs to the internal service walk `resolve_authored` (1479–1534), which
  `implementation.md` 93–96 maps separately. D-061's annotation of
  2026-10-12 (log 1955–1961) keeps "the declared-type walk" as standing,
  which the service walk is. Appendix B 12831–12833 repeats the conflation.
  Proposed: 10175 "`resolve(assembly, path::String) → AbstractComponent`
  resolves an immediate child, a container element's key segment included";
  10187 "Resolution enforces two duties, and they belong to different
  clients"; the second duty "is enforced by the service walk, which follows
  declared field types alongside instances". §13.3's "Which of the three
  rules a client resolves under is internal" (10244) already licenses two
  functions.
- **F4. "They render adjacently, because diagnostics sort by path."**
  9979–9980. `showerror` groups a collection by kind in first-appearance
  order and sorts each group by path (`_groups` and `showerror`, `src/diagnostics.jl` 111–148),
  as §13.2 says (10016). The did-you-mean is an `UnknownPort` and the unfed
  input an `UnconnectedInput`: two groups. With two typo'd wires the run
  printed both `UnknownPort`s, then both `UnconnectedInput`s. D-057's
  Rejected "adjacent path-sorted pairs" (log 1839) predates the grouping.
  Proposed: "Both are reported in the one throw, and the did-you-mean names
  the input the other error says is unfed, so the pairing explains itself."
- **F5. "User code runs in three places."** 9938–9942 names the
  interface-connection bodies in the structure step and two probe runs of
  the nominal evaluation. D-248 frames "every user-authored method the build
  invokes", declarations included (log 9795–9801), and §13.2 says so
  (10040–10043); §9's table (4100–4102) lists declaration bodies in the
  structure step, every user function in the nominal evaluation, and the
  continuous tier's functions in the activation at `T`. Proposed: "User code
  runs in every step. The structure step reads the declarations,
  interface-connection bodies among them. The nominal evaluation probes
  every user function, the stage-1 probes first, and an activation at
  another scalar evaluates the continuous tier's functions (§9.1)."
- **F6. The carrier sketch lacks `warnings`.** 10029–10031 shows
  `DiagnosticError{P}` with `carried::P` alone. The code adds
  `warnings::Vector{Diagnostic}`, "the build's warnings so far … a step that
  throws renders its warnings with the collection it throws"
  (`src/diagnostics.jl` 77–92), which D-250 bullet 1 rules and §13.2 states
  (10100). Proposed: add the field with that comment, a ruled edit to a code
  block.
- **F7. "A barrier's batch."** 10028, the sketch's comment. `#g-batch`
  reserves *batch* for a device's staged write set and says "Error
  reporting *collects*". Proposed: "the collection type for a barrier's
  throw".
- **F8. The warnings-as-errors switch.** 10106–10107: "A warnings-as-errors
  CI switch could be added, but is not built." D-250's Rejected list (log
  9967–9969): "*Promoting build warnings to errors under a CI switch:*
  §13.2 already rejects it; an empty selection is a fact about the model
  worth knowing, not a defect." The spec sentence has read the same since
  the docs split (`8e2505c`), so D-250 misdescribes it. D-058's Rejected
  list (log 1866–1867) valued the switch ("a separate warning channel …
  blocks a warnings-as-errors switch"). Not serious: no code exists either
  way, and D-250 is the later entry. Proposed: rule the spec to D-250, "A
  warnings-as-errors switch is rejected: a warning is a fact about the
  model, not a defect (D-250)", with D-058 annotated in track 2; or keep the
  sentence and annotate D-250 (q10).
- **F9. The pacer's record does not ride in the cells.** 10117–10119: "The
  §10.7 pacer diagnostics and the §12.2 liveness heartbeats ride in the same
  cells". The heartbeat does (`DiagCell.heartbeat`, `src/dataplane.jl`
  130–159). The pacer's record is its own field of the framework status,
  beside the writers' records (`FrameworkStatus(writers, pacer)`, 275–278;
  the glossary's framework status, 14372–14377). Proposed: "The liveness
  heartbeat (§12.2) rides in the same cells, and the pacer's record (§10.7)
  sits beside the writers' records in the status."
- **F10. The crash path without `should_abort`.** 10163–10164 ("the sim
  continues with the device absent") and 10436–10437 ("while the sim keeps
  running"). With `should_abort` set, the wrapper's exit also requests a sim
  stop: §11.6 8000–8004 bolds the policy, §12.4 (6) 8938–8940 states it,
  D-030's annotation (log 1080–1083) and `_wrap` (`src/devices.jl` 423) do
  it. And "liveness heartbeat" (10437) is not part of the crash path: the
  wrapper reports `DeviceCrash` into the device's cell; the heartbeat is how
  a hang or starvation shows (§12.2). Proposed: "A genuine bug takes the
  per-device crash path: the wrapper reports `DeviceCrash`, and the run goes
  on without the device unless its attachment set `should_abort` (§11.6)."
  The same clause for 10163.
- **F11. Kind names (lesson 20).** `NonfiniteState` (Appendix C 13623,
  §13.4) is not named where the check is stated (10412–10414), only a
  paragraph later. §13.2's index states six kinds' conditions without their
  names (`ChatteringBudget`, `FiringBudget`, `DebtReanchor`, `ThreadBudget`,
  `DeviceJoinTimeout`, `DeviceCrash`). Proposed: one name each (q5).
- **F12. `StepError`'s time is the clock at the catch.** 10289 ("the
  boundary time"), the sketch's comment (10328) and Appendix C 13617–13620.
  The field is `_seconds(clock.t)` at the catch: "the boundary time in a
  boundary phase, the stage or trial time mid-integration"
  (`src/diagnostics.jl` 220–221, `src/model.jl` 513–521). The run and the
  suite (`test_failures.jl` 206) show `t = 0.05` for a throw at an RK4
  half-step at `h = 0.1`. D-261 keeps "`StepError`'s time" as is (log 10637).
  Proposed: "the clock at the failure, a boundary time in a boundary phase
  and the stage or trial time inside integration".
- **F13. The cursor's component index.** 10267–10269: "the component path,
  an index into the execution order that `Outputs` … carries (D-253)". The
  cursor stores the component's index in walk order (`comp`, "the
  component's index in the flat", `src/executor.jl` 18), read back through
  `Structure`'s components (`src/model.jl` 518–519). The `Outputs`'s
  execution order is a vector of those indices beside the rows (D-261, log
  10598–10601). An index *into* the order would be a position in it. The
  glossary (14689–14691) and the sketch's comment (10282–10283) repeat it.
  Proposed: "the component, by its index in walk order, the index the
  execution order lists (D-261)".
- **F14. The cursor's phases.** 10271–10272 names integration stage,
  event round, localization trial and tick. The code has eight: `:drain`,
  `:integrate`, `:arrival`, `:validation`, `:trial`, `:project`, `:round`,
  `:ticks` (`src/executor.jl` 21), and D-317 bullet 6 requires the drain
  phase (log 13974–13976). The suite tests the drain, arrival and
  projection frames (`test_failures.jl` 182–198, 304–333). Proposed: "the
  phase: the frame-top drain, integration stage *k*, the arrival sweep, the
  θ = 0 validation, a localization trial, projection, event round *r*, or
  the ticks". Appendix C's `StepError` row follows in track 2.
- **F15. "The environment closures."** 10277. Nothing in the spec, the log
  or `src/` is called an environment closure; Redstone's environment is
  components (D-364's constant source). The phrase looks inherited from
  FlightCore. Proposed: drop the clause.
- **F16. One `try` per frame, not per boundary.** 10256–10260: "wraps each
  execution of the boundary macro-sequence … in a single `try`". `frame!`
  wraps the whole frame in one `try`, the top hook's drain and every `t*`
  boundary included (`src/frame.jl` 29–56: "The whole frame is the one `try`
  of §13.4"), and `init!` wraps boundary zero (`src/model.jl` 188–194).
  Proposed: "The `Model`'s `frame!` wraps each whole frame, every boundary it
  settles included, in a single `try`, and its `init!` wraps boundary zero
  the same way."
- **F17. What resets the stores after a boundary-zero throw.** 10381–10382:
  "until the next `init!` resets them". `restore!` and `replay!` are legal
  there (10378) and copy a checkpoint's state back (D-274); the run showed
  `restore!` taking a `built` simulation to `initialized`. §12.4 9204–9205
  says "until the next `init!`, `restore!` or `replay!` resets them, as
  after a throw inside boundary zero"; D-268's annotation of 2026-10-15 (log
  11373–11377) and D-398 bullet 2 say the same for the forced throw. D-223
  bullet 2 (log 8720–8721) still says "until the next `init!`". Proposed:
  "until the next `init!`, `restore!` or `replay!` resets them".
- **F18. "Surfaces the status through the control plane and GUI."**
  10402–10403. D-310 parked the GUI; the lifecycle is derived, not stored
  (D-317 bullet 7); the outcome is the `Run`'s (D-255); the control plane's
  entry (14373–14377) holds no status. The next sentence already says what
  happens. Proposed: "An interactive session logs the rendered error and
  returns."
- **F19. The pause-block unmask point (carried).** 10391. Part E, carried
  findings.
- **F20. "A loop-level `isfinite` sweep."** 10412–10413. The check is the
  model's: `integrate!` runs it after every backend return, a localized
  frame's segments included (`src/model.jl` 421–440, "the site is the seam's
  framework side and not the frame loop"), and D-317 gives the model the
  frame. The `#g-sweep` link is wrong: a sweep is a pass through the
  execution order, this is a pass over the flat buffer (10425 calls it "One
  `isfinite` pass"). "At boundaries" is loose for the same reason. §9.5
  5094 and §10.6 6531 carry the same "loop" word. Proposed: "An `isfinite`
  pass over the flat state buffer, run by the model after every integrate,
  fails fast as a `StepError` species naming the component, the state leaf
  and the boundary."
- **F21. "The build tier."** 10424. `#g-tier`: "Bare 'tier' means only
  this." Proposed: "designed out of the build".
- **F22. "Of either kind."** 9950. *Kind* is a diagnostic's identity
  (`#g-kind`). Proposed: "from either population".
- **F23. *Frame* in five senses.** The glossary's *frame* is one loop
  iteration. Half 1 also uses it for the framing diagnostic (10035, 10039,
  10044, 10048), for `frame!` ("The frame of the `Model`", 10256), for the
  cursor's record (`CursorFrame`, "the cursor's frame", 10289, 10327, 10356),
  and for stack frames ("exception frames", 10274; "compact frames", 10297).
  Proposed: "the framing diagnostic" or "the framing" for the first, "the
  `Model`'s `frame!`" for the second, "the cursor frame" with a gloss at
  first use for the third, "exception handlers" and "stack frames" for the
  last (q8).
- **F24. A self-citation.** 10226 cites "(§13.3, D-406)" from inside §13.3.
  Proposed: "(D-406)".
- **F25. The chapter opening and the Part IV roadmap.** Rows 1–3: "This
  section" for the chapter; the list omits §13.3 and §13.6. The Part IV
  roadmap (9891–9897) omits §13.3, §13.6 and §13.7, and 9902–9904 says §13
  "fixes only how a failure is reported once it happens" (q1).
- **F26. "The no-shared-mutable-model decision."** 10440–10441, unnamed and
  uncited. It is D-022 ("Periphery architecture: no shared mutable model",
  log 870–878). Proposed: cite D-022 and name what it bought, "Device code
  shares no mutable state with the model (D-022), so the two failure
  domains never mix."
- **F27. "It succeeds `InputMappingError`."** 10149–10150. A reader-cold
  name: FlightCore's exception type (D-105 Rationale, log 3398–3399).
  Proposed: "It replaces FlightCore's `InputMappingError`", or drop as
  history (q11).
- **F28. `InternalInvariant` unintroduced.** 10047. D-215 bullet 4 (log
  8258–8259): internal invariant checks "raise a distinct `InternalInvariant`
  exception outside the kind set". Proposed gloss: "an `InternalInvariant`
  (the exception a framework self-check raises, outside the kind set)".
- **F29. Duplicate glossary links.** `#g-diagnostic-cell` at 10110 and
  10118 (§13.2); `#g-face` at 10184 and 10189 (§13.3). One link per term
  per section.
- **F30. The bare-value throw's outcome is unstated.** 10319–10321 says
  only "The framework does not handle that throw (D-225)". The run
  (`run/bare.jl`): `run!` raised the constructor's `MethodError`, the run
  closed `stopped` with `LoopError(MethodError(StepError, …))` on its
  record, and the `Model`'s status stayed `:consistent` although the frame
  was cut mid-integration. D-225 records the cost in its Rationale (log
  8805–8807: "the frame and the pointer are lost, and the lifecycle word
  does not move as it does on the framed path") and bullet 3 calls it
  "Accepted, not handled". §13.5 10600–10603 describes this path for loop
  faults outside the frame. Settled by D-225, so not serious. Proposed: one
  clause, "The `MethodError` leaves the catch unframed and the run closes
  `stopped` under a `LoopError`, as a loop fault does (§13.5)."
- **F31. `warnings(x)`'s holders.** 10098–10099 names `Build` and
  `Deployment`; D-250 bullet 4 (log 9933–9935), §9.2 4588 and Appendix B
  13204 add `Simulation`, and the code `Model` too (`src/model.jl` 464–474).
  Resolved by M9's pointer to §9.2.
- **F32. `NonfiniteState`'s payload.** 10413–10414 ("naming the offending
  component's state block and the boundary"). The payload names the
  component, the leaf within its block, the value, the time and the
  frame-entry index (`src/diagnostics.jl` 284–290). Minor; "state leaf"
  replaces "state block" in F20's wording.
- **F33. "Paths are validated at build time."** 10197. True of wiring
  paths. Service paths are validated when the service resolves them (a
  condition at `init!`, trim reads at `trim!`), and inspection paths at
  attach (10224). Proposed: "Paths are validated before anything runs on
  them, and renames break loudly."
- **F34. "Compact frames per the doctrine (§13.2)."** 10297–10298. §13.2
  states no compact-frame rule; it states strings never instances (the
  `compact_backtrace` lesson) and the didactic frame first. `showerror`
  (`src/diagnostics.jl` 252–275) prints the frame line, the reproduction,
  then the cause. Proposed: "A `StepError` renders under §13.2's doctrine:
  the frame and the reproduction first, the cause second, names as strings."

Outside the half, met while checking citations: spec 3410–3413 (§8.6),
7108–7110 (§11.2), 12831–12833 (Appendix B) for F1 and F3; 4706 (§9.3),
5094 (§9.5), 6531 (§10.6), 12181 (§14.8), the glossary's execution cursor
(14689–14693) and Appendix C's `StepError` row (13617–13620). All in part D.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| opening (A) | low | 97 words recast as context, roadmap and the FlightCore sentence (q1) |
| §13.1 (A) | low | 561 words in good order; one **Rule.**; two bold list lead-ins; F4 (the render) and F5 (three places) are one-sentence fixes; F22 one word |
| §13.2 (A) | medium to high | 1,629 words, two topics under no subheading; two **Rule.** labels, 19 bold spans; D-214 and D-136 uncited; three moves (M1–M3) and two trims (M4, M9); the runtime index (q5) with six unnamed kinds; F6–F9, F10, F27–F29, F31 local fixes; F8 needs a ruling (q10); a code block with two ruled edits |
| §13.3 (B) | high | 816 words whose central table is false for one client (F1, serious, q2) and whose last paragraph is stale (F2); "the walk" conflates two functions (F3); D-130 and D-207 under-cited; the argument (rows 100–103) is constructive rationale that must survive whole |
| §13.4 (B) | high | 1,741 words with no context paragraph, seven bold labels to convert, a reorder for define-before-use (M6), a trim to §12.4 (M7), three code blocks; D-059, D-128, D-218, D-398 under-cited; F12–F20, F23, F26, F30, F32, F34 local fixes, several touching code-block comments |

Warnings for the rewriter:

- **Terms of art stay verbatim**: collect the checks, fail the evaluations
  fast; the step barrier; the dependency rule; no cascade suppression; the
  carrier; the species rule; frame-entry boundary index; the replay pointer;
  the host; the one constructor; the artifact criterion; the
  collected-warning slot; the one-level rule; the generic-holding rule;
  wiring, service and inspection clients; at the authoring or mount level;
  the boundary's first act; the error-locality inversion; domain separation;
  the defensive arm. "Strings, never instances", "the didactic style is
  policy", "logging is presentation and never a home", "one principle, not
  three concessions" and "strict exactly where a promise depends on it" are
  each a line the log fought for.
- **Two carriers, two parameters.** `DiagnosticError{P}`'s parameter is the
  policy; `StepError{C}`'s is the cause's type. A gloss that calls both
  "the policy" or both "the kind" is wrong (D-222, D-225).
- **Scope words are exact.** "a single interrupt never reaches the branch"
  (a forced throw does); "a collected carrier … No runtime check throws
  one"; "every pass that ran"; "at least" nowhere; "the first user-code
  exception aborts the phase". Keep each.
- **Counts are claims.** "three places" (F5), "five clients" (F2), "three
  facts" (the cursor), "five things" (`StepError`), "two rendering rules",
  "three exceptions pass through". Each must match its list after the
  rewrite.
- **The half cites by adjacency.** Rows 5, 7, 16, 18–20, 23, 28, 33, 38, 41,
  43–44, 58–59, 65, 91, 109, 122, 125, 129, 135, 137, 139–141, 143–144, 146,
  147, 158–159, 164–166 carry their citation one or more sentences away. A
  move that separates a rule from its citation (M2, M3, M6) needs the
  citation repeated.
- **Glossary links reset per section, once each.** Unlinked first uses:
  *carrier exception* (§13.2, §13.4), *generic holding* (§13.3), *frame*,
  *store*, *control plane*, *input mode*, *error locality* and *operator
  interrupt* (§13.4), *nominal* and the section's own *collect the checks*
  anchor (§13.1). Two duplicate links (F29). One wrong link (`#g-sweep`,
  F20).
- **Reserved words.** *batch* (F7), *tier* (F21), *kind* (F22), *frame*
  (F23), *entry* (part E, carried), *door* (chapter 12's R14: a door builds
  a run; the build's "entry point" at 10102 is not one).
- **The log's vocabulary is old.** D-058 says `BuildError` and "strata";
  D-057 says "`exports` bodies" and "stratum"; D-130 says
  `ReadBindingUnresolved` and "GUI panels"; D-159 says "a sixth severity";
  D-253 says `Dataflow`; D-255 says "stop faces". Never import them.
- **Code-block comments are ruled edits only**: F6, F7 (the diagnostic
  sketch), F13 (the cursor sketch), F12 (the `StepError` sketch).
- **History sentences.** 9917–9921 (FlightCore's lessons), 9972–9973 ("the
  cost that kept this decision open"), 10149–10150 (`InputMappingError`).
  Carry them until q1 and q11 are ruled.

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q1. The chapter opening and the Part IV roadmap (rows 1–3, F25).** The
opening calls the chapter "this section", names no section numbers and omits
§13.3 and §13.6. The Part IV roadmap (9891–9904) omits §13.3, §13.6 and
§13.7 and says §13 "fixes only how a failure is reported". Options: (a)
recast the opening as one context sentence and one roadmap sentence naming
§13.1–§13.8, keeping the FlightCore sentence; carry the Part IV roadmap to
the front matter's rewrite as a README item, as chapter 12 did for Part III
(B86); (b) (a) plus a ruled edit to the Part IV roadmap now; (c) fix only
"this section". Recommendation: (a), ruled jointly with the sibling, whose
sections the roadmap names.

**q2. Device read bindings past a generic seam (F1), serious.** §13.3's
table, D-130's and D-242's Positions, §11.2 and §8.6 say a binding takes the
instance walk; since D-406's code a binding's path selector walks the strict
service walk and is refused past a generic seam. Options: (a) leave §13.3's
inspection row and 10221–10223 as written, the rewriter flags them, and the
orchestrator escalates with the evidence and a recommendation; (b) rule the
spec to the code now: the inspection row keeps snapshot and log inspection,
device read bindings move to the service row (strict at the authoring or
mount level), §11.2's "reach any cell" and §8.6's sentence become loose
fixes, D-130 and D-242 are annotated in track 2; (c) rule that the code
returns to the instance walk for a binding's reads, an implementation
increment. Recommendation: (a). D-130's Rejected list names the shipped
binding that the strict rule breaks, so which behavior the framework wants
is the owner's call; the recommendation to put to the owner is (b) if the
XPlane binding reads only faces, (c) otherwise. In every option the table
drops "GUI panels" (D-310). Rule jointly with the sibling's H13 (§13.5
10652–10664).

**q3. Subheadings and labels.** §13.2 holds two topics; §13.4 holds eight,
marked by seven bold labels and two italic ones. Options: (a) `####` labels
as in part C, two in §13.2 and eight in §13.4; §13.1 and §13.3 none, each
with a parts sentence; the runtime index's bold labels and the table's bold
cells become plain; (b) no `####`, each label becoming a plain topic
sentence; (c) `####` in §13.4 only. Recommendation: (a). §13.4 at 1,741
words is a reference section readers enter by topic (the recipe, boundary
zero, the nonfinite check), and §13.2's two halves are cited separately
(the warning half by §9.2, §11.8 and the glossary).

**q4. Overlap homes and the doubles (M4, M7, M9; H1, H6, H8, H14, H16,
H19).** Options: (a) one home each, as part B says: §13.4 for `StepError{C}`;
§12.4 for masking, the unmask points and the forced throw, §13.4 keeping the
catch-site clause; §9.2 for the build's warnings and `warnings(x)`; §11.6 and
§12.4 for the crash disposition; §13.5 for `UnboundedRun`; §6.1 for the
one-level rule; each other text a pointer with its citation; (b) leave every
duplicate. Recommendation: (a), ruled with the sibling for H8–H13.

**q5. The runtime warning index (M8, F11).** Options: (a) keep it as the
section's one-place index, one line per kind, each kind named and pointing
to its owning section, the crash line corrected (F10), `UnboundedRun`
reduced to its name and pointer (H8); (b) drop it to one sentence pointing
to Appendix C's rate-limited rows, which index the same kinds; (c) keep it
as is, adding the six names. Recommendation: (a). "The committed runtime
warnings, in one place" is the section's stated promise, inbound rows rely
on it (part D, M8), and Appendix C is the contract, not the reader's index.

**q6. Bold homes.** The half is the home section of these rulings, none bold
now as a headline clause with its citation: D-057 (the two populations; no
cascade suppression), D-229 (the dependency rule), D-058 (a closed set of
plain values), D-214 (severity is the kind's; raised and policy are the
occurrence's), D-222 (the parameter spells the policy), D-248 (every
user-authored method framed), D-341 bullet 3 (the `FieldError`
recognition, stated plain in §5.2 1116–1119), D-250 (the artifact
criterion), D-061 (the primitive forms), D-130 (client scoping), D-059 (one
catch site; the cursor), D-317 bullet 8 (the model's `frame!` and `init!`
host the catch), D-221 (the species rule), D-225 (the cause's type as the
parameter), D-128 (the frame-entry index as the pointer), D-223 (boundary
zero under the service's disposition), D-274 bullet 7 (reproduction by
`init!`), D-268 bullet 5 (the disposition by the roster), D-157 (the first
act; `ẋ` excluded), D-022 (the domains never mix, if cited here). Doubles to
make plain with their citations: row 59 (D-250 bullet 1, bold at §9.2 4574);
D-207 (§6.1 1541), D-394 and D-398 (§12.4), D-084 (§6.1 1626), D-136
(§11.8), D-105 (§11.6). Options: (a) bold each listed home ruling once at
its headline clause, under the one-bold test; make the doubles plain; (b)
the same, but leave D-022 and D-274 plain as consequences cited elsewhere.
Recommendation: (a).

**q7. The clear factual corrections.** F2 (`resolve_terminal`'s clients),
F3 (`resolve` is one level; two walks), F4 (the render), F5 (where user
code runs), F6 (the sketch's `warnings`), F7 ("batch"), F9 (the pacer's
record), F10 (`should_abort`), F12 (`StepError`'s time), F13 (the cursor's
index), F14 (the phases), F15 (environment closures), F16 (one `try` per
frame), F17 (what resets the stores), F18 (control plane and GUI), F19 (the
pause block), F20 (the model's `isfinite` pass), F21–F22 (tier, kind), F24
(self-citation), F26 (D-022), F28 (`InternalInvariant`), F29 (duplicate
links), F30 (the bare throw's outcome), F31–F34. Options: (a) rule them all
at checkpoint 1 with part E's evidence and proposed wording, grepping the
chapter for each phrase first ("GUI", "boundary time", "loop-level",
"environment", "frame" and "until the next `init!`" may recur in half 2);
(b) leave them for rulings. Recommendation: (a). F1 is q2, F8 is q10, F23
is q8, F25 is q1, F11 is q5, F27 is q11.

**q8. *Frame* in five senses (F23).** Options: (a) keep *frame* for the loop
iteration only; write "the framing diagnostic" (§13.2), "the `Model`'s
`frame!`", "the cursor frame" glossed at first use as "the record of the
cursor a `StepError` carries", "stack frames" and "exception handlers";
(b) keep "the cursor's frame" as a term, since the code names it
`CursorFrame` and Appendix C uses "cursor frame", and fix only the other
three senses. Recommendation: (b) with a gloss at first use per section;
the code's name argues for the term, the loop sense for the rest.

**q9. The units.** Two units as in part C: A 2,287 (heading to §13.2), B
2,557 (§13.3 and §13.4). The alternative is A′ 3,103 (to §13.3) and B′
1,741 (§13.4). Recommendation: A and B. Each move stays in one unit, and A's
shortfall below the floor is small.

**q10. The warnings-as-errors switch (F8).** Options: (a) rule the spec to
D-250's Rejected list: "A warnings-as-errors switch is rejected: a warning
is a fact about the model, not a defect (D-250)", D-058's contrary hint
annotated in track 2; (b) keep "could be added, but is not built" and
annotate D-250's Rejected bullet as misdescribing §13.2; (c) mark it
*recorded, not built* (`#g-recorded-not-built`). Recommendation: (a). D-250
is the later, ratified entry and weighed the switch; no code or test
depends on either reading.

**q11. Reader-cold names.** FlightCore's `compact_backtrace` (10082, named
in the opening as "the compact-backtrace discipline"), `InputMappingError`
(10150), `SimulationTermination` (9920), "ITP/Brent" (10276), "the
no-shared-mutable-model decision" (10440). Options: (a) an introducing
clause each that claims nothing beyond its source: "FlightCore's
`compact_backtrace`" at its §13.2 use, "FlightCore's `InputMappingError`",
"ITP or Brent root-finding (§10.4)", D-022 named; (b) cut the FlightCore
precedents to the log. Recommendation: (a); the compact-backtrace lesson is
the reason the strings rule exists, and the opening already names
FlightCore.

## H. Descriptive passages

One row per passage that describes a rule's mechanism rather than stating
the rule. The source file is the one `implementation.md`'s map and a grep
put it in; where a passage describes something stale, the row says so. These
rows are the normative kernel's migration list; part C proposes no move on
their account.

| id | section | lines | summary | realized in |
|---|---|---|---|---|
| P1 | §13.1 | 9928–9937 | the collecting checks listed, each a pass over a list returning its full violation list | `src/assembly.jl` (the walk, `flatten_tree!`, the obligation check), `src/build.jl` (step passes, `throw(DiagnosticError(diags))` at 115, 409, 588, 594) |
| P2 | §13.1 | 9958–9973 | how each pass runs past a failure: the walk's two results, the wire recorded with no producer, tier and event checks merging, the structural throw, the probe chain's fail-fast | `src/assembly.jl` (`resolve_terminal` recording into `diags`, `_one_level`), `src/build.jl` (`build`, 572–600) |
| P3 | §13.1 | 9976–9980 | the typo'd-wire pair and its rendering | `src/assembly.jl` (`UnknownPort` with candidates), `src/diagnostics.jl` (`_groups`, `showerror`); the adjacency claim is stale (F4) |
| P4 | §13.2 | 9997–10005 | severity read as `severity(d)`, never stored; raised and policy as occurrence facts | `src/diagnostics.jl` (`severity` default and per-kind methods, 51, 665, 1378, 1568–1579) |
| P5 | §13.2 | 10007–10017 | the barrier's single throw, the fail-fast carrier, `showerror` grouped by kind and sorted by path | `src/diagnostics.jl` (`DiagnosticError`, `diagnostic`, `diagnostics`, `kinds`, `_groups`, `showerror`, 77–148) |
| P6 | §13.2 | 10019–10032 | the `Diagnostic` and `DiagnosticError` sketch | `src/diagnostics.jl` (`Diagnostic` 24, `DiagnosticError` 89); the sketch lacks `warnings` (F6) |
| P7 | §13.2 | 10034–10050 | the framing accessor: what the frame carries, the framed set, the three pass-through exceptions, the runtime handoff | `src/declare.jl` (`_passes_frame` 430, `invoke_declaration` 444, `invoke_probed` 459, `UserCodeFraming` construction); `src/diagnostics.jl` (`UserCodeFraming` 1140) |
| P8 | §13.2 | 10052–10072 | the `FieldError` match at the probe by type and at the catch site by names, the three classes, the example message | `src/declare.jl` (the probe's `BundleFieldError`), `src/model.jl` (`_species(::Model, ::FieldError)`, 534–566) |
| P9 | §13.2 | 10097–10107 | build warnings carried on the artifact, rendered with a throwing step's collection, logged once at return | `src/diagnostics.jl` (`BUILD_WARNINGS`, `_warn!`, 163–180), `src/build.jl` (615), `src/deployment.jl` (379), `src/model.jl` (`warnings`, 474) |
| P10 | §13.2 | 10109–10121 | the runtime stream in the per-writer cells: ring, suppressed counts, frame-top take, the heartbeat, the status | `src/dataplane.jl` (`DiagCell`, `report_cell!`, `_take!`, `_beat!`, `_fold!`, 130–200; `WriterStatus`, `FrameworkStatus`, 223–278); the pacer clause is stale (F9) |
| P11 | §13.2 | 10123–10128 | the service's warnings on its report; `EmptyGreedyClaim` into the roster entry's cell | `src/trim.jl` (`TrimReport`, the three `TrimCommit…` logs, 620–644), `src/sim.jl` (`EmptyGreedyClaim`, 1939) |
| P12 | §13.2 | 10131–10168 | the runtime warning index: where each kind is raised | `src/frame.jl` (`ChatteringBudget`), `src/model.jl` (`FiringBudget`), `src/control.jl` (`DebtReanchor`), `src/dataplane.jl` (`OutOfClaimEntry`, `ClaimedFaceEntry`, `EntryTypeMismatch`), `src/devices.jl` (`MalformedDatum`, `DeviceCrash` in `_wrap`, 403–426), `src/sim.jl` (`ReplayDiscardedStaging`, `ThreadBudget`, `DeviceJoinTimeout`, `UnboundedRun`) |
| P13 | §13.3 | 10175–10185 | the three primitive forms | `src/assembly.jl` (`resolve` 354, `resolve_terminal` 375, `input_faces` 400, `output_faces` 413) |
| P14 | §13.3 | 10187–10198 | the walk's two duties: the one-level refusal, the declared-type walk refusing past a generic holding | `src/assembly.jl` (`_one_level` 312–335 with `:reaches_past`; `resolve_authored` 1494–1534 with `:past_generic`, `_held_concretely` 1476) |
| P15 | §13.3 | 10206–10226 | the client table and each client's walk | `src/assembly.jl` (wiring), `src/conditions.jl` (199, the service walk for `at` prefixes), `src/readers.jl` (`_mount` 482–493, `_rebase` 499–513); the inspection row is stale for bindings (F1) |
| P16 | §13.3 | 10248–10252 | `resolve_terminal`'s five clients, one splitter | none: stale. The code's terminal split serves wiring alone (F2) |
| P17 | §13.4 | 10256–10277 | the one `try`, the cursor and its three facts, one store per dispatch, the surfaces it covers | `src/frame.jl` (`frame!` 34–57), `src/executor.jl` (`ExecutionCursor` 17–24, `_phase!` 27, the dispatch stores 153–367), `src/model.jl` (the boundary-zero `try`, 188–194); "environment closures" names nothing (F15) |
| P18 | §13.4 | 10279–10285 | the cursor sketch | `src/executor.jl` (`ExecutionCursor`) |
| P19 | §13.4 | 10287–10298 | `StepError`'s five fields, the pointer, the host, the rendering | `src/diagnostics.jl` (`CursorFrame` 196–207, `StepError` 218–226, `_phase_text`, `showerror` 252–275), `src/model.jl` (`_wrap_step` 513–522) |
| P20 | §13.4 | 10300–10321 | the species unwrap, the only constructor, the parameter, the bare-value refusal | `src/model.jl` (`_wrap_step`'s `InternalInvariant` arm, `_species` 528–531) |
| P21 | §13.4 | 10323–10333 | the `StepError` sketch | `src/diagnostics.jl` (`StepError`) |
| P22 | §13.4 | 10335–10348 | reproduction: recorded at the drain, replayed to the pointer, re-stepped | `src/trace.jl` (`_record!` 101–112), `src/sim.jl` (`replay!` 920–1000, `to_boundary` 948–988; `step!` 1697), `src/diagnostics.jl` (the rendered recipe, 264–270) |
| P23 | §13.4 | 10350–10384 | the boundary-zero catch: status back to `:built`, raw interrupt, pointer 0, no trace or record, the recipe by host | `src/model.jl` (`init!(model, plan)` 178–198), `src/sim.jl` (`init!` 591 and its run handling), `src/diagnostics.jl` (`showerror`'s host branch) |
| P24 | §13.4 | 10386–10396 | the interrupt carve-out and the defensive arm | `src/frame.jl` (`err isa InterruptException && rethrow()`, 52), `src/model.jl` (192), `src/sim.jl` (the interrupt arms, 1237–1262, 1436–1462) |
| P25 | §13.4 | 10398–10408 | the disposition by the roster: rethrow or log and return | `src/sim.jl` (`run!`'s catch, 1271–1272, "§13.4's disposition, by the roster"; `replay!`, `step!`) |
| P26 | §13.4 | 10410–10432 | the `isfinite` pass after integrate, its placement and `ẋ`'s exclusion | `src/model.jl` (`integrate!` 421–425, `_check_finite!` 435–441, `_nonfinite` 446–463), `src/diagnostics.jl` (`NonfiniteState` 284–296) |
| P27 | §13.4 | 10434–10441 | device-side failure classes: the crash path and the tolerated datum | `src/devices.jl` (`_wrap` 403–426), the author's loop body (`report!`, `src/roster.jl` / `src/devices.jl`) |

27 rows. Rule statements the kernel would keep from these passages are in
part A; every row above describes how a ruling is carried out. P16 is the
one stale passage with no realization; P3, P10 and P15 contain stale clauses
inside otherwise realized descriptions.
