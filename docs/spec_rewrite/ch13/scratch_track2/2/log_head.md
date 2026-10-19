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

