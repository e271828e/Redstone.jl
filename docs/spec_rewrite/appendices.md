# The appendices: one treatment each

The plan for the last part of the readability rewrite, settled with the
owner on 2026-10-20. The chapter recipe does not transfer. The four
appendices are four different kinds of artifact, and each gets its own
treatment, sized so that any one of them can run in a session of its own.

What the chapters share with this work: one brief per appendix in the
recipe's form, seeded with that appendix's carried items from `README.md`;
the battery after each lands (`spec_style.md` lists it); rulings recorded
with their reasons as the chapters did; the orchestrator rules and only a
real design decision reaches the owner.

Measured at `6ac4635`:

| appendix | lines | words | entries |
|---|---|---|---|
| A. Taught contracts | 12953–13098 | 1,340 | 18 |
| B. API synopsis | 13099–13563 | 4,090 | 6 blocks |
| C. Diagnostic kind set | 13564–14018 | 3,880 | 84 kinds |
| D. Glossary | 14019–15500 | 10,070 | 175 in 10 groups |

## Appendix A: rewrite as one unit, after a harvest

A is the only appendix close to a chapter. It fits one recipe unit, it
already reads near the new style, and its carried fixes are two bold
lead-ins with no D-citation (§5.3's rulings, D-089 and D-141).

The owner wants it expanded with what authors and users have learned since
it was written in August. An entry of A is a recall line for a contract
the owning section already states and no check enforces, so adding one is
not a design change. The expansion is therefore a **harvest**, not a
survey: one Opus agent, read-only, over what accrued after A was written.
Its sources are the decision log from D-162 on, the companions written
since (`pid_anti_windup.md`, `limited_integrator_variants.md`,
`lqr_tracker.md`, `trim_environment_walkthrough.md`,
`linearization_walkthrough.md`), the friction notes and `notes_*.md` files
in `docs/design/briefs/`, and the `escalations.md` files of the chapter
rewrites (recoverable from the commits the README's table names). It
returns candidates, each with the owning section, the evidence that an
author gets it wrong without a diagnostic, and a draft recall line. The
owner picks.

One structural question for the harvest to test. A has two audiences,
component authors and periphery authors, and none for the service user.
Chapter 14 came after A, and the trim and condition algebra have semantic
traps no check catches. A third group, for operators and service users, is
the natural home if the harvest finds entries for it.

Then the ordinary steps: one rewriter over A as a single unit with the
chosen additions, one blind verifier, the battery.

**The front matter and the Part roadmaps** ride with A. They are small and
their fixes are already listed in the README (the Part III roadmap omits
§12.5; the Part IV roadmap omits §13.3, §13.6 and §13.7, misstates §13's
scope and predates §14's roadmap sentence).

## Appendix B: thin it, don't polish it

B is too dense for one reason. It disclaims being a second home and then is
one. Most of its words explain each entry in prose the owning section
already carries, and the bundle table's footnotes restate §5.2's bundle law
in full. The recipe says the overlap analysis buys little for appendices;
for B it is the whole job.

The pass classifies every sentence of B three ways:

1. a name or signature;
2. a duplicate of its owning section;
3. a claim stated nowhere else.

Class 3 is the finding list. Each such claim moves to its owning section or
becomes a docstring, and the owner rules on any that is a decision. Classes
1 and 2 collapse to the thin shape: per entry a signature, a one-line
gloss and a citation. Cutting duplicated prose is not a loss of content,
since the spec's own rule gives that content one home.

B lists what the code has today. Its signatures are checked against `src/`
in the same pass, since nothing generated will catch them later. The
carried fixes ride along: the `Model` rows' "door" wording (chapter 12's
R14 reserves *door* for an entry point that builds a run), the missing
`port(snapshot, path, name)` beside `port(model, path, name)`, the handler
return law's missing D-090 citation, and the seven names the examples
import that B omits (`AbstractComponent`, `Absolute`, `get_deriv`,
`logged`, `termination`, `EndTimeReached`, `ModelRequestedStop`). Listing a
name is this rewrite's; exporting or renaming it is the audit's.

## Appendix C: audit against the code, no rewrite

C is normative and shape-fixed. Every entry is a kind, its owners, severity,
stage, policy and payload, and tests match on kind plus payload. Readers
look entries up, so prose is beside the point and accuracy is everything.

Two mechanical layers:

1. **The kind set, both ways.** A script lists the bold kinds in C and the
   structs subtyping `Diagnostic` in `src/`, and diffs them. At `6ac4635` C
   has 84 bold entries and a plain grep finds 83 structs. That discrepancy
   is explained before anything else.
2. **Per kind**, the payload fields against the struct, the severity
   against its `severity` method, and raised and policy against the raise
   sites. Bounded Sonnet work over frozen copies (`git show <tip>:file`),
   in parallel ranges, one TSV row per kind with a verdict and an excerpt.

Chapter 14's B75 rows seed the fix list: `ConditionResolution`'s sub-kinds,
`DuplicateConditionLeaf`'s leaf, `ConditionNodeMisuse`'s `:set_payload`,
`ConditionShapeDrift`'s `reason`, `TapResolution`'s seeded-tap limits
(D-424), `TrimProblemInvalid`'s `:inverted_box` and
`:nonpositive_tolerance` (D-422), `ReadResolution` and §14.9. Also
`TwoProducers`'s "sibling wire", which D-314 makes "local wire". Findings
land as fixes. Where C and the code disagree on behavior rather than on
description, the owner rules.

## Appendix D: citations, gaps and length

D is non-normative, the largest appendix, and the one readers of the
rewritten chapters land on through the glossary links, so its accuracy
matters more than its style. Three checks:

1. **Citations.** Every entry's cited section still states what the entry
   says. The rewrites moved a lot of text. Known breaks: *generic holding*
   cites §6.1, which no longer states it, and *local wire* cites §6.1 for
   "one end on the boundary", which D-314's Rationale states. This is a
   judgment check, Opus over bounded ranges of entries.
2. **Gaps.** Terms the rewritten chapters define or bold with no entry.
   Known: `#g-entry` lacks the wiring entry (§6.1, §13.3) and the condition
   entry, input entry and tap (§14). The bold checker's inventory gives the
   candidate list.
3. **Length.** A cap per entry, with the overflow pushed back to the owning
   section. *contract* is the archetype of an entry that outgrew a lookup
   line, and the "not to be confused with" clauses are where entries swell.

`check_glossary.jl` covers the anchors and stays in the battery.

## Lessons from Appendix A

Landed 2026-10-20; the working files stay in `appA/` until the directory
closes.

- **Probe a companion's behavioral claim before it grounds a spec sentence.**
  The limited-integrator companion said a hit guard gated on the free mode
  re-latches once and leaves the release guard unable to fire. A probe on a
  gated copy of the block showed the pair handing each other fresh edges and
  chattering until the firing budget breaks the tie, with the mode decided
  by which event fired first. The spec sentence and the companion were
  written from the probe, not the companion. The rest-reading claim held
  exactly, with one nuance the sentence had to respect: a component not due
  at boundary zero holds its authored store until its first tick.
- **The unit checker refuses a bold with no D-citation in its sentence**,
  and an index's bold labels are sentences to it. The rewriter met it by
  adding each old entry's ruling entry to its owners parenthetical, eleven
  citations the verifier then had to check. Decide the label convention and
  the checker's treatment of it before the rewriter starts.
- **Thirteen new entries made ADDED the main check**, not an afterthought:
  the verifier's prompt had to say that every added sentence is checked
  against the spec sentence it rests on, by frozen line.
- **A brief error travels.** The brief placed a §5.3 sentence in §1; the
  rewriter caught it. Check every section number a brief's table names
  against the outline.

## Lessons from Appendix B

Landed 2026-10-20 in two units, B1 to the panel kit and B2 from the
condition algebra on; the working files stay in `appB/`.

- **Classify before the brief.** Four read-only Opus agents over bounded
  ranges, one TSV row per sentence (`appB/classify_brief.md`), plus one
  Sonnet agent checking every signature against `src/`. Of about 360 rows,
  21 were stated nowhere else and 17 had drifted from their home. Every
  stated-nowhere-else row turned out to be ruled by a log entry, so none
  needed the owner but one.
- **A dropped claim is checked where it lands.** Each claim the thin shape
  drops is tag `M` with its home's own span, found in `appB/homes.md`: the
  frozen spec at `e6a4fcb` with B cut out (`awk 'NR<13371 || NR>13846'`)
  and the one move into §12.1 applied. The file is not committed; rebuild
  it that way to re-run `check_unit.py appB`.
- **Thinning drops names, and a name on B is public** (D-226). The first
  drafts dropped eleven diagnostic kinds with the prose around them. A
  script diffing the backticked names of `old.md` and `new.md` finds them
  before the verifier does.
- **Two units of one section need a link rule keyed on the new text.**
  B2's rule, "link a term only if B1's old text never uses it", left five
  terms unlinked once B1's new text dropped them.
- **The glossary whitelist records deliberate unlinks.** `check_glossary.jl`
  failed when B linked *derived-contract*, which the polysemy pass left
  unlinked on purpose; the link went, not the whitelist entry.
- **The signature checker's absences need a second grep.** It reported
  `termination` absent, missing a one-line method definition.

## Lessons from Appendix C

Landed 2026-10-21 as an audit, with D-431; the working files stay in
`appC/`.

- **Payload drift is the main drift.** Of 345 rows, 53 were stale, and
  nearly all of them were fields and reason values the structs hold and C
  never named. Severity agreed everywhere. Spell every `reason` with its
  full value set, since tests match on it.
- **A field set on one reason is not a field of the kind.** The audit rows
  and the first edits stated four such fields for every occurrence. A fresh
  Opus verifier over the diff caught all four. Say which reason carries a
  conditional field.
- **The owners check is noise unless filtered.** A section that mentions a
  kind is not an owner. Add an owner only where the section states a raise
  rule the entry describes.
- **A policy mismatch can be a missed conformance.** The per-unit
  collection predated D-229 by a week and was never conformed. Date the code
  against the entry before deciding which side moves.

## Sequencing

- Working order: A whole, that is the harvest, the owner's pick, then the
  unit rewrite with the front matter. Then B, C and D in that order, since
  B's relocations and C's corrections both feed D's citation check. One
  appendix in flight at a time, and any one of them can run in a session
  of its own.
- `pending.md` places the exported-name audit before the appendices. The
  audit edits B's name list. A thin B makes that cheap, so the order no
  longer matters much, and is decided deliberately rather than by accident.
- When all four have landed, the README's status table records them, and
  this file's lessons go into the recipe before `docs/spec_rewrite/` closes.
