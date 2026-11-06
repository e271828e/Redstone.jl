# Brief rules

The rules for writing a brief, whatever the job: an increment of the code,
a sweep, an audit. A brief is the only instruction its builders and its
reviewer get beyond the repo's standing rules, so it routes, pins and
counts, and restates nothing a rules file says. The pipeline it feeds is
`increment_rules.md`; the template is the last section.

## Routing

- Route the reading: `code_map.md` entries for the files touched, the
  `pending.md` bullets, spec sections by line range, the authoring caveats
  that apply, the head of "What is real here". Never say "read the map".
- Every number in a brief comes from a probe run as `increment_rules.md`
  says; none is derived from a signature or a roadmap.

## Counting and citing

- Every count, classification and runtime claim is re-checked against the
  tree or a REPL before it enters a brief or an entry; roadmap counts are
  stale by the time later steps launch. A `name = ` grep counts keyword
  arguments as locals. A specialization claim is probed, never derived
  from signatures. "Closes a cycle as X does" is a classification claim:
  probe real against artificial per port.
- Line numbers come from `git show HEAD:file`, never the working tree, and
  the brief names the tip's hash; a brief written before another increment
  lands is rebased at the new tip, every line recounted. A cited block
  range starts at its docstring's opening `"""`. A phrase grep misses a
  gloss that wraps across a line: grep a short fragment, and count sites
  before the brief states a number. Recount every pinned-site list after a
  docs amendment moves lines.
- A fixture declaring `X{T}` walks; only a literal `Float64` is a pin. A
  parametric fixture is a `UnionAll` the `Dual` sweep never sees, so it
  changes no pinned count; run `build` before touching that pin, as the
  routing table says for any new fixture.

## Scope

- Before writing "needs no change", ask who else *constructs* the shape at
  runtime. When a decision rosters a field, grep who reads it; a field
  nobody reads is a ruling to raise. When a decision states a principle,
  the same increment greps for its other instances and the reviewer's
  brief names the sweep; a `@nospecialize` ruling follows the value into
  every callee that takes it. Before storing a derived fact in a keyed
  table, list every writer of that key space (D-210).
- Before renaming a function, grep the spec for it as a bare name: a
  spec-named function is a ruling. `README.md`'s quick start is a component
  file, so a declaration-surface change routes it into scope.
- Grep every new name across `test/` in both directions: a same-named type
  silently rebinds a fixture module. The block keeps the name; the fixture
  is renamed as its own commit before the brief, gate run.
- A new declaration says whether it joins the §8.1 family (D-246's check).
  A loop-signature change lists every direct caller. A stage prompt never
  widens a grep the brief scoped. Before moving a file below another in
  the include order, grep the earlier file for the later one's types.
- A fingerprint guards a copy by position: list what the positions depend
  on before calling it complete.
- A vocabulary sweep is classified before the brief: parallel read-only
  high-tier agents over bounded ranges, one TSV row per occurrence with
  class, excerpt and proposed rewrite; the coordinator adjudicates the
  borderline rows; the stage reports a disagreement rather than deviating.

## Library blocks

- An event design in an inventory row is probed against §10.6's
  bookkeeping before the brief; `companions/library_inventory.md` section
  2 names the shapes that have failed there.
- A fixture wired to a typed input is checked to publish that type. A
  brief that sends the builder to "the helper the neighbouring tests use"
  greps that the helper exists and names it.
- A handler pin is taken from the state where no other event repairs the
  handler's work: a reset onto a limit pinned from a free start lets the
  hit event clamp and code it, and the handler's own mutants survive. A
  block that gains a form (a policy, a reset) runs every existing policy
  of that form; a model whose `localized` reaches only the sources leaves
  the block's boundary-detected arm untested.
- A continuous block's allocation testset measures its phase bodies at
  `LinearizeDual` beside `Float64`, by `test_executor.jl`'s loop over the
  two scalars. A `Dual` model freezes the discrete tier and compiles events
  out, so a discrete block has no bodies to measure there.

## Prose for agents

- Proof-read prose handed over for a literal paste. Check an override or
  example against the rules it cites before launch; a fixer's prompt never
  overrides a ruling. A mid-tier agent reads an example list as
  exhaustive: state the principle and say "every instance". State a
  rewrap width in numbers.

## Tests and mutants

- A mutant dies only if it changes a result: a by-name selection makes an
  argument-order mutant unkillable, and a pin on a rate-limited or filtered
  signal may be unable to fail. Pin upstream of the limiter, and ask of
  every new pin which mutant turns it red. When the settled struct fixes a
  type domain, check every test claim against it.
- A "bumpless" or "tracks" claim is probed in the transient, not only at
  steady state, and stated with numbers: a standby follows a command with
  a lag of about `Tt` times the command's slew plus one tick. A pin whose
  window opens inside a transient pins the noise realization, not the
  claim: sweep the step over a few tick alignments and open the window
  where every alignment reads the same.
- A diagnostic two raisers share has every sentence checked against each.
- A new port is probed by building the block alone as a root (D-210). A
  design procedure a companion states, signs included, is checked
  numerically before the docs commit.

## The template

The sections below, in this order; a section that does not apply is
omitted, not left empty. The latest landed brief shows the register.

```markdown
# Brief: increment N, <title>

<The commits the arc makes. Drafted on <date> at <tip>, after the docs
commit <hash>. Who prototyped, in which worktree, and the patch file
beside this brief. Whether the user is away, and where the coordinator's
rulings are. "Not normative: if a shape below proves wrong at the
keyboard, stop and report rather than deviate.">

## What is settled
<The pending bullet or ruling this delivers. Each ruling with its reason.
The log entry, or the companion and inventory rows, docs commit first.>

## The shape built
<Per file, what appears, moves or goes, with line ranges from
`git show <tip>:file`.>

## Measurements
<Allocations, specializations, compile latency, every figure from the
prototype.>

## Readings the prototype took
<Each reading on an unruled seam, the recommendation, and whether the
user ratified it.>

## What the tests pin, by property
<One bullet per testset: the property, the section it answers to, the
mutant that turns it red.>

## The stages
<Multi-stage increments only. Per stage: the agent, the files, the routed
runners, the commit, the handoff notes it writes.>

## Routing
<The reading per stage: map entries, spec line ranges, pending bullets,
rules sections.>

## Bookkeeping
<The map entries, the pending bullets retired or added, the inventory
rows, the docs files, each named.>

## Out of scope
<What stays out, and where it is recorded.>

## The cold review
<What the reviewer probes, the sweep it runs, the survivors it may accept
and why.>

## The review's record
<Filled after the review: findings, fixes, survivors with their reasons.>
```
