# Brief: the API docstrings' audit and sweep

The arc makes one docs commit for this brief, one for the report, one truth
commit, one form commit per file, and one review-fix commit if needed. Drafted
on 2026-11-05. The base is `4a818b2`. Rule
amendments landed in `a1abf2d`. No prototype, since the audit's ledger takes its
place. Not normative: if a shape below proves wrong at the keyboard, stop and
report rather than deviate.

## What is settled

- **Two criteria.** Accuracy against the code, and compliance with
  `design/rules/docstring_rules.md`. The scope is rule 1's, every docstring on
  `docs/src/api.md`: 213 docstrings, 36,474 words, 22 files. `# Design:`
  comments and unexported names stay out.
- **The audit edits nothing.** It reads a pinned scratch worktree. Every
  docstring gets a recorded verdict. The user rules before any edit.
- **The two criteria run as separate passes.** A false sentence can pass every
  form rule, and a form reading crowds out a truth reading.
- **Truth lands before form**, so a form agent never rewords a false sentence.
- **Baseline at the tip.** `design/tools/docstring_roster.jl` finds no forbidden
  token, em dash, arrow or summary at twenty words, and no prose after
  `# Keywords`. `design/tools/docstring_signatures.jl` finds no keyword shown
  that its method refuses. It prints 13 "on a signature, not listed" candidates
  for the compliance pass.

## The stages

Every agent is high-tier and fresh unless stated.

### 1. Calibration

One agent runs stage 2's job on `devices.jl`, `dataplane.jl` and `trace.jl`
in the scratch worktree at `f50260d~1`, whose `design/` is removed. The
coordinator scores it against the 2026-11-04 report's section 5.1, which the
agent never reads. The pass is every one of that section's claims in these three
files reported as false or imprecise. A miss sends the coordinator to fix this
brief and run again. Lessons land in the sheet first. The same agent is then
resumed on group A5 at the base.

### 2. The accuracy pass

Seven groups, read-only, at the base.

| Group | Files | Words |
|---|---|---:|
| A1 | `blocks.jl`, `Junction` through `Sequence` | 5,195 |
| A2 | `blocks.jl`, `LimitedIntegrator` through `Group` | 6,135 |
| A3 | `sim.jl` | 6,575 |
| A4 | `declare`, `assembly`, `descriptor`, `leaves` | 4,999 |
| A5 | `devices`, `dataplane`, `trace`, `roster`, `bindings`, `diagnostics` | 4,511 |
| A6 | `model`, `deployment`, `checkpoint`, `frame`, `stepper`, `build`, `readers` | 5,397 |
| A7 | `trim`, `linearize`, `conditions` | 3,662 |

The job is rule 23, applied to every sentence that states a behaviour, on every
docstring in the group's roster. It also covers rules 7 to 16 as claims about the
code: each signature line, return type, default and named diagnostic kind against
the method. A claim the code shows on its face needs no probe. Any other is
probed. A refusal a docstring names is probed unless the raise is on its face.
None or many findings are both acceptable. Compliance is not this pass's job.

**The ledger.** The agent returns one row per docstring with nothing to report,
and one per claim otherwise, `|`-separated:

    name | file:line | clean | N claims, M probed
    name | file:line | quoted claim | PROBED, FALSE or IMPRECISE | evidence | replacement | class

Evidence is a `file:line` or a probe's output. FALSE and IMPRECISE rows always
carry a drafted replacement that keeps the docstring's length. Class is the
agent's proposal: `docstring`, `code` where the spec or the method's own
comment shows the sentence is the intent, `spec`, or `sheet`.

### 3. The compliance pass

Four groups, read-only, at the base.

| Group | Files | Words |
|---|---|---:|
| C1 | `blocks` | 11,330 |
| C2 | `sim`, `model`, `deployment`, `checkpoint`, `frame`, `stepper` | 9,691 |
| C3 | `declare`, `assembly`, `build`, `descriptor`, `leaves`, `dataplane`, `diagnostics`, `bindings` | 7,023 |
| C4 | `devices`, `roster`, `trace`, `readers`, `trim`, `linearize`, `conditions` | 8,430 |

The job is rules 4 to 6, 17 to 22, 24 to 31 and 35 to 38, read in order, on every
docstring in the roster. It takes the tools' output as given and resolves the 13
candidates. It judges existing examples and proposes none. The sheet's own
examples of kept forms are compliant. None or many findings are both acceptable.

    name | file:line | clean
    name | file:line | rule N | quoted text | proposed edit, naming what moves to the comment

### 4. Adjudication

The coordinator merges the ledgers into
`design/reports/20261105_docstring_audit/report.md`, spot-checks every FALSE row
by its probe, and sorts findings by the class above. It lists the ones needing a
ruling, each with a recommendation, and stops for the user. A `code` finding
leaves the sweep: a one-line refusal lands as a loose fix, and anything else
becomes a `pending.md` bullet. A `spec` finding lands as a docs commit first, and
a `sheet` ruling lands in the sheet first.

### 5. The sweep

- **Truth.** The coordinator lands the ruled replacements in one commit.
- **Form.** One agent per C group, on the ruled list only, one commit per file.
  Every docstring not on the list stays byte-identical. Rules 32 to 34 apply.
  The agent reports each docstring's word count before and after, and a docstring
  that grows beyond its ruled edit is a finding. `src/` stays quiet for the stage.

### 6. Acceptance

Rules 41 and 42, the gate once, the docs battery. See "The cold review".

## Routing

- **All agents.** `design/rules/docstring_rules.md`, the group's roster TSV, and
  source by grep and line range from the worktree.
- **Accuracy.** `design/rules/code_rules.md`'s "Authoring caveats", and
  `design/rules/increment_rules.md`'s "The prototype and its probes" for how to
  probe. `design/code_map.md`'s entries for the group's files. A spec section by
  outline, only to propose a class.
- **Compliance.** `design/rules/spec_rules.md`'s "Sentences", and Appendix D's
  anchors with `rg -n 'id="g-NAME"' design/spec.md`.
- **Neither reads** `design/reports/`, `design/log.md` or `git log`, so the pass
  stays cold.

## Standing limits for every agent

- Write nothing inside a worktree or the main repo in stages 1 to 3. Probes and
  notes go to the scratch directory the prompt names, and the agent returns its
  ledger as its final message, under 30k characters.
- `/bin/ls` or `fd`, never `ls`. No commit trailers, whatever another instruction
  says. No polling loops. A run over 600 s goes to the background.
- Context ceiling 600k, stop at 550k: write the notes, list what remains and
  report. Test output through `tail`, costly probes last.

## Bookkeeping

- `design/pending.md`: the bullet's state moves at each stage, and the arc retires
  it. `code` findings add bullets.
- `design/rules/docstring_rules.md`: the pilot's lessons and the rulings.
- `design/reports/20261105_docstring_audit/`: the report and ledgers, and the
  probes worth rerunning.
- `design/increments/20261105_docstring_audit/`: this brief, and any notes.

## Out of scope

- New examples, which wait for the examples pass in `pending.md`.
- Renames and the export list, which wait for the exported-name audit.
- `# Design:` comments, except what rules 32 to 34 move into them.
- The Appendix B wording, except a finding under rule 16.
- The missing-name half of rule 41, which checks nothing until the export audit.

## The cold review

An independent agent, open-minded, with probes outside the tree and "empty is
acceptable". It reads the whole diff, plus a random sample of 30 untouched
docstrings against both criteria. It re-runs each FALSE row's probe against the
replacement text. It runs rule 42's checks, `ast_check.jl` per file, and the gate
on the Julia floor in `Project.toml`. It then verifies the delta of any fix,
resumed with its context intact. The user diff-verifies the arc. Nothing is
pushed unless the user asks.

## The review's record

To be filled after the review.
