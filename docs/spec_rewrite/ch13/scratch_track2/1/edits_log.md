### 1. B42, D-012 — `docs/design/decisions.md`

Old:

```
**Rationale.** Recorded only through the rejections below.

**Rejected.**
```

New:

```
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-19): D-259 retired the strata, so the Stratum-B topological
stall is the topological-sort stall in the nominal evaluation (§13.8).

**Rejected.**
```

### 2. B44, D-057 — `docs/design/decisions.md`

Old:

```
**Rationale.** Recorded only through the rejections below.

**Rejected.**
```

New:

```
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-19): §13.1 no longer says the two errors of a typo'd
wire render adjacently by path. The did-you-mean names the input the other
error says is unfed, so the pairing explains itself.

**Rejected.**
```

### 3. B45 Spec, D-058 — `docs/design/decisions.md`

Old:

```
**Spec.** [Appendix C][sC]
```

New:

```
**Spec.** §13.2, [Appendix C][sC]
```

### 4. B45, R11, D-058 — `docs/design/decisions.md`

Old:

```
**Rationale.** Recorded only through the rejections below.

**Rejected.**
```

New:

```
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-19): amended by D-222 and D-250. The one carrier is
`DiagnosticError{P}`, which replaces `BuildError` (D-222). Warnings ride no
shared stream: a warning raised while producing an artifact lives on that
artifact, and one raised while mutating state lives in that state's status
(D-250). The fourth rejection counts blocking a warnings-as-errors switch
against a separate channel; D-250 rejects that switch, and §13.2 states the
rejection.

**Rejected.**
```

### 5. B46, D-059 — `docs/design/decisions.md`

Old:

```
[§13.4][s13-4], [§14][s14]
```

New:

```
[§13.4][s13-4], §13.6, [§14][s14]
```

### 6. B47, D-060 — `docs/design/decisions.md`

Old:

```
state, never an exception, stands.

**Rejected.**
```

New:

```
state, never an exception, stands.

Annotation (2026-10-19): the Tier-2 event of the detection clause is a
localized event, which a stop that must be localized declares as a
sign-form event (§13.5). The `stop_on` root faces are stop requests since
D-316, and the policy binds per advance, not at `Simulation` construction
(D-255).

**Rejected.**
```

### 7. B48 (D-061), D-061 — `docs/design/decisions.md`

Old:

```
face lists and the terminal split stand.

**Rejected.**
```

New:

```
face lists and the terminal split stand.

Annotation (2026-10-19): the public `resolve` resolves one level, an
immediate child, and the declared-type walk is the service walk (§13.3).
Since D-406 and D-407, device read bindings and log extraction by series
resolve on the service side; GUI panels are parked (D-310). The inspection
case is snapshot and log inspection (§13.3).

**Rejected.**
```

### 8. B49, D-062 — `docs/design/decisions.md`

Old:

```
parameter and tier transparency stand ([§13.7][s13-7]).

**Rejected.**
```

New:

```
parameter and tier transparency stand ([§13.7][s13-7]).

Annotation (2026-10-19): predicate selection is `select`, a selector of
`input_passthrough` and `output_passthrough` (D-251), not a `faces` method.
The face-route printer is `show(::Structure)` (D-257), not the `Build`
printer (§13.7).

**Rejected.**
```

### 9. B50 Spec, D-071 — `docs/design/decisions.md`

Old:

```
**Spec.** [§13.7][s13-7]
```

New:

```
**Spec.** §14.9
```

### 10. B50, D-071 — `docs/design/decisions.md`

Old:

```
**Rationale.** Recorded only through the rejections below.

**Rejected.**
```

New:

```
**Rationale.** Recorded only through the rejections below.

Annotation (2026-10-19): the helper is recorded in §14.9. §13.7's library
holds components only.

**Rejected.**
```

### 11. B52, D-114 — `docs/design/decisions.md`

Old:

```
predicate tests no longer mirrors the snapshot's index.

**Rejected.**
```

New:

```
predicate tests no longer mirrors the snapshot's index.

Annotation (2026-10-19): §13.4 indexes a failure by the frame-entry
boundary index (D-128, D-230). The counter-plus-recorded-`t` indexing this
entry presupposes is historical, and §13.4 no longer rests on it.

**Rejected.**
```

### 12. B53, D-120 — `docs/design/decisions.md`

Old:

```
producer; in a rig, a stub child).

**Rejected.**
```

New:

```
producer; in a rig, a stub child).

Annotation (2026-10-19): the remainder is exported via
`input_passthrough(rig, child; except)` (§13.7). The slot of the second
rejection's slot-typing rule is a root input since D-206.

**Rejected.**
```

### 13. B48 (D-130), D-130 — `docs/design/decisions.md`

Old:

```
stays enforcing where promises depend on
it.

**Rejected.**
```

New:

```
stays enforcing where promises depend on
it.

Annotation (2026-10-19): since D-406 and D-407, device read bindings and log
extraction by series resolve on the service side, and
`ReadBindingUnresolved` retires (D-406); GUI panels are parked (D-310). The
inspection case is snapshot and log inspection (§13.3).

**Rejected.**
```

### 14. B54, D-131 — `docs/design/decisions.md`

Old:

```
advisory.

**Rejected.**
```

New:

```
advisory.

Annotation (2026-10-19): §13.4 names only the terminal statuses and the
return to `built`; the five-state count is §12.6's.

**Rejected.**
```

### 15. B57, D-141 — `docs/design/decisions.md`

Old:

```
here and in the Rejected list are [§7.1][s7-1]'s.

**Rejected.**
```

New:

```
here and in the Rejected list are [§7.1][s7-1]'s.

Annotation (2026-10-19): the grow-by-migration-demand rule the Rationale
cites is retired: a listed block is built whenever wanted, with no
demonstrating model required (D-313). The Bool gates the third rejection
cites admit no `Not`; the negation is one character at the consumer
(D-311).

**Rejected.**
```

### 16. B58, D-142 — `docs/design/decisions.md`

Old:

```
scope stays unnarrowed by this
finding.

**Rejected.**
```

New:

```
scope stays unnarrowed by this
finding.

Annotation (2026-10-19): under D-316 a plausibility check meaning "stop
the run" publishes a `StopFlag` port, which `StopRequest` spells, and no
keyword names it.

**Rejected.**
```

### 17. B59, D-143 — `docs/design/decisions.md`

Old:

```
tier stand.

**Rejected.**
```

New:

```
tier stand.

Annotation (2026-10-19): the root slot of the second clarification is a
root input since D-206 (§11.3). The demonstrated-need charter the Rationale
cites is retired: a block joins the library by judgement against three
guidelines (D-313, §13.7).

**Rejected.**
```

### 18. B60, D-159 — `docs/design/decisions.md`

Old:

```
five-value count to six.

**Rejected.**
```

New:

```
five-value count to six.

Annotation (2026-10-19): superseded in part by D-250. §13.2's two-stream
partition is gone; a service warning lives on the artifact the call returns.

**Rejected.**
```

### 19. B40, D-184 — `docs/design/decisions.md`

Old:

```
[D-314][d-314].

**Rejected.**
```

New:

```
[D-314][d-314].

Annotation (2026-10-19): §13.7's starting inventory does not list `Group`.
`Group` belongs to §13.7's library as its one member admitted by persona.

**Rejected.**
```

### 20. B62 Spec, D-203 — `docs/design/decisions.md`

Old:

```
[§12.6][s12-6], [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]
```

New:

```
[§12.6][s12-6], §13.2, [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]
```

### 21. B62, D-203 — `docs/design/decisions.md`

Old:

```
home for the fact, stands.

**Rejected.**
```

New:

```
home for the fact, stands.

Annotation (2026-10-19): amended by D-233. The final boundary time is always
present, a value of the deployment's scalar and never `nothing`, so the
record has no absent-time arm.

**Rejected.**
```

### 22. B48 (D-242), D-242 — `docs/design/decisions.md`

Old:

```
what is at stake.

**Rejected.**
```

New:

```
what is at stake.

Annotation (2026-10-19): since D-406 and D-407, device read bindings and log
extraction by series resolve on the service side; GUI panels are parked
(D-310). The inspection case is snapshot and log inspection (§13.3).

**Rejected.**
```

### 23. B68, D-255 — `docs/design/decisions.md`

Old:

```
[§12.7][s12-7], [§13.5][s13-5], [Appendix C][sC]
```

New:

```
[§12.7][s12-7], §13.2, [§13.5][s13-5], [Appendix C][sC]
```

### 24. B78, D-005 — `docs/design/decisions.md`

Old:

```
**Spec.** [§5.5][s5-5]
```

New:

```
**Spec.** [§5.5][s5-5], §13.8
```

### 25. B78, D-019 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2][s2], [§3.2][s3-2], [§3.3][s3-3], [§5.2][s5-2], [§10.5][s10-5]
```

New:

```
**Spec.** [§2][s2], [§3.2][s3-2], [§3.3][s3-3], [§5.2][s5-2], [§10.5][s10-5], §13.5
```

### 26. B78, D-022 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2][s2], [§11.1][s11-1], [§12.1][s12-1], [§12.3][s12-3]
```

New:

```
**Spec.** [§2][s2], [§11.1][s11-1], [§12.1][s12-1], [§12.3][s12-3], §13.4
```

### 27. B78, D-084 — `docs/design/decisions.md`

Old:

```
**Spec.** [§6.1][s6-1], [§6.2][s6-2], [§11.2][s11-2], [§11.7][s11-7], [§13.2][s13-2], [Appendix C][sC]
```

New:

```
**Spec.** [§6.1][s6-1], [§6.2][s6-2], [§11.2][s11-2], [§11.7][s11-7], [§13.2][s13-2], §13.5, [Appendix C][sC]
```

### 28. B78, D-147 — `docs/design/decisions.md`

Old:

```
**Spec.** [§5.3][s5-3], [§10.3][s10-3], [§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6], [§9.7][s9-7], [§14.5][s14-5], [Appendix D][sD]
```

New:

```
**Spec.** [§5.3][s5-3], [§10.3][s10-3], [§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6], [§9.7][s9-7], §13.5, [§14.5][s14-5], [Appendix D][sD]
```

### 29. B78, D-218 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4]
```

New:

```
**Spec.** [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], §13.5
```

### 30. B78, D-231 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2.5][s2-5], [§3.2][s3-2], [§7.3][s7-3], [§8.2][s8-2], [§9.1][s9-1], [Appendix C][sC], [Appendix D][sD]
```

New:

```
**Spec.** [§2.5][s2-5], [§3.2][s3-2], [§7.3][s7-3], [§8.2][s8-2], [§9.1][s9-1], §13.7, [Appendix C][sC], [Appendix D][sD]
```

### 31. B78, D-235 — `docs/design/decisions.md`

Old:

```
**Spec.** [§7.1][s7-1], [§8.2][s8-2], [§9.5][s9-5], [Appendix C][sC]
```

New:

```
**Spec.** [§7.1][s7-1], [§8.2][s8-2], [§9.5][s9-5], §13.4, [Appendix C][sC]
```

### 32. B78, D-237 — `docs/design/decisions.md`

Old:

```
**Spec.** [§4.3][s4-3], [§4.4][s4-4], [§8.2][s8-2], [§9.5][s9-5], [§9.7][s9-7], [Appendix C][sC]
```

New:

```
**Spec.** [§4.3][s4-3], [§4.4][s4-4], [§8.2][s8-2], [§9.5][s9-5], [§9.7][s9-7], §13.7, [Appendix C][sC]
```

### 33. B78, D-251 — `docs/design/decisions.md`

Old:

```
**Spec.** [§8.8][s8-8], [Appendix C][sC]
```

New:

```
**Spec.** [§8.8][s8-8], §13.2, §13.7, [Appendix C][sC]
```

### 34. B78, D-254 — `docs/design/decisions.md`

Old:

```
**Spec.** [§8.7][s8-7], [§9.2][s9-2], [§10.5][s10-5], [§11.5][s11-5], [§12.7][s12-7], [Appendix C][sC]
```

New:

```
**Spec.** [§8.7][s8-7], [§9.2][s9-2], [§10.5][s10-5], [§11.5][s11-5], [§12.7][s12-7], §13.2, [Appendix C][sC]
```

### 35. B78, D-261 — `docs/design/decisions.md`

Old:

```
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§11.2][s11-2], [§11.3][s11-3], [§11.5][s11-5], [§12.6][s12-6], [§13.5][s13-5], [Appendix B][sB]
```

New:

```
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§11.2][s11-2], [§11.3][s11-3], [§11.5][s11-5], [§12.6][s12-6], §13.4, [§13.5][s13-5], [Appendix B][sB]
```

### 36. B78, D-274 — `docs/design/decisions.md`

Old:

```
**Spec.** [§10.2][s10-2], [§10.6][s10-6], [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§14][s14], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

New:

```
**Spec.** [§10.2][s10-2], [§10.6][s10-6], [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], §13.4, [§14][s14], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

### 37. B78, D-294 — `docs/design/decisions.md`

Old:

```
**Spec.** [§10.7][s10-7], [§12.4][s12-4]
```

New:

```
**Spec.** [§10.7][s10-7], [§12.4][s12-4], §13.4
```

### 38. B78, D-322 — `docs/design/decisions.md`

Old:

```
**Spec.** [§6.1][s6-1], [§9.1][s9-1]
```

New:

```
**Spec.** [§6.1][s6-1], [§9.1][s9-1], §13.7
```

### 39. B78, D-364 — `docs/design/decisions.md`

Old:

```
**Spec.** [§4.4][s4-4], [§8.2][s8-2], [§14.9][s14-9]
```

New:

```
**Spec.** [§4.4][s4-4], [§8.2][s8-2], §13.7, [§14.9][s14-9]
```

### 40. B78, D-387 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.6][s12-6]
```

New:

```
**Spec.** [§12.6][s12-6], §13.6
```

### 41. B78, D-389 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.4][s12-4], [§12.6][s12-6]
```

New:

```
**Spec.** [§12.4][s12-4], [§12.6][s12-6], §13.4
```

### 42. B78, D-398 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.1][s12-1], [§12.4][s12-4]
```

New:

```
**Spec.** [§12.1][s12-1], [§12.4][s12-4], §13.4
```

### 43. B78, D-401 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.2][s12-2]
```

New:

```
**Spec.** [§12.2][s12-2], §13.2
```

### 44. B78, D-406 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.2][s11-2], [§11.6][s11-6], [§14.4][s14-4], [§14.7][s14-7], [Appendix C][sC]
```

New:

```
**Spec.** [§11.2][s11-2], [§11.6][s11-6], §13.3, §13.5, [§14.4][s14-4], [§14.7][s14-7], [Appendix C][sC]
```

### 45. B78, D-407 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.2][s11-2], [Appendix B][sB]
```

New:

```
**Spec.** [§11.2][s11-2], §13.3, [Appendix B][sB]
```

