# Chapter 14, track 2 log, agent 3 pass (the verifier's eight fixes)

The fixes `ch14/track2_verify.md` lists, applied by
`scratch_track2/2/fix3.py`, linkified, then rewrapped by rendered columns with
`scratch_track2/2/reflow.py` (lines found by `scratch_track2/2/over.py`). Each
hunk below is the working diff after `linkify.jl` and the rewrap, so a bare
citation the script wrote reads linked. Fix numbers follow the report: 1 is
D-427 with its Index row and link definitions and the §14.2 and §14.9
citations; 2 the D-071 annotation; 3 D-122; 4 D-098; 5 D-409; 6 D-424; 7
D-422; 8 D-426. No Position changed.

## decisions.md, hunk 1 (-427,0 +428)

Old:

```markdown
(none)
```

New:

```markdown
| [D-427][d-427] | Refuse a condition entry naming an internally wired input at resolution, with its producer | ratified |
```

## decisions.md, hunk 2 (-2363,3 +2364,3)

Old:

```markdown
internally wired face; resolution refuses it with the producer named, as [D-277][d-277]
states for a face fed by a component. And no source ships a `design_world`; it
is the rig this design records for design-time work ([§14.9][s14-9]).
```

New:

```markdown
internally wired face; resolution refuses it with the producer named, as [D-427][d-427]
states for a condition entry and [D-277][d-277] for a `get_input`. And no source ships a
`design_world`; it is the rig this design records for design-time work ([§14.9][s14-9]).
```

## decisions.md, hunk 3 (-3239,3 +3240,3)

Old:

```markdown
stores, only the services' readers take a store selector ([§14.4][s14-4]). No client
policy applies on top of the source rule, which is the resolver's, not a
client's ([D-406][d-406]).
```

New:

```markdown
stores, only the services' readers take a store selector ([§14.4][s14-4]). [D-406][d-406]'s
Position makes the source rule "the resolver's, not a client's", and its
Rationale says the family "splits by source and not by client".
```

## decisions.md, hunk 4 (-4120,3 +4121,3)

Old:

```markdown
Annotation (2026-10-20): only `trim!` takes the `baseline` keyword now. The
clause held when written, the spec at `8e2505c` reading "the `baseline` keyword
`init!`/`trim!` take", and `init!` lost the keyword later.
```

New:

```markdown
Annotation (2026-10-20): only `trim!` takes the `baseline` keyword. `init!`
took none when this entry was written (`4728a93` gives
`init!(sim, condition; t0)`).
```

## decisions.md, hunk 5 (-16438,2 +16439)

Old:

```markdown
Annotation (2026-10-20): the service half bears on the reads a run acts on, as
[§13.5][s13-5] frames the rejection. Since [D-414][d-414] the locality law is authoring guidance,
```

New:

```markdown
Annotation (2026-10-20): since [D-414][d-414] the locality law is authoring guidance,
```

## decisions.md, hunk 6 (-16797,7 +16797,7)

Old:

```markdown
**Rationale.** No entry records either reason. Both entered the code in
`415ed0b` and moved into `src/trim.jl` in `3408028`, and the landed [§14.8][s14-8]
lists both cases. The code's comments give the reasons. An inverted pair is a
box no projection can honor, so `clamp` would answer the upper bound and the
report would name a saturation nobody authored. A tolerance is the half-width
of its residual's or check's box, so zero and negative name no box, and a
non-positive residual tolerance sends the acceptance test to `Inf` or `NaN`
```

New:

```markdown
**Rationale.** No entry records either reason. Both were named in the kind in
`415ed0b`, `src/trim.jl`'s checks have raised them since `3408028`, and the
landed [§14.8][s14-8] lists both cases. The code's comments give the reasons. An inverted
pair is a box no projection can honor, so `clamp` would answer the upper bound and
the report would name a saturation nobody authored. A tolerance is the
half-width of its residual's or check's box, so zero and negative name no box,
and a non-positive residual tolerance sends the acceptance test to `Inf` or `NaN`
```

## decisions.md, hunk 7 (-16847,3 +16847,5)

Old:

```markdown
**Rationale.** No entry records the limits. The code checks them in
`_check_seedable` (`src/linearize.jl`), and the suite cites "[§14.10][s14-10], [D-036][d-036],
[D-276][d-276]" for them, though neither Position states them. A seed is a `Float64`
```

New:

```markdown
**Rationale.** The code checks the limits in `_check_seedable`
(`src/linearize.jl`), and the suite cites "[§14.10][s14-10], [D-036][d-036], [D-276][d-276]" for them.
[D-276][d-276]'s Position bullet "A store selector takes a field name with at most an
index step" already bounds the `x` list. No entry records the `u` list's step
limit, the exact-`Float64` leaf or the reason names. A seed is a `Float64`
```

## decisions.md, hunk 8 (-16853,3 +16855,4)

Old:

```markdown
resolving to a vector or a bundle is [D-272][d-272]'s annotation of 2026-09-30, and the
second bullet names its reason only. This entry records the limits as [§14.10][s14-10]
and the code state them, and decides nothing new.
```

New:

```markdown
resolving to a vector or a bundle is [D-272][d-272]'s second bullet, as its annotation
of 2026-09-30 spells it, and the second bullet here names its reason only. This
entry records the limits as [§14.10][s14-10] and the code state them, and decides nothing
new.
```

## decisions.md, hunk 9 (-16901,3 +16904,8)

Old:

```markdown
input is the forbid-seeding marker itself ([D-295][d-295]). Two pieces remain recorded,
as [§14.10][s14-10] states. [D-073][d-073]'s Position records the sampled-data extension unbuilt,
not this tooling, and no entry carried it. The entry decides nothing new.
```

New:

```markdown
input is the forbid-seeding marker itself ([D-295][d-295]). Section 14.10 of the
spec text at `9ad74d5`, written when the marker came to exist, gave the
two-piece form the Position restates. It reads "What stays recorded is only
the remaining tooling over that visibility", names pinned-face validation by
the tap declaration and a feedthrough-graph lint, and closes "Additive when a
consumer shows up, no flag day". The landed [§14.10][s14-10] states it. [D-073][d-073]'s Position
records the sampled-data extension unbuilt, not this tooling, and no entry
carried it. The entry decides nothing new.
```

## decisions.md, hunk 10 (-16906,0 +16915,23)

Old:

```markdown
(none)
```

New:

```markdown
### D-427 — Refuse a condition entry naming an internally wired input at resolution, with its producer

**Status.** ratified

**Position.** Resolution refuses a condition entry naming an input face that a
component feeds, as `ConditionResolution` with reason `:internally_wired` and
the producer in hand.

**Spec.** [§14.2][s14-2], [§14.9][s14-9]

**Rationale.** Section 16.2 of the design text at `2ee101a`, which settled
[D-065][d-065], stated the ruling. Resolution "walks the export chain to the root slot
and errors if the face never surfaces — an internally-wired input has no slot
and writing it is meaningless (the first sweep overwrites)". No Position
carries it. [D-277][d-277]'s second bullet states the refusal for a `get_input` and
points to [§14.2][s14-2] for the condition entry, and [D-071][d-071]'s second bullet and [D-139][d-139]'s
Rationale assert it by citing [§14.9][s14-9]. The code raises it in `_root_input`
(`src/conditions.jl`), with the producer, and the landed [§14.2][s14-2] states it. This
entry records the refusal as that design text, [§14.2][s14-2] and the code state it,
and decides nothing new.

**Rejected.** None beyond [D-065][d-065]'s list.

```

## decisions.md, hunk 11 (-17307,0 +17339)

Old:

```markdown
(none)
```

New:

```markdown
[d-427]: #d-427--refuse-a-condition-entry-naming-an-internally-wired-input-at-resolution-with-its-producer
```

## spec.md, hunk 1 (-11449 +11449)

Old:

```markdown
`ConditionResolution` with reason `:internally_wired` ([D-277][d-277]). Unexported stays
```

New:

```markdown
`ConditionResolution` with reason `:internally_wired` ([D-427][d-427]). Unexported stays
```

## spec.md, hunk 2 (-12608,2 +12608,2)

Old:

```markdown
a `get_input` ([D-277][d-277]). The service compiles the scoped condition and reads, and
runs the identical loop. It never knows where its paths are mounted.
```

New:

```markdown
a `get_input` ([D-277][d-277], [D-427][d-427]). The service compiles the scoped condition and reads,
and runs the identical loop. It never knows where its paths are mounted.
```

## spec.md, hunk 3 (-15503,0 +15504)

Old:

```markdown
(none)
```

New:

```markdown
[d-427]: decisions.md#d-427--refuse-a-condition-entry-naming-an-internally-wired-input-at-resolution-with-its-producer
```
