# Chapter 13: final-verifier fixes, units A and B (step 6b)

The seven findings of `final_verify_1.md`, applied as written. Each entry
gives the finding, the unit's `new.md`, and the old and new text verbatim,
the new text after the rewrap to 80 rendered columns (link markup, `*` and
backticks not counted; no link split across lines). The hunks are disjoint,
so they replay in any order. The matching `claims.md` blocks name the
finding in their `note`, or in a comment beside an `added:` block.

## Finding 1, unit B

"run it" becomes "run the walk", so the pronoun cannot read as the rule. Paragraph rewrapped.

Old:

````text
alongside instances. Every service and the read resolver run it over an authored
path. A segment that traverses *past* a generically-held field (one whose declared
type is non-concrete) is a diagnostic, even though the concrete instance in hand
would resolve it. Resolving *to* a generic child is legal, as access at the level
of a [port](#g-port) (one declared input or output). An unknown segment errors with the
sibling field list in hand. Paths are validated before anything runs on them,
and renames break loudly ([D-061][d-061]).
````

New:

````text
alongside instances. Every service and the read resolver run the walk over an
authored path. A segment that traverses *past* a generically-held field (one whose
declared type is non-concrete) is a diagnostic, even though the concrete
instance in hand would resolve it. Resolving *to* a generic child is legal, as
access at the level of a [port](#g-port) (one declared input or output). An unknown segment
errors with the sibling field list in hand. Paths are validated before anything
runs on them, and renames break loudly ([D-061][d-061]).
````

## Finding 2, unit B

The `#g-face` link and its gloss move to §13.3's first prose use, in the `input_faces` bullet; the `resolve_terminal` bullet's "face names" goes plain. Both bullets rewrapped.

Old (1 of 2):

````text
  they return the face names of `input_wires(c)` / `output_wires(c)`. Declaration
  order is preserved, which gives deterministic printouts and stable
  diagnostics.
````

New (1 of 2):

````text
  they return the [face](#g-face) names (the names ports wear on their component's
  boundary) of `input_wires(c)` / `output_wires(c)`. Declaration order is preserved,
  which gives deterministic printouts and stable diagnostics.
````

Old (2 of 2):

````text
  unambiguous because [face](#g-face) names (the names ports wear on their
  component's boundary) may contain dots but never slashes ([§8.6][s8-6]).
````

New (2 of 2):

````text
  unambiguous because face names may contain dots but never slashes ([§8.6][s8-6]).
````

## Finding 3, unit B

The `#g-trace` link moves to §13.4's first use, at the replay pointer, with its gloss as a sentence of its own, since the sentence before is replay's definition; Reproduction's "the trace" goes plain. Both paragraphs rewrapped. Unit A's lines 257–259 (the same pattern, one sentence apart) are left as they are: the finding's fix names unit B only.

Old (1 of 2):

````text
pointer** ([D-128][d-128]). Replay is the ordinary loop re-driven from a recorded trace.
The pointer names the frame-top boundary at which the failing frame began. That
frame top is a grid boundary or boundary zero, and it is always a legal replay
halt ([§12.7][s12-7]). The host names the catch that took the throw. It is `:loop` for a
throw inside a frame, and `:boundary_zero` for a throw inside the boundary zero
that `init!` runs. A `StepError` renders under the doctrine of [§13.2][s13-2]. The cursor
frame and the reproduction come first, the cause second, and names are strings.
````

New (1 of 2):

````text
pointer** ([D-128][d-128]). Replay is the ordinary loop re-driven from a recorded [trace](#g-trace).
The trace is the primary record of a session. The pointer names the frame-top
boundary at which the failing frame began. That frame top is a grid boundary or
boundary zero, and it is always a legal replay halt ([§12.7][s12-7]). The host names the
catch that took the throw. It is `:loop` for a throw inside a frame, and
`:boundary_zero` for a throw inside the boundary zero that `init!` runs. A `StepError`
renders under the doctrine of [§13.2][s13-2]. The cursor frame and the reproduction come
first, the cause second, and names are strings.
````

Old (2 of 2):

````text
Reproducibility holds by construction. Staged inputs are drained and recorded
to the [trace](#g-trace) (the primary record of a session) at the frame top,
*before* the boundary executes. So the failing boundary's inputs are already
in the trace when it fails. The error names the frame-entry boundary `k` to
replay to. `replay!(sim2, trc; to_boundary = k)` halts exactly at that frame
top ([D-128][d-128]). It halts in `:replay`, the
[input mode](#g-input-mode) that keeps the recording attached, so the failing
frame's record is still ahead of the simulation ([§12.7][s12-7],
[D-218][d-218]). `step!` then applies that record and re-executes the failing
frame under instrumentation, [localized](#g-localized) boundaries included.
````

New (2 of 2):

````text
Reproducibility holds by construction. Staged inputs are drained and recorded to
the trace at the frame top, *before* the boundary executes. So the failing
boundary's inputs are already in the trace when it fails. The error names the
frame-entry boundary `k` to replay to. `replay!(sim2, trc; to_boundary = k)` halts
exactly at that frame top ([D-128][d-128]). It halts in `:replay`, the [input mode](#g-input-mode) that
keeps the recording attached, so the failing frame's record is still ahead of
the simulation ([§12.7][s12-7], [D-218][d-218]). `step!` then applies that record and re-executes
the failing frame under instrumentation, [localized](#g-localized) boundaries included.
````

## Finding 4, unit B

The taps gloss takes the spec's own wording (glossary `#g-taps`; frozen spec lines 11542 and 12475). A table row: not rewrapped.

Old:

````text
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the selector lists linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
````

New:

````text
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the three selector lists declaring what linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
````

## Finding 5, unit B

"leaves the catch unwrapped" becomes "propagates from the catch unwrapped". Paragraph rewrapped.

Old:

````text
and the constructor refuses it, so it leaves the catch unwrapped. The framework
does not handle that throw ([D-225][d-225]). The cursor frame and the pointer are then
lost, and the lifecycle does not move as it does when the catch builds a
`StepError`.
````

New:

````text
and the constructor refuses it, so it propagates from the catch unwrapped. The
framework does not handle that throw ([D-225][d-225]). The cursor frame and the pointer
are then lost, and the lifecycle does not move as it does when the catch builds
a `StepError`.
````

## Finding 6, unit A

The rewrap keeps `[Appendix C][sC]` on one line. Paragraph rewrapped; no word changes.

Old:

````text
**A diagnostic is a plain value from a small closed set of [kinds](#g-kind)** ([D-058][d-058]). [Appendix
C][sC] enumerates that set normatively. For each kind it records the kind name, the
[payload](#g-payload) fields (the structured data a diagnostic carries beside its kind), the
owning section, the severity, where the kind is raised and under which policy
([D-214][d-214]). That index is the reference the [§8.4][s8-4] walkthroughs, run as acceptance
tests, and the error-message work are written against. Tests match on kind plus
payload fields, never on message text, so messages are pure presentation
([D-058][d-058]).
````

New:

````text
**A diagnostic is a plain value from a small closed set of [kinds](#g-kind)** ([D-058][d-058]).
[Appendix C][sC] enumerates that set normatively. For each kind it records the kind
name, the [payload](#g-payload) fields (the structured data a diagnostic carries beside its
kind), the owning section, the severity, where the kind is raised and under
which policy ([D-214][d-214]). That index is the reference the [§8.4][s8-4] walkthroughs, run as
acceptance tests, and the error-message work are written against. Tests match on
kind plus payload fields, never on message text, so messages are pure
presentation ([D-058][d-058]).
````

## Finding 7, unit A

"The runtime carrier" goes from the second introduction of `StepError{C}`; line 111 already gives it. Paragraph rewrapped.

Old:

````text
`@test_throws DiagnosticError{Kind}`. The runtime carrier `StepError{C}` takes a
parameter of its own, the type of its `cause` ([§13.4][s13-4], [D-225][d-225]). `showerror` renders a
collection compiler-style, grouped by kind and sorted by path. It renders a
single diagnostic as its own line.
````

New:

````text
`@test_throws DiagnosticError{Kind}`. `StepError{C}` takes a parameter of its own,
the type of its `cause` ([§13.4][s13-4], [D-225][d-225]). `showerror` renders a collection
compiler-style, grouped by kind and sorted by path. It renders a single
diagnostic as its own line.
````
