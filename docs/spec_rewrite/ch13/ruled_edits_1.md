# Chapter 13: ruled edits, units A and B (step 6)

Applied from `rulings_batch.md` items B6 (unit A) and B1, B4, B9, B10, B11 and
B87 (unit B). Each entry gives the item, the unit's `new.md`, and the old and
new text verbatim; the new text is after the rewrap to 80 rendered columns
(link markup, `*` and backticks not counted). The hunks are disjoint, so they
replay in any order. Each item's claims in `units/<U>/claims.md` carry
`tag: R` and `ruling: B<n>`; B4's sentence is an `added:` block with a
comment naming B4, since an added block takes no ruling field.

## 1. B6, unit A

§13.2's `DeviceCrash` index line names the kind and points; "A genuine bug takes the per-device crash path" and "reports `DeviceCrash`" go, so §13.4 alone keeps the path. Item rewrapped.

Old:

````text
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). A genuine bug takes the per-device
  crash path. The framework wrapper catches a device task's failure and reports
  `DeviceCrash`, and the run goes on without the device unless its attachment set
  [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!` keyword) ([§11.6][s11-6]).
````

New:

````text
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). The framework wrapper catches a
  device task's failure, and the run goes on without the device unless its
  attachment set [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!`
  keyword) ([§11.6][s11-6]).
````

## 2. B1, unit B

First half: the generic-holding sentence names the clients, and the service walk is defined where it is used, in the ruling's words. Paragraph rewrapped.

Old:

````text
the [generic-holding](#g-generic-holding) rule, which governs the deep paths the read side still
writes. It is enforced by the service walk, which follows *declared field types*
alongside instances. A segment that traverses *past* a generically-held field (one
whose declared type is non-concrete) is a diagnostic, even though the concrete
````

New:

````text
the [generic-holding](#g-generic-holding) rule, which governs the deep paths a service or a reader is
given. It is enforced by the service walk, the walk every service and the read
resolver run over an authored path, which follows *declared field types* alongside
instances. A segment that traverses *past* a generically-held field (one whose
declared type is non-concrete) is a diagnostic, even though the concrete
````

## 3. B1, unit B

Second half: each pointer names its client, with D-406 at the readers, in the ruling's words. Paragraph rewrapped.

Old:

````text
Inside the framework only wiring resolution calls `resolve_terminal`. The
services and the readers split their own paths through the service walk
([§14.3][s14-3], [§14.4][s14-4]).
````

New:

````text
Inside the framework only wiring resolution calls `resolve_terminal`. Condition
addressing ([§14.3][s14-3]) and the readers ([§14.4][s14-4], [D-406][d-406]) split their own paths through
the service walk.
````

## 4. B4, unit B

The pointer back to §13.5's stop scan, at the end of the inspection warrant. Paragraph rewrapped.

Old:

````text
defining question.
````

New:

````text
defining question. The stop scan, the one read a run acts on, is §13.5's
([§13.5][s13-5]).
````

## 5. B9, unit B

"Three kinds of client" becomes "Three clients". Paragraph rewrapped.

Old:

````text
**Which rule applies depends on who is resolving** ([D-130][d-130]).
[D-083][d-083] separates the reads a build's correctness rests on from the
reads that only observe it. The same line runs through resolution. Three kinds
of client share one resolution, and each gets the rule its promises require.
````

New:

````text
**Which rule applies depends on who is resolving** ([D-130][d-130]). [D-083][d-083] separates the
reads a build's correctness rests on from the reads that only observe it. The
same line runs through resolution. Three clients share one resolution, and each
gets the rule its promises require.
````

## 6. B10, unit B

D-310 leaves the inspection row (a table row: not rewrapped).

Old:

````text
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection ([D-310][d-310]) | the instance walk |
````

New:

````text
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection | the instance walk |
````

## 7. B11, unit B

The code comment takes R7's term.

Old:

````text
    cursor         # the cursor's frame at the catch
````

New:

````text
    cursor         # the cursor frame: the cursor's copy at the catch
````

## 8. B87, unit B

The `Outputs` gloss drops *class* for the glossary's wording. Paragraph rewrapped.

Old:

````text
evaluation's product, the port classes and the execution order) carries. The
second is which function is running, one of `y_state`, `y_direct`, `x_deriv`,
`s_update`, a [guard](#g-guard) (the declared function defining an event's predicate), a
handler, or `x_projection`. The third is the boundary phase, one of the frame-top
drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass through the execution
order), the θ = 0 validation, a localization trial, projection, event round *r*,
or the ticks. Maintaining the cursor costs one cheap store per dispatch on a
single-tasked executor, with no allocation and no exception handlers. It covers
every user-code surface uniformly, including the forgettable ones. Those are the
evaluations of the [RHS](#g-flow) (the continuous derivative function) at interior RK stage
points and the guard evaluations at the trial points of ITP or Brent
root-finding ([§10.4][s10-4]).
````

New:

````text
evaluation's product, the output port names each stage produces and the
execution order) carries. The second is which function is running, one of
`y_state`, `y_direct`, `x_deriv`, `s_update`, a [guard](#g-guard) (the declared function defining an
event's predicate), a handler, or `x_projection`. The third is the boundary phase,
one of the frame-top drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass
through the execution order), the θ = 0 validation, a localization trial,
projection, event round *r*, or the ticks. Maintaining the cursor costs one cheap
store per dispatch on a single-tasked executor, with no allocation and no
exception handlers. It covers every user-code surface uniformly, including the
forgettable ones. Those are the evaluations of the [RHS](#g-flow) (the continuous
derivative function) at interior RK stage points and the guard evaluations at
the trial points of ITP or Brent root-finding ([§10.4][s10-4]).
````

## Amendments

These two entries replay after entries 1 to 8.

## 9. B1 (amended), unit B

B1's amended wording, applied after entries 2 and 3: the service walk's definition becomes its own sentence, so "which" no longer reads as the path. Paragraph rewrapped.

Old:

````text
given. It is enforced by the service walk, the walk every service and the read
resolver run over an authored path, which follows *declared field types* alongside
instances. A segment that traverses *past* a generically-held field (one whose
declared type is non-concrete) is a diagnostic, even though the concrete
instance in hand would resolve it. Resolving *to* a generic child is legal, as
access at the level of a [port](#g-port) (one declared input or output). An unknown segment
errors with the sibling field list in hand. Paths are validated before anything
runs on them, and renames break loudly ([D-061][d-061]).
````

New:

````text
given. It is enforced by the service walk, which follows *declared field types*
alongside instances. Every service and the read resolver run it over an authored
path. A segment that traverses *past* a generically-held field (one whose declared
type is non-concrete) is a diagnostic, even though the concrete instance in hand
would resolve it. Resolving *to* a generic child is legal, as access at the level
of a [port](#g-port) (one declared input or output). An unknown segment errors with the
sibling field list in hand. Paths are validated before anything runs on them,
and renames break loudly ([D-061][d-061]).
````

## 10. B4 (amended), unit B

B4's amended wording, applied after entry 4: "is §13.5's (§13.5)" becomes "belongs to [§13.5][s13-5]". Paragraph rewrapped.

Old:

````text
defining question. The stop scan, the one read a run acts on, is §13.5's
([§13.5][s13-5]).
````

New:

````text
defining question. The stop scan, the one read a run acts on, belongs to [§13.5][s13-5].
````
