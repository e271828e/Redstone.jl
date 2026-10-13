# Chapter 11, step 5: the editorial fixer's log, half 2

Units F, G1, G2, H and J. The items are `chapter_pass_2.md`'s EDITORIAL
items and the rulings RP-8 to RP-13 of `chapter_rulings.md`. Each edit is
given in the order applied, as its unit's `new.md` source with runs of
whitespace collapsed to one space. Replay each by a whitespace-insensitive
match, which hits exactly once. Edit 40 is the exception: it is a code
block, given verbatim with its spaces. Edit 41 is the rewrap, which changes
whitespace only. Edit 42 came after it.

Each edit's claims were updated in its unit's `inventory.json`, listed at
the end. Every unit, A to D included, prints `checks failed: 0`.

## Edits

### 1. P2-12, unit F

Old:

```text
The input [trace](#g-trace) is the sequence of drained, [device](#g-device)-tagged
```

New:

```text
The input [trace](#g-trace) is the sequence of [drained](#g-drain), [device](#g-device)-tagged
```

### 2. P2-12, unit F

Old:

```text
A frame is one iteration of the loop, from drain to publication.
```

New:

```text
A frame is one iteration of the loop, from drain to publication. The drain is the frame-top swap that applies staged device writes to the root inputs.
```

### 3. P2-12, unit F

Old:

```text
At the [drain](#g-drain) (the frame-top swap that applies staged device writes to the root inputs) each drained [staging cell](#g-staging-cell) is scanned.
```

New:

```text
At the drain each drained [staging cell](#g-staging-cell) is scanned.
```

### 4. P2-12, unit F

Old:

```text
A face is the name a port wears on its component's boundary.
```

New:

```text
A face is the name a port wears on its [component](#g-component)'s boundary. A component is the unit of modeling, a leaf or an assembly.
```

### 5. P2-12, unit F

Old:

```text
On the dense [component](#g-component) (the unit of modeling, a leaf or an assembly) the conversion costs about 2×
```

New:

```text
On the dense component the conversion costs about 2×
```

### 6. P2-7, unit F

Old:

```text
The rule is uniform because a [claim](#g-claim)'s *width* is a fact about one [binding](#g-binding) (the value passed at `attach!` that makes a device framework-legible), not about a category of writers. A claim is the set of faces a device *may* write. A [greedy claim](#g-greedy-claim) is the unclaimed complement the framework computes at attach. It is enumerated and as wide as the root [contract](#g-contract) (the root's declared interface, [§11.3][s11-3]), so keying
```

New:

```text
The rule is uniform because the *width* of a [claim](#g-claim) (the set of faces a device *may* write) is a fact about one [binding](#g-binding), the value passed at `attach!` that makes a device framework-legible, not about a category of writers. A [greedy claim](#g-greedy-claim) is the unclaimed complement the framework computes at attach ([§11.3][s11-3]). It is enumerated and as wide as the root [contract](#g-contract) (the root's declared interface), so keying
```

The binding's gloss becomes an appositive so the sentence keeps one parenthetical; the §11.3 pointer moves to the greedy claim's sentence.

### 7. P2-8, unit F

Old:

```text
Per [boundary](#g-boundary) (a published consistency point) it is smaller than the [log](#g-log)'s [snapshot](#g-snapshot), the immutable per-boundary publication. The log is the retained sequence of published snapshots. The snapshot is the carve-out's standing occupant
```

New:

```text
Per [boundary](#g-boundary) (a published consistency point) it is smaller than the [log](#g-log)'s [snapshot](#g-snapshot). The log is the retained sequence of published snapshots. A snapshot, the immutable per-boundary publication, is the carve-out's standing occupant
```

### 8. P2-9, unit F

Old:

```text
counters, and the fingerprint and the [deployment](#g-deployment) ([D-319][d-319]).
```

New:

```text
counters, and the fingerprint (the structural layout) and the [deployment](#g-deployment) ([D-319][d-319]).
```

### 9. P2-27, unit F

Old:

```text
the [run](#g-run) (the state one run owns) holds
```

New:

```text
the [`Run`](#g-run) (the state one run owns, a `Simulation` field) holds
```

### 10. P2-9, unit F

Old:

```text
The fingerprint (the structural layout) and the deployment are the parts of the header replay compares
```

New:

```text
The fingerprint and the deployment are the parts of the header replay compares
```

### 11. P2-9, unit F

Old:

```text
The header carries the run's `Deployment` and the structural layout. The deployment comes from [§9.2][s9-2].
```

New:

```text
The deployment comes from [§9.2][s9-2].
```

### 12. P2-9, unit F

Old:

```text
The layout is the store layout and the root-input faces
```

New:

```text
The fingerprint is the store layout and the root-input faces
```

### 13. P2-2 / RP-8, unit F

Old:

```text
bit-identity claim ([§12.7][s12-7]).
```

New:

```text
bit-identity claim ([§2.4][s2-4], [§12.7][s12-7]).
```

### 14. P2-10, unit F

Old:

```text
"given the initial state and the trace, the log is recomputable" requires.
```

New:

```text
"given the initial state and the trace, the log is recomputable" (below) requires.
```

### 15. P2-11, unit F

Old:

```text
by the door that builds the run, and never again
```

New:

```text
by the door that builds the run (`init!`, `restore!` or `replay!`, [§12.6][s12-6]), and never again
```

### 16. P2-3 / RP-9, unit F

Old:

```text
(the framework-owned write path of the calling task)
```

New:

```text
(the framework-owned write path `stage!(sim, …)`)
```

### 17. P2-13, unit G1

Old:

```text
A batch staged there would land in a staging cell, and no [drain](#g-drain) (the frame-top swap that applies staged device writes to the root inputs) reads that cell. A report would land in a [diagnostic cell](#g-diagnostic-cell) (each writer's bounded ring of diagnostics and its heartbeat). No [frame](#g-frame) top (the start of one loop iteration) folds that cell.
```

New:

```text
A [batch](#g-batch) staged there would land in a [staging cell](#g-staging-cell) that no [drain](#g-drain) reads. A report would land in a [diagnostic cell](#g-diagnostic-cell) that no [frame](#g-frame) top folds. A batch is a device's staged set of writes. A staging cell is the per-device holding place where a pending batch waits between drains. The drain is the frame-top swap that applies staged device writes to the root inputs. A diagnostic cell is each writer's bounded ring of diagnostics and its heartbeat. A frame is one iteration of the loop.
```

### 18. P2-14, unit G1

Old:

```text
A device is a user type subtyping the framework's neutral root,
```

New:

```text
A device's type is a user type subtyping the framework's neutral root,
```

Keeps "a user type", which the pass's text dropped.

### 19. P2-5 / RP-11, unit G1

Old:

```text
**Only `loop` is mandatory** ([D-366][d-366]).
```

New:

```text
**Of the four functions, only `loop` is mandatory** ([D-366][d-366]).
```

### 20. P2-17, unit G1

Old:

```text
and `UDPInput` is FlightCore's UDP input device type.
```

New:

```text
and `UDPInput` is FlightCore's UDP input device type. `Telemetry` is an illustrative output device type.
```

### 21. P2-1, unit G1

Old:

```text
A window ✕ or peer EOT is the loop body returning. The wrapper's exit path
```

New:

```text
A window ✕ or peer EOT is the loop body returning, which is [§12.4][s12-4](6)'s case. The wrapper's exit path
```

### 22. P2-1, unit G1

Old:

```text
persist to run end (the freeze, [§11.3][s11-3], [D-106][d-106]). This is [§12.4][s12-4](6)'s case. The GUI implements
```

New:

```text
persist to run end (the freeze, [§11.3][s11-3], [D-106][d-106]). The GUI implements
```

### 23. P2-16, unit G1

Old:

```text
**`should_abort` is an `attach!` keyword**
```

New:

```text
#### The failure policy

**`should_abort` is an `attach!` keyword**
```

### 24. P2-15, unit G2

Old:

```text
so silence is not greediness ([D-177][d-177]). The computed claim source is declared or absent.
```

New:

```text
so silence is not greediness ([D-177][d-177]). A [greedy claim](#g-greedy-claim) is the unclaimed complement computed at attach. The computed claim source (the greedy one, [§11.3][s11-3]) is declared or absent.
```

### 25. P2-15, unit G2

Old:

```text
nothing tells a [greedy claim](#g-greedy-claim) (the unclaimed complement computed at attach) from a returned one ([§11.3][s11-3]).
```

New:

```text
nothing tells a greedy claim from a returned one ([§11.3][s11-3]).
```

### 26. P2-4 / RP-10, unit G2

Old:

```text
It is the same kind of reflection check as §8.1's shadowing check, an `isdefined`/`!==` pair ([§8.1][s8-1]).
```

New:

```text
It is a reflection check like the shadowing check of [§8.1][s8-1], an `isdefined`/`!==` pair.
```

### 27. P2-6, unit H

Old:

```text
[root input](#g-root-input) (the only thing the periphery may write)
```

New:

```text
[root input](#g-root-input) (the root component's own input face)
```

Singular "face", the glossary's own wording, since the term here is singular.

### 28. P2-29 / RP-13, unit H

Old:

```text
**Widgets, however, name the component's own ports, never root inputs** ([D-026][d-026]).
```

New:

```text
However, **widgets name the component's own ports, never root inputs** ([D-026][d-026]).
```

### 29. P2-6, unit H

Old:

```text
[claim](#g-claim) (the set of root inputs a device *may* write)
```

New:

```text
[claim](#g-claim) (the set of faces a device *may* write)
```

### 30. P2-18, unit H

Old:

```text
is therefore automatic. At build time it follows the wiring archetype, where a scripted `World` (the example assembly of pure composition that [§8.8][s8-8] introduces) wires a
```

New:

```text
is therefore automatic. `World` is the example assembly of pure composition that [§8.8][s8-8] introduces. At build time the switch follows the wiring archetype, where a scripted `World` wires a
```

### 31. P2-19, unit H

Old:

```text
renders the fact in its source label ("claimed by `T16000M` — task dead", where `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick), the heartbeat surfaced in place ([§12.2][s12-2]).
```

New:

```text
renders the fact in its source label, such as "claimed by `T16000M` — task dead". `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick. The heartbeat is surfaced in place ([§12.2][s12-2]).
```

### 32. P2-20, unit H

Old:

```text
What stays deferred is the GUI package's half (`pending.md`, which records what the implementation still owes and the questions the design leaves open), which the built-in GUI's parking ([D-310][d-310]) assigns to the browser client over the bridge.
```

New:

```text
The GUI package's half stays deferred, and `pending.md` (the record of what the implementation still owes) tracks it. The built-in GUI's parking ([D-310][d-310]) assigns it to the browser client over the bridge. The bridge is the link to the simulation, and [D-310][d-310] leaves its design open.
```

The bridge's gloss is split into its own sentence: the pass's "the link to the simulation whose design D-310 leaves open" lets "whose" bind to "the simulation". D-310 Position: "is what the bridge serves"; "ruled with the bridge's design".

### 33. P2-22, unit J

Old:

```text
[harness writer](#g-harness-writer) (the framework-owned write path `stage!(sim, …)`) ([D-200][d-200]).
```

New:

```text
[harness writer](#g-harness-writer) (the framework-owned write path `stage!(sim, …)`, [D-200][d-200]).
```

### 34. P2-23, unit J

Old:

```text
(the list of attached device entries, [§11.3][s11-3])
```

New:

```text
(the list of attached devices, [§11.3][s11-3])
```

### 35. P2-22, unit J

Old:

```text
so the new roster entry's diagnostic cell has no other writer yet.
```

New:

```text
so the new roster entry's [diagnostic cell](#g-diagnostic-cell) (a writer's own holding place for runtime diagnostics) has no other writer yet.
```

### 36. P2-22, unit J

Old:

```text
**Each writer has one [diagnostic cell](#g-diagnostic-cell)** (its own holding place for runtime diagnostics) ([D-136][d-136], [D-200][d-200]).
```

New:

```text
**Each writer has one diagnostic cell** ([D-136][d-136], [D-200][d-200]).
```

### 37. P2-21, unit J

Old:

```text
of what the ring could not hold ([D-136][d-136]).
```

New:

```text
of what the ring could not hold ([D-136][d-136]). The rejected alternatives are in [D-136][d-136].
```

The pass says both "the end of 'One diagnostic cell per writer'" and "after L1771" (mid-section). The pointer goes at the section's end.

### 38. P2-28, unit J

Old:

```text
Presentation is where `maxlog` lives.
```

New:

```text
Presentation is where `maxlog`, the cap Julia's logging macros put on repeats, lives.
```

### 39. P2-21, unit J

Old:

```text
The [log](#g-log) (the retained sequence of published snapshots) retains snapshot references ([§11.2][s11-2]), so `totals` is monotone across logged snapshots. So `log_every` [decimation](#g-decimation) (the log's keep-every-kth retention policy) loses *which* boundary within a skipped stretch an occurrence fell on, never *how many* occurrences there were. [D-136][d-136] lists the rejected alternatives.
```

New:

```text
Because the [log](#g-log) (the retained sequence of published snapshots) retains snapshot references ([§11.2][s11-2]), `totals` is monotone across logged snapshots. `log_every` [decimation](#g-decimation) (the log's keep-every-kth retention policy) therefore loses *which* boundary within a skipped stretch an occurrence fell on, never *how many* occurrences there were.
```

### 40. P2-25 / RP-12, unit G1

Inside the wrapper sketch's fenced block. The one comment line becomes two, both with the `#` at column 46 (45 spaces before it).

Old:

```text
                                             # no dead-marking: task_state shows the end, claims stay, §11.3
```

New:

```text
                                             # no dead-marking: task_state shows the end,
                                             # claims stay, §11.3
```

### 41. P2-26 and P2-21 (underfilled lines), and the J verifier's three long lines; units F, G1, G2, H, J

Every prose paragraph and bullet item in the five units was refilled
greedily to at most 80 rendered columns. Link markup is collapsed, every
other character is counted, asterisks and backticks included. A bullet's
continuation lines keep a two-space indent. Fenced blocks, table rows,
headings and the closing `---` were not touched. A reference-style citation
(`[§12.4][s12-4]`, `[Appendix C][sC]`) and an inline code span are never
split across lines. Glossary links may be split, as the rest of the spec
does. No line starts with a token that Markdown would read as a list marker
or heading.

To verify, take each unit's normalized text (`show-new`). It is identical
before and after the rewrap, paragraph by paragraph. Its fenced blocks,
headings and table rows are byte-identical. The widest prose line in each
unit is now 80 rendered columns. The named lines (L1031, L1324, L1534,
L1539, L1554, L1559, L1574, L1586, L1631, L1705, L1865, and J's three) are
gone, and so are the underfilled ones (L1132, L1372, L1489, L1633, L1749,
L1872, L1882, L1919, L1921).

### 42. P2-12 (follow-up), unit F

Fixes an antecedent. After edit 4, the face and component glosses stand between the recording and "That". This edit came after the rewrap, so the paragraph was refilled again, whitespace only.

Old:

```text
A component is the unit of modeling, a leaf or an assembly. That is an O(surface-width) scan
```

New:

```text
A component is the unit of modeling, a leaf or an assembly. The recording is an O(surface-width) scan
```

## Inventory changes

- F: C-007 (now the drain's R13 gloss sentence), C-008, C-010, C-011,
  C-012, C-025, C-028, C-033, C-034, C-039 (R17), C-040 (now maps to the
  checkpoint list's "the fingerprint (the structural layout) and the
  deployment"), C-043, C-051 (tag C, newcites §12.6), C-059 (tag R, RP-9),
  C-063 (tag R, RP-8, newcites §2.4 and §12.7), C-066. `added` loses the
  claim, component and binding glosses, the old harness-writer gloss and
  the bare greedy-claim sentence. It gains the drain and component
  sentences, the claim gloss, the binding appositive, "(the structural
  layout)", ", a `Simulation` field", the doors' parenthetical and
  "(below) requires".
- G1: G1-010, G1-011, G1-026, G1-033 (ruling "R21, RP-12"), G1-068,
  G1-071. In `added`, RP-11's bold sentence is updated. The three old
  parenthetical glosses are dropped. The five gloss sentences, the
  `Telemetry` sentence and "#### The failure policy" are new. RP-11's
  sentence has no claim of its own: it was R22's addition.
- G2: C-011 (tag C, newcites §11.3), C-037 (ruling "R10, RP-10"), C-061.
  `added` gains the greedy-claim sentence and "(the greedy one, §11.3)".
  It loses the old parenthetical gloss.
- H: C-003 (tag R, RP-13), C-006, C-031, C-059, C-092. In `added`, the
  context sentence is updated. Four glosses are swapped for the new
  `World`, `T16000M`, ", such as", `pending.md` and bridge wording.
- J: C-005, C-009, C-011, C-015, C-058, C-089, C-090, C-091 (now "The
  rejected alternatives are in D-136."). In `added`, the harness-writer and
  roster glosses are updated, the diagnostic cell's gloss is replaced, and
  the `maxlog` gloss is new.

## Declined

- **P2-24, both parts** (units F and J). The pass marks it optional, and
  each cut removes a stated claim from its section: "the state trajectory
  included" in §11.5, and "That way the framework observes activity without
  owning the loop body" in §11.8. R5 governs overlaps across the split and
  did not rule these two. The inventory would also have to map the cut
  claim into another unit's file. §11.2's file, unit B, is under a
  concurrent edit. That makes it a ruling for the orchestrator.

## Applied with a note

- **P2-9** (F). Glossing "fingerprint" at L1016 moves R17's "(the
  structural layout)" out of the compared-parts sentence, which keeps R17's
  other words. The dropped sentence "The header carries the run's
  `Deployment` and the structural layout" was a restatement. Its claim,
  C-040, now maps to the checkpoint list.
- **P2-12** (F). The pass also notes that "boundary" appears in its
  structural sense in the face gloss before its consistency-point link at
  L995. It gives no fix for that, so it is unchanged.
- **P2-15** (G2). "a returned one" stays unglossed. The pass names the
  problem but gives no text.
- **P2-11** (F). The new parenthetical says the header is written by
  `init!`, `restore!` or `replay!`. §12.6 (frozen spec, 9047 and 9055)
  names these as the doors that construct a `Run`.
- **RP-9** (F). The glossary's harness-writer entry changes at landing,
  not here.
