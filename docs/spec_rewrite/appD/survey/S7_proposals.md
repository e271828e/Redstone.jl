<a id="g-collect-the-checks-fail-the-evaluations-fast"></a>**collect the checks, fail the evaluations fast** — the reporting policy.
Declarative passes over collected structure return their full violation
list, while the first user-code exception aborts the phase. The build's
steps are barriers, and the policy field of [Appendix C][sC] spells the
collecting case `collected` ([§13.1][s13-1]).

<a id="g-error-locality"></a>**error locality** — the property the declaration layer buys. A mistake
fails at the site of the mistake, not later and inside correct code. The
five walkthroughs ([§8.4][s8-4]) are its grounding cases, and they run as
acceptance tests ([§13.2][s13-2]).

<a id="g-species"></a>**species** — a `StepError` whose `cause` is a diagnostic, `StepError{Kind}`
by type. It is what the catch site makes of a single-diagnostic
`DiagnosticError` thrown inside the guarded sequence, under the species rule
([§13.4][s13-4], [D-225][d-225]).

<a id="g-stop-request"></a>**stop request / termination is a state** — graceful termination is model
state, never an exception. A model publishes a stop request as an output port
of the framework enum `StopFlag`, anywhere in the tree. One reading
`STOP_REQUESTED` ends the run unless the advance ignores it. `StopRequest` is
the library spelling ([§13.5][s13-5], [D-316][d-316]).

<a id="g-artifact"></a>**artifact** — an immutable pure function of its inputs, such as `Structure`,
`Outputs`, `Events`, an activation, the `Build`, the `Deployment`, a trim
report or the trace header. A warning raised producing one lives on it
([§13.2][s13-2], [D-250][d-250]). It holds declared facts, and a consumer
compiles what it needs from them at one home ([§9.2][s9-2], [D-261][d-261]).

<a id="g-row"></a>**decision entry / `D-nnn`** — a numbered entry of `decisions.md`, cited
throughout as a linked `D-nnn` reference. Each entry records one settled
decision, with the alternatives considered and the reasons they were
rejected. Entry numbers are stable and never reused ([§1][s1]).

<a id="g-guarded-addition"></a>**guarded addition** — a capability the design admits but does not build.
The design weighs each one against the criteria of [§1][s1]. Examples are
field-addressed staging ([§4.3][s4-3]) and mid-run reader attach
([§11.3][s11-3]).

<a id="g-normative"></a>**normative / index, not a second home** — the spec is the normative
statement of the design ([§1][s1]). Appendices A and B are indices. An
item there is normative only where its owning section settles it
([Appendix A][sA]). [Appendix C][sC] makes its kind set normative. The
glossary and the `companions/` explainers are not normative, and the owning
text wins ([§1][s1]).
