# Chapter 13, track 2: agent 2's log

Agent 2 of `track2_prompts.md`. One commit on `master`, `32a4e98`: the
entries D-408 to D-414, their Index rows, their citations in chapter 13,
two citations of existing entries that lesson 42 put in place of dropped
bullets, and one Spec field.

Every edit was matched by its old text and asserted to occur exactly once
(the Spec-field edit: once inside D-369) before any file was written. The
script is `scratch_track2/2/apply.py` (`python3 -I apply.py <root> <out>`).
It reads the base from HEAD's blobs, so a rerun replays every edit afresh.
The entry text is `scratch_track2/2/entries.md`, written with bare
citations. After each spec edit the script spills any line of the edited
paragraph past 80 rendered columns onto the next line, cascading only while
a line it filled overflows. Link syntax, `**`, `*` and backticks do not
count. `width.py` measures rendered columns; every changed line is at most
80. `linkify.jl` then linked the bare citations, so the spec records below
show the committed, linked text.

## Battery

Before the edits, at `e1a7004`, and again before the commit, each check as
its own command: `linkify.jl`; `check_refs.jl` OK; `check_rows.jl` OK, with
408 to 414 reported as newly cited and no coverage drop, so no rebaseline;
`check_glossary.jl --strict` OK; `check_bold.jl` OK (chapter 13: 57 bold
spans, 521 bold words, unchanged); `linkify.jl` again a no-op (diff hash
unchanged). Agent 1's `spec_fields.py` after the commit: one pair absent,
D-310 §13.5, as agent 1 left it.

## The items

Every source entry was read in full. Every Position in the log was
extracted (`scratch_track2/2/positions.py`, output `positions.txt`) and
grepped for each proposed bullet before it was written (lesson 42).

Written:

- B43, D-030 → D-408. From the Rejected "Mid-frame abort" and the design
  text that ruled D-030 (`framework_design.md` at `6fe7de2`, §15.6: "the
  boundary is all-or-nothing outside the sim task … discard the failed
  boundary, promote the previous snapshot to final, and rejoin the ordinary
  tail"). No Position states the discard or the promotion.
- B47 with B72, D-060 and D-316 → D-409. The one topic both rule in §13.5:
  D-060's Rejected "Observation-by-path" and D-316's Rationale paragraph on
  the narrowed rejection, which D-060's annotation of 2026-10-08 also
  records. D-083's Position covers the inspection half for output-device
  reads only.
- B47, D-060 → D-410. Post-terminal dynamics, from the second ground of the
  Rejected "Termination-by-exception". Kept apart from D-409 and D-413,
  since it is another topic and one source.
- B59, D-143 → D-411. The rig stub, from the Rationale. The zero-contributor
  use is already D-143's Position, so the entry states the stub only.
- B70, D-312 → D-412. The pin's generalization, from the annotation of
  2026-10-06. The `Constant` pin is already D-312's Position and its reason
  is a reason.
- B72, D-316 → D-413. The reason string telling the two uses apart. The
  clause before it, an ignored request still a cell, follows from D-316's
  Position (its ports land in the cell block; the mask only gates the scan)
  and is left out under lesson 68.
- B77 → D-414. From `_advance!`, `_stop_hit`, `_bind_policy` and `_t_bound`
  in `src/sim.jl` and §13.5, in D-400's form. `run!` and `replay!` reach
  `_advance!` through `_run_body!`, `step!` directly.

Dropped:

- B45, D-058. Lesson 42: D-058's Position states "paths and names as
  strings, expected/observed port types". "Never instances" is its Rejected
  item, whose ground is the `compact_backtrace` lesson. §13.2 already cites
  D-058 at "Two rendering rules are doctrine, not style".
- B49, D-062. Lesson 42: D-062's Position says the library "ships as
  ordinary components", the ruling §13.7 bolds with D-062. "Ordinary status
  keeps schema authority total" is the ground of the Rejected
  "Framework-privileged library blocks", a reason.
- B51, D-108. Lesson 42, as the Status line asks: D-108's Position lists
  each service's legal states, `capture` at `initialized`/`stopped` and
  `init!` and `trim!` also at `built`, with no `errored`; D-059's makes
  `errored` terminal. No entry. D-108 is cited at §13.6's refusal sentence
  (edit S7); its Spec field already lists §13.6.
- B55, D-132. Lesson 42: D-132's Position makes the interrupt a
  control-plane stop that ends `stopped`, D-317 bullet 8 says it is never
  wrapped, and D-398 bullet 2 names "§13.4's defensive arm" and gives its
  disposition, `stopped`. §13.4 already cites D-132 and D-398 there.
- B56, D-136. Lesson 42: D-369 bullet 3, from D-136's Rationale, says the
  published framework status carries per writer `recent`, the boundary's
  drained ring. D-369 is cited at §13.2's surfacing sentence (edit S8), and
  §13.2 joins its Spec field (edit L1).
- B62, D-203, all three rulings. (1) The configured bound read off the
  record's policy: D-260 bullet 3, "The termination record is the policy's
  one lasting home", D-255's "the termination record holds that one", and
  D-203 bullet 1's `EndTimeReached` with no payload. (2) "Why" and "how"
  answered from the record: a consequence of D-203's Position, the record
  holding the source and the tail residue (lesson 68; §13.5 writes it with
  "therefore"). (3) Appendix C gaining nothing: D-203 bullets 1 and 2, the
  sources outside Appendix C's set and the interrupt never a fifth kind; the
  Rejected ground also cites §13.5 back (lesson 43). §13.5 cites D-203,
  D-255 and D-260 at each.
- B64, D-225. Lesson 68: `@test_throws StepError{ConformanceFailure}` is
  D-225's Position, "a species is `StepError{Kind}`", used as a test. The
  evidence check found the Rationale does not spell it.
- B67, D-250. Lesson 68: D-250's Position, "A warning raised while
  producing an artifact lives on that artifact", and its bullet 3, which
  counts stopped-sim service calls among artifact-producing calls. §13.2
  writes the case with "so" and bolds the rule with D-250.
- B71, D-313. `decisions_style.md` rule 9: library admission is
  implementation policy and earns no entry. "A gain earns no block" is also
  D-313's guidelines applied to one block, and "a language, not a toolbox"
  a reason.
- B72's operator-path clause. Lesson 42: D-316 bullet 2 refuses
  `:stop_flag_at_root` "since a request is the model's, never an
  operator's (§12.1)", and D-132 makes the operator's stop a control-plane
  stop. §13.5's sentence describes the two channels, which B77 lists as a
  description.

Not in the items and left alone: B47's evidence also lists "compound stop
logic composes in-model", from D-060's Rejected annotation. B47's Status
line orders only the inspection doctrine and post-terminal dynamics.

## The entries, as committed

```markdown
### D-408 — Discard a failed boundary and promote the previous snapshot to final

**Status.** ratified

**Position.** A loop failure discards the failed boundary, promotes the
previous snapshot to final and rejoins the ordinary tail. No torn final
snapshot is published.

**Spec.** [§13.6][s13-6]

**Rationale.** This restates the ground of [D-030][d-030]'s rejection of a mid-frame
abort, "torn final snapshot; consumers observe un-swept state", which its
Position does not state. That Position says only that a loop failure runs
the same protocol from the catch path. The design text that ruled [D-030][d-030]
stated the discard and the promotion, since the boundary is all-or-nothing
outside the loop, and the log's entry did not carry them. The entry decides
nothing new.

**Rejected.** None beyond [D-030][d-030]'s list.

### D-409 — Keep service observation on the contract and let inspection see everything

**Status.** ratified

**Position.** Two rulings on observation by path.

- Observation by path is rejected. Service observation must speak the
  contract, while inspection observation sees everything, [§6.1][s6-1]'s knowledge
  rule applied to reads.
- The ignore list narrows the rejection. It reads no arbitrary cell. It
  addresses the `Build`'s requester roster, a build product like the
  root-input list, and it binds at an advance, a stopped-sim point where
  conditions already address state by path ([§14.1][s14-1]).

**Spec.** [§13.5][s13-5]

**Rationale.** The first bullet restates the ground of [D-060][d-060]'s rejection of
observation by path, which its Position does not state. The second restates
the paragraph of [D-316][d-316]'s Rationale on the narrowed rejection, which [D-060][d-060]'s
annotation of 2026-10-08 also records. [D-316][d-316]'s Position states neither.
[D-083][d-083]'s Position states the inspection half for output-device reads alone.
The entry decides nothing new.

**Rejected.** None beyond the source entries' lists.

### D-410 — Leave post-terminal dynamics to the model

**Status.** ratified

**Position.** Post-terminal dynamics are the model's job, and a model states
its own terminal dynamics.

**Spec.** [§13.5][s13-5]

**Rationale.** This restates the second ground of [D-060][d-060]'s rejection of
termination by exception, "models never state their terminal dynamics",
which its Position does not state. That Position makes termination model
state, never an exception. The entry decides nothing new.

**Rejected.** None beyond [D-060][d-060]'s list.

### D-411 — Spell the component test rig's stub as a `Constant` holding the test handle

**Status.** ratified

**Position.** `Constant` subsumes the rig stub. The concrete provider a rig
wires to an abstract face ([D-120][d-120]) is typically a `Constant` holding the test
handle, the block's first shipped instance. Bespoke stubs stay ordinary
components wherever the double must compute something.

**Spec.** [§13.7][s13-7]

**Rationale.** This restates the rig-stub clause of [D-143][d-143]'s Rationale, which
its Position does not state. That Position spells the block's other use, the
zero-contributor aggregate. The demonstrated-need charter the Rationale then
cites is retired ([D-313][d-313]), and the stub does not rest on it. The entry
decides nothing new.

**Rejected.** None beyond [D-143][d-143]'s list.

### D-412 — Pin a library block whose output depends on neither state nor a walking input

**Status.** ratified

**Position.** A library block whose output depends on neither its continuous
state nor a walking input, only on instance data and a mode, declares
`(out = Pinned{V},)`, as `Constant` does. `Step` and `Relay` are such
blocks. `UnitDelay` stays plain, because the discrete tier pins wholesale
([D-263][d-263]).

**Spec.** [§13.7][s13-7]

**Rationale.** This restates [D-312][d-312]'s annotation of 2026-10-06, which its
Position does not state. That Position pins `Constant` alone. The
annotation rests on the Rationale's ground for `Constant`. Such a block is
never seeded, carries zero partials under every activation, and its pinned
form is the more connectable one. The entry decides nothing new.

**Rejected.** None beyond [D-312][d-312]'s list.

### D-413 — Let the reason string, never the framework, tell a stop request's two uses apart

**Status.** ratified

**Position.** Validity breakdown and scenario completion share the
stop-request mechanism. The reason string is what tells a reader which, and
the framework never will.

**Spec.** [§13.5][s13-5]

**Rationale.** This restates a clause of [D-316][d-316]'s Rationale, which its
Position does not state. That Position makes `stop_reason` an optional
declaration whose string the requester roster carries. The clause before it,
that an ignored request is still a cell in every snapshot, follows from the
Position and is not restated. The entry decides nothing new.

**Rejected.** None beyond [D-316][d-316]'s list.

### D-414 — Check for an honoured request at an advance's entry, and bound `t_end` first

**Status.** ratified

**Position.** Two rulings on what every advance, `run!`, `replay!` and
`step!`, checks before its first frame.

- The advance reads the latest snapshot for an honoured stop request before
  its first frame. After `init!` that snapshot is boundary zero's, so an
  authored condition already terminal ends the run at `t₀` with that
  snapshot final, integrating nothing. An advance that starts later ends
  where it started, advancing no frame.
- A `t_end` that is not a non-negative real is refused as `ArgumentInvalid`,
  reason `:range`, before the ignore list is read.

**Spec.** [§13.5][s13-5]

**Rationale.** Both bullets record what the code does and [§13.5][s13-5] states.
`_advance!` in `src/sim.jl` calls `_stop_hit` on the latest snapshot before
its loop and returns `ModelRequestedStop` with no frame advanced.
`_bind_policy` calls `_t_bound`, which throws the `ArgumentInvalid`
fail-fast, before it validates the ignore list. [D-316][d-316]'s Position rules the
scan after every publication, not the entry read, and [D-255][d-255]'s says only that
`t_end` is validated per call. The entry decides nothing new.

**Rejected.** None beyond [D-255][d-255]'s and [D-316][d-316]'s lists.
```

## Edits, in order

S1 to S11 are `docs/design/spec.md`, in the order applied; L1 to L3 are `docs/design/decisions.md`.

### S1. D-408, §13.6, the abnormal-path bold

Old:

```
to final, and rejoins the ordinary tail** ([D-030][d-030]). The protocol becomes one tail
with two entry points. Graceful entry follows a *completed* final boundary, and
abnormal entry follows a *discarded* one. Everything downstream of "final
```

New:

```
to final, and rejoins the ordinary tail** ([D-030][d-030], [D-408][d-408]). The protocol becomes one
tail with two entry points. Graceful entry follows a *completed* final boundary,
and abnormal entry follows a *discarded* one. Everything downstream of "final
```

### S2. D-409, §13.5, the inspection doctrine

Old:

```
a line [D-316][d-316] narrows. Inspection is human-facing, has no effect on run
```

New:

```
a line [D-316][d-316] narrows ([D-409][d-409]). Inspection is human-facing, has no effect on run
```

### S3. D-413, §13.5, ignored requests

Old:

```
validity broke even on a run that continued ([D-316][d-316]). Two uses share
```

New:

```
validity broke even on a run that continued ([D-316][d-316], [D-413][d-413]). Two uses share
```

### S4. D-410, §13.5, post-terminal dynamics

Old:

```
have well-defined terminal states, which is better modeling ([D-060][d-060]).
```

New:

```
have well-defined terminal states, which is better modeling ([D-060][d-060], [D-410][d-410]).
```

### S5. D-414, §13.5, the `t_end` range

Old:

```
`ArgumentInvalid`, refused before the ignore list is read.
```

New:

```
`ArgumentInvalid`, refused before the ignore list is read ([D-414][d-414]).
```

### S6. D-414, §13.5, the entry check

Old:

```
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a build's state) already
terminal ends the run at `t₀` with that snapshot final, integrating nothing. A
run that starts later ends where it started, advancing no frame.
```

New:

```
first frame ([D-414][d-414]). After `init!` that snapshot is boundary zero's, so an
authored [condition](#g-condition) (the path-addressed sparse overlay that sets a build's state)
already terminal ends the run at `t₀` with that snapshot final, integrating
nothing. A run that starts later ends where it started, advancing no frame.
```

### S7. D-108 (B51, lesson 42), §13.6, the refusal of an errored simulation

Old:

```
errored simulation outright (`ServiceLifecycle`, [§14][s14]). Operations on the [roster](#g-roster)
(the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
```

New:

```
errored simulation outright (`ServiceLifecycle`, [§14][s14], [D-108][d-108]). Operations on the
[roster](#g-roster) (the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
```

### S8. D-369 (B56, lesson 42), §13.2, the stream surfacing through the status

Old:

```
each snapshot carries beside the signal table) ([§11.2][s11-2]). The liveness heartbeat
([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record ([§10.7][s10-7]) sits
beside the writers' records in the status. The stream is never collected, since
there is no collection to join. Nothing in the argument of [D-084][d-084] applies to it.
That decision is about what the *build* warns on.
```

New:

```
each snapshot carries beside the signal table) ([§11.2][s11-2], [D-369][d-369]). The liveness
heartbeat ([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record
([§10.7][s10-7]) sits beside the writers' records in the status. The stream is never
collected, since there is no collection to join. Nothing in the argument of
[D-084][d-084] applies to it. That decision is about what the *build* warns on.
```

### S9. D-412, §13.7, the pin generalization

Old:

```
each declares its `out` pinned ([D-312][d-312]).
```

New:

```
each declares its `out` pinned ([D-312][d-312], [D-412][d-412]).
```

### S10. D-411, §13.7, the two uses of `Constant`

Old:

```
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant`, publishing the value its instance holds) instead
([§14.9][s14-9], [D-364][d-364]).
```

New:

```
Two uses need `Constant` ([D-143][d-143], [D-411][d-411]), though a listed block needs none to be
built ([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a
required aggregate input has no physical contributor, and the zero total must be
spelled as a wire. The rig stub below is the other. The block's value is
instance data, like junction arity, not an overridable default ([D-143][d-143]). A
configuration wanting an externally settable source uses a root input ([§11.3][s11-3]),
which keeps the block from drifting into a back-door input default. A handle
that references bulk data never surfaces as a root input ([D-237][d-237]); a rig holds
such a handle through a [constant source](#g-constant-source) (a `Constant`, publishing the value its
instance holds) instead ([§14.9][s14-9], [D-364][d-364]).
```

### S11. D-411, §13.7, the first shipped instance

Old:

```
makes it the source block's first shipped instance ([D-143][d-143]). Bespoke
```

New:

```
makes it the source block's first shipped instance ([D-143][d-143], [D-411][d-411]). Bespoke
```

### L1. D-369 Spec field (B56, lesson 42)

Old, inside D-369:

```
**Spec.** [§11.8][s11-8]
```

New:

```
**Spec.** [§11.8][s11-8], [§13.2][s13-2]
```

### L2. Index rows

Inserted after the row `| [D-407][d-407] | Read the log through the read-selector family, as columns | ratified |`:

```
| [D-408][d-408] | Discard a failed boundary and promote the previous snapshot to final | ratified |
| [D-409][d-409] | Keep service observation on the contract and let inspection see everything | ratified |
| [D-410][d-410] | Leave post-terminal dynamics to the model | ratified |
| [D-411][d-411] | Spell the component test rig's stub as a `Constant` holding the test handle | ratified |
| [D-412][d-412] | Pin a library block whose output depends on neither state nor a walking input | ratified |
| [D-413][d-413] | Let the reason string, never the framework, tell a stop request's two uses apart | ratified |
| [D-414][d-414] | Check for an honoured request at an advance's entry, and bound `t_end` first | ratified |
```

### L3. The entries

Inserted between D-407's last line, `  specialization.`, plus its blank line, and the `<!-- citation link definitions` marker: the seven entries above, each followed by a blank line. `linkify.jl` then added the `[d-408]` to `[d-414]` definitions to both files' generated blocks.

## Review fixes (`f6beddf`)

The orchestrator accepted the four findings of `track2_verify.md`. The
script is `scratch_track2/2/fix.py` (`python3 -I fix.py <root>`). It
asserts each old text once before writing. It was run on `32a4e98`'s tree,
and then `linkify.jl` relinked. One hand edit followed, F1b. The full
diff is `scratch_track2/2/fix.diff`. Nothing had been pushed, so the
renumbering is safe.

### F1. D-408's Rationale names its source

Old:

```
the same protocol from the catch path. The design text that ruled [D-030][d-030]
stated the discard and the promotion, since the boundary is all-or-nothing
outside the loop, and the log's entry did not carry them. The entry decides
nothing new.
```

New, as the verifier worded it:

```
the same protocol from the catch path. The design text at `6fe7de2` (§15.6),
which filled the seat D-030's catch-path clause left, stated the discard and
the promotion, since the boundary is all-or-nothing outside the sim task, and
no entry carried them. The entry decides nothing new.
```

F1b. `check_refs.jl` then failed: "decisions.md: §15.6 — unknown section".
`§` is reserved for spec citations, and the design text's §15.6 is not the
spec's. The sentence was rewritten so it uses no `§`:

```
the same protocol from the catch path. Section 15.6 of the design text at
`6fe7de2`, which filled the seat [D-030][d-030]'s catch-path clause left, stated the
discard and the promotion, since the boundary is all-or-nothing outside the
sim task, and no entry carried them. The entry decides nothing new.
```

### F2. D-409 keeps bullet 1 alone

Old Position:

```
**Position.** Two rulings on observation by path.

- Observation by path is rejected. Service observation must speak the
  contract, while inspection observation sees everything, [§6.1][s6-1]'s knowledge
  rule applied to reads.
- The ignore list narrows the rejection. It reads no arbitrary cell. It
  addresses the `Build`'s requester roster, a build product like the
  root-input list, and it binds at an advance, a stopped-sim point where
  conditions already address state by path ([§14.1][s14-1]).
```

New:

```
**Position.** Observation by path is rejected. Service observation must speak
the contract, while inspection observation sees everything, [§6.1][s6-1]'s knowledge
rule applied to reads.
```

Old Rationale and Rejected:

```
**Rationale.** The first bullet restates the ground of [D-060][d-060]'s rejection of
observation by path, which its Position does not state. The second restates
the paragraph of [D-316][d-316]'s Rationale on the narrowed rejection, which [D-060][d-060]'s
annotation of 2026-10-08 also records. [D-316][d-316]'s Position states neither.
[D-083][d-083]'s Position states the inspection half for output-device reads alone.
The entry decides nothing new.

**Rejected.** None beyond the source entries' lists.
```

New, with D-129 named beside D-083 as the verifier's note asks:

```
**Rationale.** This restates the ground of [D-060][d-060]'s rejection of observation
by path, which its Position does not state. [D-083][d-083]'s Position states the
inspection half for output-device reads alone, and [D-129][d-129]'s has service reads
speak the contract and inspection reads speak structure. The entry decides
nothing new.

**Rejected.** None beyond [D-060][d-060]'s list.
```

### F3. D-410 dropped, D-411 to D-414 renumbered D-410 to D-413

- The D-410 entry was deleted whole, from its heading to D-411's heading
  (its text is under "The entries, as committed" above), and so was its
  Index row `| [D-410][d-410] | Leave post-terminal dynamics to the model |
  ratified |`.
- Spec §13.5: "which is better modeling ([D-060][d-060], [D-410][d-410])."
  became "which is better modeling ([D-060][d-060])."
- The renumbering ran in ascending order, after the deletion. In the text
  before each file's link-definition marker, `### D-n ` became
  `### D-(n-1) ` and `[D-n][d-n]` became bare `D-(n-1)`, and the script
  asserted that no `D-n` was left. It replaced two occurrences per number in
  the log (heading and Index row). In the spec it replaced D-411 2 (both in
  §13.7), D-412 1 (§13.7), D-413 1 (§13.5) and D-414 2 (§13.5). The log
  entries cite none of their sibling numbers. `linkify.jl` regenerated the
  `[d-410]` to `[d-413]` definitions in both files. `rg 'd-414|D-414'
  docs/design/` finds nothing.
- Map: D-411 (rig stub) → D-410, D-412 (pin) → D-411, D-413 (reason
  string) → D-412, D-414 (advance entry) → D-413.

### F4. D-412's citation moved to the sentence it rules (§13.5)

Old:

```
validity broke even on a run that continued ([D-316][d-316], [D-413][d-413]). Two uses share
the mechanism, validity breakdown and scenario completion. The reason string
is what tells a reader which, and the framework never will.
```

New:

```
validity broke even on a run that continued ([D-316][d-316]). Two uses share
the mechanism, validity breakdown and scenario completion. The reason string
is what tells a reader which, and the framework never will ([D-412][d-412]).
```

### Battery before `f6beddf`

`linkify.jl`; `check_refs.jl` OK (after F1b); `check_rows.jl` OK, no
coverage drop and no rebaseline; `check_glossary.jl --strict` OK;
`check_bold.jl` OK (chapter 13: 57 spans, 521 words); `linkify.jl` again a
no-op (diff hash unchanged). `spec_fields.py`: only D-310 §13.5 absent, as
before.
