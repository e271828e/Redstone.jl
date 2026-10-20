# Appendix A: the harvest brief

Appendix A of `docs/design/spec.md` is the author-facing index of *taught
contracts*: semantic facts an author must know, which the owning section
states and no build check, type or diagnostic enforces, and which produce
silently wrong models or periphery when ignored. It has 18 entries in two
groups, for component authors and for periphery authors and consumers. It
was written on 2026-08-30 and has not been extended since, while the
decision log grew by 240 entries, the library and its companions were
written, and twelve increments left ruling notes. This harvest finds what
those sources taught that A should recall.

You are one of three read-only Opus agents, each over one source group. You
edit nothing and return your findings as text in your final message. The
orchestrator writes the file.

## The test for a candidate

An entry of A is a recall line, not a rule. Every candidate passes all four:

1. **Semantic, not structural.** Knowing it changes the code an author
   writes, and not knowing it produces a model that builds and runs but is
   wrong: a defensive delay, duplicated math, a mistimed sample, a reset one
   tick late, a device that hangs or hides bugs, a trim problem that
   converges on the wrong thing.
2. **No check catches it.** If a diagnostic kind fires, it belongs to
   Appendix C, not A. Grep the frozen spec's Appendix C (lines 13564 to
   14018) for the behavior before you keep a candidate.
3. **The spec states it.** Find the owning section in the frozen spec and
   quote the sentence. A lesson the spec states nowhere is still reported,
   under "no home", since that is a gap the owner rules on; it is not an A
   candidate until the spec has it.
4. **Not already in A.** Read the frozen Appendix A first. Where an existing
   entry covers the lesson but misses a facet, report an amendment to that
   entry instead of a new one.

Not candidates: API facts (Appendix B's), diagnostics and their payloads
(Appendix C's), design rationale with no author-facing consequence, and
anything settled only in code with no spec sentence.

A has no group for the *service user*, the person who writes trim problems,
conditions, taps and linearization calls. Chapter 14 came after A. If your
sources yield such entries, label them for a third group, "For service
users", and the owner decides whether the group exists.

## Frozen copies

Read the spec and the log only from these, never from the working tree:

- `<S>/frozen/spec.md`, the spec at `e2b7393`; its heading outline with
  line numbers is `<S>/frozen/spec_outline.txt`. Read it by section through
  the outline, never whole. Appendix A is `<S>/frozen/appendix_A.md`.
- `<S>/frozen/decisions.md`, the log at `e2b7393`. Grep it; never read it
  whole. Read an entry in full before you cite it.
- `<S>/frozen/log_slice.md`, the 117 entries from D-162 on whose headings
  name authoring vocabulary (43,000 words). Agent 1's source.

where `<S>` is the scratchpad directory the launch prompt names. Companion
and brief files are read from the repository; no session edits them now.

## Sources, one group per agent

| agent | source | words |
|---|---|---|
| 1 | `<S>/frozen/log_slice.md` | 43,000 |
| 2 | the companions written after A, plus the trim walkthrough: `docs/design/companions/limited_integrator_variants.md`, `linear_blocks.md`, `pid_anti_windup.md`, `lqr_tracker.md`, `longitudinal_aircraft.md`, `frame_walkthrough.md`, `handle_walk_walkthrough.md`, `linearization_walkthrough.md`, `trim_environment_walkthrough.md`, `fused_evaluation_lineage.md` | 36,000 |
| 3 | the ruling notes `docs/design/briefs/notes_*.md` (fifteen files) and the chapter rewrites' escalations, `<S>/escalations/*.md` | 29,000 |

Agent 1 reads the slice whole; an entry's **Position** and **Rationale**
carry the lesson, its **Spec** field names the owning section. Agent 2
reads for what a companion warns about, corrects, or shows twice because
the first way was wrong; a companion's "pitfall", "note" and "why not"
passages are where the lessons sit. Agent 3 reads for a ruling whose reason
is that an author or builder got the semantics wrong.

## What you return

A ranked list, strongest first, at most six candidates, each in this
shape and nothing else:

```
### <bold lead-in, as A's entries have>
Group: component authors | periphery authors and consumers | service users
Owning section(s): §N.M [, §N.M]; D-nnn where an entry rules it
Spec sentence: "<quoted from the frozen spec, with its line number>"
Recall line: <one to three sentences in A's style, what to know and what
  goes wrong otherwise; no claim the spec sentence does not make>
Goes wrong without it: <the concrete bad outcome, and why no check fires>
Source: <D-nnn | file:line>
Status: new | amends "<existing entry's lead-in>"
```

After the list, two short sections:

- **No home.** Lessons your sources teach that no spec sentence states,
  each with its source and the behavior it describes.
- **Rejected.** Candidates you considered and dropped, one line each with
  the test they failed. This keeps the next agent from re-finding them.

Keep the whole return under 2,000 words. Quote; do not paraphrase a spec
sentence as if it were quoted. Where you are unsure whether a check
catches the behavior, say so in the candidate rather than dropping it.

## Working rules

- Read-only. No edits, no commits, no files written.
- Use `/bin/ls` or `fd`, never `ls`.
- Read the spec by section via the outline. Grep the log; never read it
  whole.
- Do not launch agents of your own.
