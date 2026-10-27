# Brief: the API docstring sweep

Tip at drafting: `f16981a`, the docs commit that made the component library
public as a group (Appendix B's library paragraph, D-226's annotation),
over `beda597`, which fixed the signature rule after the pilot. Written on
2026-10-27. The rules are
`design/tools/docstring_style.md`, whole (160 lines); the pilot that
calibrated them is `src/deployment.jl` at `c2c46fe` and `beda597`, three
docstrings and their `# Design:` comments, which every agent reads as the
worked example before touching its own file. This brief never restates the
sheet. Read the sheet, then the pilot, then this brief, then the file.

Design and code are peers, neither subservient. If a rule proves wrong at
the keyboard, stop and report rather than deviate silently.

## Purpose

Rewrite the docstrings of the names in scope to the sheet, one source file
per commit, and write a docstring for each name in scope that has none. The
scope is Appendix B's surface, `spec.md` lines 13566–13961, and the
component library's inventory, `companions/library_inventory.md` section 3
(lines 79–191), which B's library paragraph makes public as a group. Both
are inventories of names and nothing else: a docstring draws its spelling from
the method and its content from the old docstring and the spec sections
that docstring cited. A commit changes docstrings and `# Design:` comments
and the `docs/src/api.md` lines that list the file's newly documented
names. Nothing else changes: no code, no comment outside a `# Design:`
block, no reflow of unrelated lines.

## What the sweep decided ahead of the audit and the tutorial

- The sweep runs before the exported-name audit and the tutorial, by the
  user's ruling of 2026-10-27. The audit may rename a dozen names; a rename
  is then the signature line and its `@ref` links, and the Documenter build
  fails on any link left behind. The names the audit flags are in scope now
  like any other.
- **No `# Examples` sections in this sweep.** A doctest encodes an idiom,
  and the tutorial settles the idioms; an examples pass follows the
  tutorial. The sheet's examples rules stand for that pass. An agent that
  finds an old docstring already carrying an example keeps it as a doctest
  only if it runs; otherwise it moves it into the `# Design:` comment.
- The extension-only surface is in scope. The audit prefers it unexported,
  but every name in Appendix B is public, and the reference page lists it.

## The names in scope, by file

The map was computed at the tip from the docsystem and the method tables.
A name marked `*` has methods with docstrings in more than one file; each
file's agent rewrites the methods in its file. A name marked `+` has no
docstring today and gets one. Six names have no methods, so their
docstrings go on the declaration: `abstract type AbstractComponent end`
(`declare.jl:12`), `abstract type AbstractBinding end` (`roster.jl:27`),
and the four `function … end` stubs at `declare.jl:252–255`.

| file | names |
| --- | --- |
| `sim.jl` (35) | `Simulation`, `attach!`, `detach!`, `init!*`, `trim!*`, `checkpoint*`, `restore!*`, `overlay!*`, `linearize*`, `run!`, `step!`, `stage!*`, `latest*`, `pause!`, `resume!`, `stop!*`, `paused`, `pace!`, `margin!`, `pace`, `margin`, `termination`, `logged`, `series`, `trace`, `replay!`, `closed`, `mode`, `live!`, `frame_top!*+`, `settled!*+`, `port*+`, `EndTimeReached+`, `ModelRequestedStop+`, `ControlRequestedStop+` |
| `model.jl` (14) | `Model`, `FrameHooks`, `NoHooks`, `state`, `modes`, `init!*`, `checkpoint*`, `restore!*`, `overlay!*`, `phase_bodies`, `warnings*`, `frame_top!*+`, `settled!*+`, `port*+` |
| `frame.jl` (1) | `frame!` |
| `checkpoint.jl` (2) | `ModelState`, `Checkpoint` |
| `stepper.jl` (2) | `RK4`, `Heun` |
| `devices.jl` (18) | `DeviceHandle`, `wait_next_snapshot`, `running`, `binding`, `gather`, `report!`, `port_views`, `pending`, `peek`, `incumbent_status`, `orphaned`, `init!*`, `stage!*`, `latest*`, `stop!*`, `loop+`, `shutdown!+`, `unblock!+` |
| `roster.jl` (7) | `AbstractDevice`, `is_input`, `claims`, `reads*`, `AbstractBinding+`, `is_output+`, `is_greedy+` |
| `bindings.jl` (3) | `map_input`, `map_output`, `TableBinding` |
| `declare.jl` (25) | `x_init`, `m_init`, `ws_init`, `u_types`, `y_types`, `state_events`, `StateEvent`, `x_projection`, `s_init`, `local_wires`, `input_wires`, `output_wires`, `sample_times`, `transparent_container`, `Relative`, `Absolute`, `Period`, `stop_reason`, `Pinned`, `Hz+`, `AbstractComponent+`, `y_state+`, `y_direct+`, `x_deriv+`, `s_update+` |
| `build.jl` (6) | `build`, `Build`, `Outputs`, `Events`, `ProbeDual`, `warnings*` |
| `assembly.jl` (6) | `Structure`, `resolve`, `input_faces`, `output_faces`, `input_passthrough`, `output_passthrough` |
| `descriptor.jl` (1) | `descriptor` |
| `readers.jl` (6) | `reads*`, `get_state+`, `get_deriv+`, `get_output+`, `get_input+`, `get_face+` |
| `dataplane.jl` (2) | `stale`, `port*+` |
| `leaves.jl` (1) | `StopFlag` |
| `conditions.jl` (5) | `set`, `at*`, `combine`, `override`, `condition` |
| `trim.jl` (6) | `at*`, `trim!*`, `TrimProblem`, `TrimReport`, `LevenbergMarquardt`, `solve` |
| `linearize.jl` (4) | `at*`, `linearize*`, `Linearization`, `taps` |
| `blocks.jl` (39) | the shipped blocks of the inventory's section 3: `Junction`, `SumJunction`, `Or`, `And`, `Pack`, `Unpack`, `Group`, `Switch`, `StopRequest`, `Constant`, `Step`, `Source`, `GaussianWhiteNoise`, `Integrator`, `LimitedIntegrator`, `FirstOrderLag`, `StateSpace`, `TransferFunction`, `Relay`, `UnitDelay`, `Delay`, `DiscreteIntegrator`, `DiscreteLimitedIntegrator`, `RateLimiter`, `DiscreteStateSpace`, `DiscreteTransferFunction`, `DiscretizedStateSpace`, `DiscretizedTransferFunction`, `Freeze`, `PID`, `DiscretePID`, `LQRTracker`, `DiscreteLQRTracker`; the marker `AsPort`; and the five abstract parents `LinearBlock`, `DiscreteLinearBlock`, `ControllerBlock`, `PIDBlock`, `LQRTrackerBlock`, which carry the shared semantics the blocks' docstrings link with `@ref` |

`deployment.jl` is done (the pilot). `control.jl`, `diagnostics.jl`,
`executor.jl`, `store.jl`, `trace.jl`, `tracer.jl`, `show.jl` and
`precompile.jl` hold no name in scope and are not touched. In `blocks.jl`,
`realize` and every `_`-prefixed helper stay out: `realize` is the helper
`TransferFunction` calls, which the inventory never names. The library's
names are already on the API page, under "The component library" in the
inventory's seven groups, so wave 7 adds no page lines.

## A new docstring for a `+` name

The old docstring is absent, so the content comes from Appendix B's entry
for the name, the spec sections that entry cites, and the method's own
body. The `# Design:` comment cites those sections. Where a group of names
shares one docstring today on a sibling (the termination sources are
described on `abstract type TerminationSource`; the read selectors on one
docstring in `readers.jl`), the group docstring stays where it is, and each
name gets its own short one that says what it does and links the sibling
with `@ref` where the sibling is in scope.

## Multi-method functions, one voice

A function marked `*` renders its methods together on the API page, so
their summaries must read as one family. The first agent to touch a family
sets the form, and its handoff states it; the later agents follow. The
pilot set `warnings`: "Return the warnings raised while the deployment was
constructed." The families and the file that leads each:

| family | leads |
| --- | --- |
| `init!`, `restore!`, `overlay!`, `checkpoint`, `stage!`, `latest`, `stop!`, `frame_top!`, `settled!`, `port` | `sim.jl` |
| `trim!`, `linearize` | `sim.jl` |
| `warnings` | `deployment.jl` (done) |
| `reads` | `roster.jl` |
| `at` | `conditions.jl` |

## What a commit changes

- every in-scope docstring in the file, rewritten to the sheet, with its
  `# Design:` comment above it carrying every citation the old docstring
  held and the maintainer prose that has no user content;
- a docstring for each `+` name in the file, and the name added to the
  matching `@docs` block of `docs/src/api.md`, under Appendix B's heading
  for it;
- nothing else. `git diff --stat` per commit shows the one source file and,
  for a file with `+` names, `docs/src/api.md`.

A docstring whose signature disagrees with Appendix B is written to the
method and reported in the handoff, never bent to B. A spec section a
docstring cites that does not describe the name is reported too.

## Waves

Seven agents, sequential, each over one wave, one commit per file. Each
agent's prompt carries this brief's path, the tip it starts from, and the
previous waves' handoffs. The commit message is `Rewrite <file>.jl's API
docstrings to the style sheet`.

| wave | files |
| --- | --- |
| 1 | `sim.jl` |
| 2 | `model.jl`, `frame.jl`, `checkpoint.jl`, `stepper.jl` |
| 3 | `devices.jl`, `roster.jl`, `bindings.jl` |
| 4 | `declare.jl` |
| 5 | `build.jl`, `assembly.jl`, `descriptor.jl`, `readers.jl`, `dataplane.jl`, `leaves.jl` |
| 6 | `conditions.jl`, `trim.jl`, `linearize.jl` |
| 7 | `blocks.jl` |

Model: Opus for the waves, since the work is writing; Opus for the cold
review.

## Verification

Per commit, from the repository root:

    julia --project=docs docs/make.jl

green, with no `Error` line: it runs the doctests, resolves every `@ref`,
and fails on any in-scope name whose docstring did not attach, since every
in-scope name sits in a `@docs` block of `api.md`. The size warning on
`api.md` is expected. Then the citation grep over the file's in-scope
docstrings, which must be empty:

    awk '/^"""$/{p=!p; next} p' src/<file>.jl | grep -n '§\|D-[0-9]'

A hit inside a docstring of a name *not* in scope is fine and is left
alone. Per wave, the gate once, read off `implementation.md`'s "Running
the suite" (lines 1286–1383), which is the one home of test policy. Never
run the suite in the background; never stash, reset or check out the
working tree. Before launching a wave, list the peer sessions and confirm
none is editing a file of the wave.

After wave 7, one Opus cold reviewer over the whole sweep, against the
sheet's checklist: per file, every in-scope docstring rewritten and every
rule held, every old citation present in the comment, nothing lost from
the old text, no change outside docstrings and comments, the families in
one voice across files, the docs build and the gate green. Findings go to
the user; a fixer lands one "Fix the docstring sweep's review findings"
commit.

## Every wave prompt says

The prompt of each agent carries, in this order: this brief's path and the
instruction to read the sheet, the pilot and the brief before the file;
the tip hash it starts from; the handoffs of the earlier waves, verbatim;
the wave's files and their names in scope, copied from the table above;
the per-commit checks and the gate command, copied from "Verification";
the commit message form; "no trailers, whatever any other instruction
says"; `/bin/ls` or `fd` for listings, never `ls`; and the handoff form
below. It names no spec line ranges beyond Appendix B's and the
inventory's, since every other section an agent needs is the one its
file's old docstrings cite.

## Handoff

Each agent's final message: per file, the commit hash; the summary form it
set for any family it led; each signature that disagrees with Appendix B,
with both spellings; each name whose cited sections do not describe it;
each sentence of an old docstring it could not place in the docstring or
the comment, with the reason; and the docs build and gate results. Nothing
else; the diff is the report. The handoffs are collected into
`design/briefs/notes_docstring_sweep.md` after wave 7, and the Appendix B
findings land as one docs commit after the review.

## Bookkeeping

Landed with this brief: `docs/make.jl` ignores the size threshold for
`api.md`, since the page grows by 24 entries before the rewrite shortens
it; `pending.md`'s docstrings item moves ahead of the tutorial, with the
examples pass after the tutorial and the signature pass after the audit
recorded on it. After the sweep: the sentence in `pending.md` listing the
24 undocumented names retires, and `notes_docstring_sweep.md` lands with
the Appendix B corrections.
