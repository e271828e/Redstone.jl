# Increment rules

How a unit of work on this repo is built, from prototype to push: an
increment of the code, a docs sweep or an audit alike. A coordinating
session runs the pipeline; the agents it launches do the large builds and
every review. Stages run back to back with no review between them, and
the pipeline stops only for a design decision. The brief's rules are
`brief_rules.md`; the code's are `code_rules.md`.

## The pipeline

1. **Prototype first.** A high-tier agent prototypes the whole increment
   in a scratch worktree, by the rules below. Its report states each
   reading on an unruled seam in one form: the seam, the reading taken,
   the alternative rejected, the probe behind the choice, and the hunks
   that change under the alternative.
2. **The readings round.** The coordinator puts the readings to the user
   in one message, with recommendations. The checks a round of rulings
   asks for go to the prototyper in one message, resumed with its context
   intact, and come back as a verdict and a figure each, never a log. A
   ruling that changes the shape goes the same way: the prototyper revises
   the worktree and runs the gate again. The coordinator checks nothing
   itself beyond a grep and never edits the prototype. Each ruling enters
   the increment's notes file as it is made, with its reason.
3. **The brief, once.** The coordinator drafts the brief from the settled
   prototype, shows it to the user before anything lands, and commits it
   to the increment's folder under `design/increments/` with the
   prototype's patch and the notes.
4. **Who builds depends on size.** When the prototype is the
   implementation, the coordinator applies its patch to the real tree, runs
   the routed runners and commits, whatever its size; the brief keeps its
   record half only. A multi-stage increment takes one fresh high-tier
   agent per stage, each prompt carrying the brief's path, the
   predecessors' handoff notes and the tip hash; one commit per stage,
   suite green. An agent that stopped on a design conflict having edited
   nothing is resumed with the ruling, its context intact, never replaced.
5. **One cold review** by an independent high-tier agent over the whole
   increment, whoever built it: an open-mind stance, probe scripts outside
   the tree, and "empty is acceptable". It runs the gate on the Julia floor
   `Project.toml` declares, and reverts each fix alone on a scratch copy to
   show a test goes red; a surviving mutant is a missing test, or an
   acceptable survivor named with its reason.
6. **The coordinator adjudicates and a fixer lands the fixes** as one
   "Fix increment N's review findings" commit, whoever built the
   increment, a docstring-sized fix excepted. A fixer that stops on a
   survivor is resumed with a ruling.
7. **The reviewer verifies the delta**, resumed with its context intact,
   and runs the gate again unless the fixer did. The user diff-verifies the
   arc once; then the push.

## Docs and code

- A doc amendment lands as its own commit first, and the increment
  conforms to it. The readings the user ratifies land as a docs commit
  before the code commit.
- A library component lands as a companion plus its inventory rows, one docs
  commit.
- The notes file is a `notes_*.md` in the increment's folder. It takes
  every ruling the spec, the log and the brief do not carry, with its
  reason: the user's as they are made, and the coordinator's own when the
  user delegates overnight. Nothing is pushed overnight.

## The prototype and its probes

- The worktree is a scratch `git worktree` with the root `Manifest.toml`
  copied in: a worktree lacks that untracked file, and the `examples/test`
  environment needs one `Pkg.instantiate()`. The gate runs there
  unchanged, the worktree's `git diff` is the brief's patch, applied with
  `git apply` once the docs commit lands, and every pin and figure in the
  brief comes from the prototype. The worktree carries the previous
  increment's patch when the next prototype needs it, and the brief's
  reference file names which hunks are its own.
- Probe read-only against the real tree only while no agent runs on it, in
  a `module` under `Main` with `test/repl.jl` and `test/utils.jl`, the second
  after `using Test`. A probe of a device paces its run, since a short run
  ends before the device's task is scheduled, and bounds every wait. `@allocated`
  can read 0 on a dynamic call whose result goes unused, so use the result.
- Measure allocations through `phase_bodies`, and build under `(Float64,
  LinearizeDual)`, before a number enters a brief. Measure compile latency
  through the real entry point in a fresh process with `--startup-file=no`:
  a startup file that loads Revise, or a probe that calls a resolver's
  per-item helper, hides the per-call-shape recompile the real path pays.
- A developed dependency's `[sources]` path is honored by Pkg, but a
  package reached only through it is not `using`-able from `Main`; a
  temporary environment develops both. A new test dependency needs the
  real tree's untracked `Manifest.toml` resolved (`Pkg.resolve()` under
  `--project=test`) before any runner there. A new dependency's version is
  what Pkg resolves in the worktree, not the depot's newest copy. A macro
  that reads a file at expansion (`artifact"name"`) fails at load when the
  entry is missing: probe the load, not only the call.

## Running agents

- A stage prompt names the routed runner subset and the files to commit,
  checked against the brief's bookkeeping, since an omitted file silently
  defers the item. It cites `code_rules.md` by path and restates nothing
  from it.
- While an agent runs its gate on the real tree, nobody edits there.
- A mid-tier agent reads a frozen copy (`git show <tip>:file`) of
  any file the coordinator is editing.
- Several sessions may share one working tree: list the peers before
  launching, run arcs that touch the same files serially, and stage
  explicit paths only, so that a peer's uncommitted hunk is neither
  committed nor reverted.
- If a stage stops without a report, check `git stash list`.
- A frontend increment larger than one builder's run splits by concern
  into two fresh agents in one worktree, the second starting from the
  first's notes.
- **Long agents.** A whole-increment prototype or review runs hundreds of
  turns. Its launch prompt states a context ceiling and a stopping point
  below it (500k and 450k tokens today), at which the agent writes its
  notes, lists the rest as handed on and reports; a successor continues
  from the worktree and the notes. The prompt also says: read with grep
  and line ranges, never whole files; test output through `tail`; a notes
  file outside the tree, appended at each milestone; the costly probes
  last. The coordinator watches the agent's context and sends it its
  reading as it nears the stop, since the agent cannot see its own. Flat
  context with near-zero output per turn means stuck.

## The coordinator's context

- The ceiling is 500k tokens and the stopping point 450k, for the
  coordinator as for a long agent. The coordinator reads its own context
  at every agent report, every round of rulings and every commit.
- The brief's commit is a planned check, and on a multi-stage increment
  the last stage's commit is another: no agent is resumed across either.
  Past 400k there, a fresh session lands the increment.
- Elsewhere the coordinator hands over at 450k, once every running agent
  has reported. An agent answers only the session that launched it, so a
  handover between the review and the delta check costs a fresh reviewer,
  launched from the review's record and the fix commit.
- The handover is the notes file, brought up to date: the state at the
  tip, where each ruling lives, the rulings recorded nowhere else, what
  is open, and the worktrees, logs and agents' notes by absolute path.
  The coordinator commits it, puts the stage reached on the `pending.md`
  bullet, and gives the user the successor's first prompt: the brief, the
  notes, the bullet and the tip hash.
- The successor reads those and the rules, never the old transcript.
