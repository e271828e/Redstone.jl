# Chapter 13, track 2: agent 1's log

Agent 1 of `track2_prompts.md`. Two commits on `master`:

- `ebaa273`: the spec, glossary and companion edits (edits 1 to 4).
- `e1a7004`: the log (edits 5 to 49).

Every edit was matched by its old text, asserted to occur exactly once (log
edits: once inside the named entry) before any file was written. The script
is `scratch_track2/1/apply.py` (`python3 -I apply.py <root> spec|log <out>`).
New text was written with bare citations; `linkify.jl` then linked them, so
the committed text shows `[§13.5][s13-5]` where an edit below shows `§13.5`.

## Battery

Run after each phase, before each commit, each check as its own command:
`linkify.jl`, `check_refs.jl` OK, `check_rows.jl` OK (no coverage drop, no
rebaseline), `check_glossary.jl --strict` OK, `check_bold.jl` OK (chapter
13: 57 bold spans, 521 bold words, unchanged), `linkify.jl` again a no-op
(diff hash unchanged).

## Checked, no edit

- B43: D-030's Spec field already lists §13.6.
- B53: D-120's Spec field already lists §13.7. The annotation was applied.
- B68: D-255 bullet 5 is annotated already (the 2026-10-08 annotation); only
  §13.2 was added to the Spec field.
- B31: Appendix C's `StepError` row holds the ruled wording ("Cursor frame
  (the component by its component-list index, the function, and the
  boundary phase: …), the clock at the failure, …").
- B41: the glossary's feedthrough-tracer entry reads "global value-blind, or
  sampled primal-carrying"; `implementation.md` 933 reads "global on `true`
  and sampled on `false`".
- R11: covered by the D-058 annotation (edit 8), with B45's other two
  passages.
- F54: the `ArgumentInvalid` row did not cite §13.5; edit 1 adds it.

## B78: the script and what it found

`scratch_track2/1/spec_fields.py` lists every `D-nnn` the landed chapter 13
(spec `## 13.` to `## 14.`) cites, per section, against the entry's Spec
field. Before: 79 entries cited, 29 (entry, section) pairs absent
(`spec_fields_before.txt`):

```
D-005 §13.8 at spec 11111; field: §5.5
D-019 §13.5 at spec 10567; field: §2, §3.2, §3.3, §5.2, §10.5
D-022 §13.4 at spec 10498; field: §2, §11.1, §12.1, §12.3
D-058 §13.2 at spec 10000,10007,10052; field: Appendix C
D-059 §13.6 at spec 10818; field: §12.6, §9.5, §13.4, §14
D-084 §13.5 at spec 10564; field: §6.1, §6.2, §11.2, §11.7, §13.2, Appendix C
D-147 §13.5 at spec 10570; field: §5.3, §10.3, §10.4, §10.5, §10.6, §9.7, §14.5, Appendix D
D-203 §13.2 at spec 10177; field: §11.8, §12.1, §12.4, §12.6, §13.5, §13.6, Appendix C
D-218 §13.5 at spec 10662; field: §11.5, §12.6, §12.7, §13.4
D-231 §13.7 at spec 10986; field: §2.5, §3.2, §7.3, §8.2, §9.1, Appendix C, Appendix D
D-235 §13.4 at spec 10340; field: §7.1, §8.2, §9.5, Appendix C
D-237 §13.7 at spec 11029; field: §4.3, §4.4, §8.2, §9.5, §9.7, Appendix C
D-251 §13.2 at spec 10117; field: §8.8, Appendix C
D-251 §13.7 at spec 10838; field: §8.8, Appendix C
D-254 §13.2 at spec 10118; field: §8.7, §9.2, §10.5, §11.5, §12.7, Appendix C
D-255 §13.2 at spec 10183; field: §11.5, §12.1, §12.4, §12.6, §12.7, §13.5, Appendix C
D-261 §13.4 at spec 10298; field: §9.1, §9.2, §11.2, §11.3, §11.5, §12.6, §13.5, Appendix B
D-274 §13.4 at spec 10440; field: §10.2, §10.6, §11.5, §12.6, §12.7, §14, §14.8, §14.10, Appendix B
D-294 §13.4 at spec 10384; field: §10.7, §12.4
D-310 §13.5 at spec 10511; field: §11.1, §11.3, §11.6, §11.7, §12.1, §12.2, §12.4, §12.6, Appendix B, Appendix C
D-322 §13.7 at spec 10845; field: §6.1, §9.1
D-364 §13.7 at spec 11031; field: §4.4, §8.2, §14.9
D-387 §13.6 at spec 10818; field: §12.6
D-389 §13.4 at spec 10401; field: §12.4, §12.6
D-398 §13.4 at spec 10386; field: §12.1, §12.4
D-401 §13.2 at spec 10170; field: §12.2
D-406 §13.3 at spec 10227,10241,10267; field: §11.2, §11.6, §14.4, §14.7, Appendix C
D-406 §13.5 at spec 10755; field: §11.2, §11.6, §14.4, §14.7, Appendix C
D-407 §13.3 at spec 10227; field: §11.2, Appendix B
```

D-058, D-059, D-203 and D-255 are B45, B46, B62 and B68 (edits 7, 9, 24
and 27). For the other 25 pairs the citing sentence was read against the entry's
Position. Added (edits 28 to 49 below, 22 entries): each sentence states what
the entry's Position rules.

- D-005 §13.8 (the build rejects an algebraic loop), D-019 §13.5 (assemblies
  virtual for execution, rate scopes on discrete children), D-022 §13.4 (no
  shared mutable state), D-084 §13.5 (no unconnected-output warning), D-147
  §13.5 (the boundary sweep walks the full list), D-218 §13.5 (`:replay`
  bounded by the recording), D-231 §13.7 (isbits stores), D-235 §13.4 (the
  write's `ConformanceFailure` reaches the catch site), D-237 §13.7 (no
  handle-typed root input), D-251 §13.2 (`EmptyFaceSelection` on the build)
  and §13.7 (`select`), D-254 §13.2 (`GridUtilization` on the deployment),
  D-261 §13.4 (the cursor's component index, the execution order's), D-274
  §13.4 (boundary-zero reproduction is `init!` under the same condition),
  D-294 §13.4 (the interrupt deferred to an unmask point), D-322 §13.7 (no
  auto-bubbling), D-364 §13.7 (a bulk-data handle through a constant source),
  D-387 §13.6 (reproduction by trace replay), D-389 §13.4 (`step!`
  deviceless), D-398 §13.4 (the forced throw's disposition), D-401 §13.2
  (thread-budget tightness), D-406 §13.3 (bindings in the service row) and
  §13.5 (attach resolves output-device reads strictly), D-407 §13.3 (log
  extraction by `series` in the service row).

Not added: D-310 §13.5. §13.5 cites D-310 at "a front end's stop button"
(F53's "citing D-310 once in the section") for the parked GUI. The sentence
states that the wall-clock channel is orthogonal, which D-310 does not rule.

Batch items the script did not confirm: D-218 §13.4 (already listed),
D-261 §13.7 (no longer cited there), D-224 and D-394 (not cited in the
chapter), as the evidence check found.

Each section went in at its place in the field's own order: before the first
item that sorts after it, appendices last. After (`spec_fields_after.txt`):
one pair absent, D-310 §13.5.

## B50: D-071's Spec field

Every D-071 ruling is stated in §14.9: the implicitly specified condition,
`at`'s lift, resolution from the mount point, the world wrapper dissolving
into `baseline`, `design_world(ac)`, the swarm doctrine and the `product`
helper. No other trim section states one, so the field is §14.9 alone.

## B85

`rg _host_boundary_zero src/` finds nothing. `init!(sim)` (`src/sim.jl` 591)
calls the `Model`'s `init!`, which runs `boundary_zero!` under the catch that
sets `:built` and rethrows the wrapped `StepError` (`src/model.jl` 187–193).
`replay!` (`src/sim.jl` 920) restores and calls no `boundary_zero!`. §12.6
(spec 9430–9432, cited by the evidence check as §12.4) says `restore!` and
`replay!` each restore a checkpoint and run no boundary zero, and that only
`init!` runs it. Edit 4 drops `replay!` and names the host the code has.
Not edited: the next sentence's `event_phase!(sim, ESTABLISH)` is
`event_phase!(model, ESTABLISH)` in the code (`src/model.jl` 329), the
evidence check's note for the fixer; it lies outside B85's sentence.

## Edits, in order

Edits 1 to 4 are the spec phase, 5 onward the log phase. The Spec-field
records show the field as it stood when the edit applied, so later records
show bare sections an earlier edit added.

### 1. F54 — `docs/design/spec.md`

Old:

```
[§12.6][s12-6], [§12.7][s12-7], [§14.7][s14-7]). Error · service, or build in a `sample_times`
```

New:

```
[§12.6][s12-6], [§12.7][s12-7], §13.5, [§14.7][s14-7]). Error · service, or build in a `sample_times`
```

### 2. R12 glossary entry — `docs/design/spec.md`

Old:

```
[Appendix C][sC]). Severity is the kind's, not the payload's.

<a id="g-species">
```

New:

```
[Appendix C][sC]). Severity is the kind's, not the payload's.

<a id="g-requester-roster"></a>**requester roster** — the build's list of stop
requests, one `Requester(path, port, reason)` per `StopFlag` output port, in
build order (§13.5).

<a id="g-species">
```

### 3. R12 first-use link in §13.5 — `docs/design/spec.md`

Old:

```
This list is the requester roster (the build's
```

New:

```
This list is the [requester roster](#g-requester-roster) (the build's
```

### 4. B85 — `docs/design/companions/frame_walkthrough.md`

Old:

```
`init!` and `replay!` run boundary zero through `_host_boundary_zero!`, which
```

New:

```
`init!` runs boundary zero through the `Model`'s `init!`, which
```

### 5. B42, D-012 — `docs/design/decisions.md`

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

### 6. B44, D-057 — `docs/design/decisions.md`

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

### 7. B45 Spec, D-058 — `docs/design/decisions.md`

Old:

```
**Spec.** [Appendix C][sC]
```

New:

```
**Spec.** §13.2, [Appendix C][sC]
```

### 8. B45, R11, D-058 — `docs/design/decisions.md`

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

### 9. B46, D-059 — `docs/design/decisions.md`

Old:

```
[§13.4][s13-4], [§14][s14]
```

New:

```
[§13.4][s13-4], §13.6, [§14][s14]
```

### 10. B47, D-060 — `docs/design/decisions.md`

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

### 11. B48 (D-061), D-061 — `docs/design/decisions.md`

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

### 12. B49, D-062 — `docs/design/decisions.md`

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

### 13. B50 Spec, D-071 — `docs/design/decisions.md`

Old:

```
**Spec.** [§13.7][s13-7]
```

New:

```
**Spec.** §14.9
```

### 14. B50, D-071 — `docs/design/decisions.md`

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

### 15. B52, D-114 — `docs/design/decisions.md`

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

### 16. B53, D-120 — `docs/design/decisions.md`

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

### 17. B48 (D-130), D-130 — `docs/design/decisions.md`

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

### 18. B54, D-131 — `docs/design/decisions.md`

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

### 19. B57, D-141 — `docs/design/decisions.md`

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

### 20. B58, D-142 — `docs/design/decisions.md`

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

### 21. B59, D-143 — `docs/design/decisions.md`

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

### 22. B60, D-159 — `docs/design/decisions.md`

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

### 23. B40, D-184 — `docs/design/decisions.md`

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

### 24. B62 Spec, D-203 — `docs/design/decisions.md`

Old:

```
[§12.6][s12-6], [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]
```

New:

```
[§12.6][s12-6], §13.2, [§13.5][s13-5], [§13.6][s13-6], [Appendix C][sC]
```

### 25. B62, D-203 — `docs/design/decisions.md`

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

### 26. B48 (D-242), D-242 — `docs/design/decisions.md`

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

### 27. B68, D-255 — `docs/design/decisions.md`

Old:

```
[§12.7][s12-7], [§13.5][s13-5], [Appendix C][sC]
```

New:

```
[§12.7][s12-7], §13.2, [§13.5][s13-5], [Appendix C][sC]
```

### 28. B78, D-005 — `docs/design/decisions.md`

Old:

```
**Spec.** [§5.5][s5-5]
```

New:

```
**Spec.** [§5.5][s5-5], §13.8
```

### 29. B78, D-019 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2][s2], [§3.2][s3-2], [§3.3][s3-3], [§5.2][s5-2], [§10.5][s10-5]
```

New:

```
**Spec.** [§2][s2], [§3.2][s3-2], [§3.3][s3-3], [§5.2][s5-2], [§10.5][s10-5], §13.5
```

### 30. B78, D-022 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2][s2], [§11.1][s11-1], [§12.1][s12-1], [§12.3][s12-3]
```

New:

```
**Spec.** [§2][s2], [§11.1][s11-1], [§12.1][s12-1], [§12.3][s12-3], §13.4
```

### 31. B78, D-084 — `docs/design/decisions.md`

Old:

```
**Spec.** [§6.1][s6-1], [§6.2][s6-2], [§11.2][s11-2], [§11.7][s11-7], [§13.2][s13-2], [Appendix C][sC]
```

New:

```
**Spec.** [§6.1][s6-1], [§6.2][s6-2], [§11.2][s11-2], [§11.7][s11-7], [§13.2][s13-2], §13.5, [Appendix C][sC]
```

### 32. B78, D-147 — `docs/design/decisions.md`

Old:

```
**Spec.** [§5.3][s5-3], [§10.3][s10-3], [§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6], [§9.7][s9-7], [§14.5][s14-5], [Appendix D][sD]
```

New:

```
**Spec.** [§5.3][s5-3], [§10.3][s10-3], [§10.4][s10-4], [§10.5][s10-5], [§10.6][s10-6], [§9.7][s9-7], §13.5, [§14.5][s14-5], [Appendix D][sD]
```

### 33. B78, D-218 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4]
```

New:

```
**Spec.** [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§13.4][s13-4], §13.5
```

### 34. B78, D-231 — `docs/design/decisions.md`

Old:

```
**Spec.** [§2.5][s2-5], [§3.2][s3-2], [§7.3][s7-3], [§8.2][s8-2], [§9.1][s9-1], [Appendix C][sC], [Appendix D][sD]
```

New:

```
**Spec.** [§2.5][s2-5], [§3.2][s3-2], [§7.3][s7-3], [§8.2][s8-2], [§9.1][s9-1], §13.7, [Appendix C][sC], [Appendix D][sD]
```

### 35. B78, D-235 — `docs/design/decisions.md`

Old:

```
**Spec.** [§7.1][s7-1], [§8.2][s8-2], [§9.5][s9-5], [Appendix C][sC]
```

New:

```
**Spec.** [§7.1][s7-1], [§8.2][s8-2], [§9.5][s9-5], §13.4, [Appendix C][sC]
```

### 36. B78, D-237 — `docs/design/decisions.md`

Old:

```
**Spec.** [§4.3][s4-3], [§4.4][s4-4], [§8.2][s8-2], [§9.5][s9-5], [§9.7][s9-7], [Appendix C][sC]
```

New:

```
**Spec.** [§4.3][s4-3], [§4.4][s4-4], [§8.2][s8-2], [§9.5][s9-5], [§9.7][s9-7], §13.7, [Appendix C][sC]
```

### 37. B78, D-251 — `docs/design/decisions.md`

Old:

```
**Spec.** [§8.8][s8-8], [Appendix C][sC]
```

New:

```
**Spec.** [§8.8][s8-8], §13.2, §13.7, [Appendix C][sC]
```

### 38. B78, D-254 — `docs/design/decisions.md`

Old:

```
**Spec.** [§8.7][s8-7], [§9.2][s9-2], [§10.5][s10-5], [§11.5][s11-5], [§12.7][s12-7], [Appendix C][sC]
```

New:

```
**Spec.** [§8.7][s8-7], [§9.2][s9-2], [§10.5][s10-5], [§11.5][s11-5], [§12.7][s12-7], §13.2, [Appendix C][sC]
```

### 39. B78, D-261 — `docs/design/decisions.md`

Old:

```
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§11.2][s11-2], [§11.3][s11-3], [§11.5][s11-5], [§12.6][s12-6], [§13.5][s13-5], [Appendix B][sB]
```

New:

```
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§11.2][s11-2], [§11.3][s11-3], [§11.5][s11-5], [§12.6][s12-6], §13.4, [§13.5][s13-5], [Appendix B][sB]
```

### 40. B78, D-274 — `docs/design/decisions.md`

Old:

```
**Spec.** [§10.2][s10-2], [§10.6][s10-6], [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], [§14][s14], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

New:

```
**Spec.** [§10.2][s10-2], [§10.6][s10-6], [§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7], §13.4, [§14][s14], [§14.8][s14-8], [§14.10][s14-10], [Appendix B][sB]
```

### 41. B78, D-294 — `docs/design/decisions.md`

Old:

```
**Spec.** [§10.7][s10-7], [§12.4][s12-4]
```

New:

```
**Spec.** [§10.7][s10-7], [§12.4][s12-4], §13.4
```

### 42. B78, D-322 — `docs/design/decisions.md`

Old:

```
**Spec.** [§6.1][s6-1], [§9.1][s9-1]
```

New:

```
**Spec.** [§6.1][s6-1], [§9.1][s9-1], §13.7
```

### 43. B78, D-364 — `docs/design/decisions.md`

Old:

```
**Spec.** [§4.4][s4-4], [§8.2][s8-2], [§14.9][s14-9]
```

New:

```
**Spec.** [§4.4][s4-4], [§8.2][s8-2], §13.7, [§14.9][s14-9]
```

### 44. B78, D-387 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.6][s12-6]
```

New:

```
**Spec.** [§12.6][s12-6], §13.6
```

### 45. B78, D-389 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.4][s12-4], [§12.6][s12-6]
```

New:

```
**Spec.** [§12.4][s12-4], [§12.6][s12-6], §13.4
```

### 46. B78, D-398 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.1][s12-1], [§12.4][s12-4]
```

New:

```
**Spec.** [§12.1][s12-1], [§12.4][s12-4], §13.4
```

### 47. B78, D-401 — `docs/design/decisions.md`

Old:

```
**Spec.** [§12.2][s12-2]
```

New:

```
**Spec.** [§12.2][s12-2], §13.2
```

### 48. B78, D-406 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.2][s11-2], [§11.6][s11-6], [§14.4][s14-4], [§14.7][s14-7], [Appendix C][sC]
```

New:

```
**Spec.** [§11.2][s11-2], [§11.6][s11-6], §13.3, §13.5, [§14.4][s14-4], [§14.7][s14-7], [Appendix C][sC]
```

### 49. B78, D-407 — `docs/design/decisions.md`

Old:

```
**Spec.** [§11.2][s11-2], [Appendix B][sB]
```

New:

```
**Spec.** [§11.2][s11-2], §13.3, [Appendix B][sB]
```

