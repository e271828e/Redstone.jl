# Docstring style guide

The rules the API docstrings are written to. Read before writing or changing
the docstring of an exported name, by the agent that does it and by the
reviewer that checks it. Like
`spec_style.md`, it is not in the check tools' rosters; the `§` marks below
are examples of what a docstring must not contain.

## Scope and reader

- **The sheet governs the docstrings of exported names.** The exported-name
  audit (`pending.md`) fixes that set. Until it runs, the provisional set is
  the API page, `docs/src/api.md`, which lists Appendix B's surface and the
  extension-only surface (the stage family, the binding traits, the device
  contract) with it. Unexported names keep their docstrings as they are.
- **An internal-type method of a public function carries a `# Design:`
  comment, not a docstring.** A docstring on it would render under the public
  name and show a type the reader cannot construct. The comment keeps its
  text, so nothing is deleted. A sentence the user needs joins the docstring
  of the public type it concerns, as the simulation's frame hooks join
  `FrameHooks`.
- **The reader is at `?name` or on the reference page.** They know Julia and
  hybrid simulation. They have never opened `spec.md` or `decisions.md`, and
  they do not know what `§12.6` or `D-255` means. Every rule below follows
  from that reader.

## The shape

- **One template, the manual's.** Indented signature lines first, a blank
  line, a one-sentence summary, elaboration in short paragraphs, an optional
  `# Keywords` or `# Arguments` list, an optional `# Examples` block, and a
  `See also` line of [`name`](@ref) links. Above the opening quotes, a
  `# Design:` comment carries the citations. It cannot sit between the
  closing quotes and the definition: Julia attaches a docstring only to the
  expression that immediately follows it, and a comment there detaches it.

```julia
# Design: §12.6, §13.5.
"""
    closed(run::Run) -> Bool

Return `true` once the run has ended and its
[termination record](@ref g-termination-record) is written.

`closed` answers whether the run itself is over. For why it ended, see
[`termination`](@ref).
"""
closed(run::Run) = run.termination !== nothing
```

- **Keywords and arguments are bulleted lists, not tables.** Appendix B uses
  tables; a list reads in the REPL at any width, where a wide table wraps.
  One bullet per name, its default in the signature, its meaning in one
  sentence. A table that is not a keyword list, such as `ControllerBlock`'s
  case table, stays where a list cannot carry it.
- **A struct whose fields are public lists them under a lead sentence.** A
  sentence such as "A report holds these fields." opens one bullet per field,
  its meaning in one sentence. A struct with one public field names it in
  prose.

## Signatures

- **The signature line mirrors the method.** One line per method, with the
  type annotations on its positional arguments and the keyword defaults as
  the definition writes them, then the return type after `->`. The code is
  what a user calls; Appendix B is the inventory of names in scope, not a
  source of spelling, and it writes `→` as typography where a docstring
  writes `->`. A line longer than the width wraps at a keyword, the
  continuation aligned under the first argument.
- **A return type that is not one concrete type is written in words, or as
  `Any`.** `x_init` returns `NamedTuple, value or nothing`, each member
  named, and a read whose type is the cell's writes `-> Any`. `Any` is for a
  return nothing narrower is true of.
- **A fallback users extend names its argument.** Where users write methods
  of the function, or the prose refers to the argument, the line names it
  even where the method leaves it unnamed, as in
  `init!(dev::AbstractDevice) -> Nothing`. Where neither holds, the line
  keeps the method's form, as in `frame_top!(::NoHooks) -> Nothing`.
- **A block with a keyword constructor shows the keyword form only.** It is
  an exception to one line per method. The positional constructor the struct
  keeps gets no line, as `companions/library_inventory.md` states for the
  library.
- **A forwarded `kw...` is shown as the callee's keywords.**
  `DiscretizedStateSpace(; kwargs...)` shows the keywords of
  `StateSpace(; …)`, so the line names every keyword the call accepts.
- **A delegating method with no docstring of its own takes its line on its
  sibling's docstring.** `state(sim::Simulation, path::String)` sits under
  `state(model::Model, path::String)`, and the prose says the simulation
  reads its model's.
- **A method that only refuses, or that dispatches on an internal type, gets
  no signature line.** One sentence of prose states its refusal or its role,
  and its citations stay in the `# Design:` comment. `trim!`'s docstring
  states in one sentence how a second argument that is not a `TrimProblem`
  is refused.
- **A sentinel default that exists only to raise a diagnostic is shown as
  required.** `Deployment` declares `h = nothing` so that a missing `h` is
  refused as `DeploymentInvalid` rather than a `MethodError`; its signature
  line writes `h` with no default, and the keyword list says it is required.
- **A default that is an unexported constant is written as its value.**
  `width::Int = LINEARIZE_WIDTH` is written `width::Int = 8`, and a default
  with no literal value, such as `_no_checks`, is left off the line and
  stated in the prose.
- **A signature that disagrees with Appendix B is a finding against B.** The
  rewrite reports it and the spec is corrected. The docstring is never bent
  to match the appendix.

## The summary sentence

- **One sentence, under twenty words, stating what the call does or what the
  value is.** Functions take the imperative: `Return`, `Advance`, `Attach`.
  Types take a noun phrase: "The scalar-free artifact that fixes a build's
  grid parameters."
- **No citation, no history, no defense.** The summary names no section, no
  entry, no predecessor and no alternative. "This is not a defect" is a
  sentence for the log.
- **A library block's summary names its class and tier.** It opens "A
  continuous primitive that …" or "A discrete primitive that …", and
  `Group`'s opens "An assembly …". The abstract parents and `AsPort` keep
  their own forms.

## Elaboration

- **Short paragraphs in the spec's register.** `spec_style.md`'s sentence
  rules carry over: one burden per sentence, active voice, topic sentences
  that state the paragraph's content, no em-dashes, at most one parenthetical.
- **Each paragraph answers one of three questions.** What the call needs,
  what it produces, or what it refuses and with which diagnostic. A refusal
  names the diagnostic kind in code, as Appendix B does: "refused as
  `DeploymentInvalid` when absent".
- **Mechanism stays out unless the user needs it to use the call correctly.**
  How a run is paced belongs in `run!`'s docstring because `margin` is a
  keyword; how the pacer's wait is implemented does not.
- **A correction or a review finding obeys the same test.** It enters the
  docstring only if the user needs it to use the call correctly. Otherwise it
  goes to the `# Design:` comment or the companion.
- **A sentence that states a behaviour is checked against the code.** The
  rules above govern form, and a rewrite that keeps every sentence keeps
  every error in them. A claim the code does not show on its face is settled
  by a probe. A false claim is a finding, reported with its replacement
  drafted.
- **A sibling's job is a cross-reference, not an explanation.** The docstring
  links the sibling with [`name`](@ref) and says in a clause why the reader
  would go there.

## Vocabulary

- **The first mention of a glossary term links to the glossary page.** The
  link is `[term](@ref g-id)`, with Appendix D's anchor id, as in "the
  [snapshot](@ref g-snapshot)". A docstring is read alone, so each one links
  its own first mentions, the summary included. The page is generated from
  Appendix D, so the link resolves where the definition lives. It skips D's
  meta-vocabulary group, so a term there, such as "artifact", takes no link.
- **A docstring never defines a term inline.** The glossary page carries the
  definition. A term with no entry is written in plain words, as the coinage
  rule below says.
- **A code-named entry is linked through its API link only.** `Model`,
  `TrimProblem` and `at` take [`Model`](@ref) and the like, never a glossary
  link. Prose "build", "deployment", "model" and "run" take no glossary link.
  A code-named entry with no API link, such as `should_abort` or `t*`, keeps
  its glossary link.
- **The spec keeps its glosses.** Its readers arrive at a section or a line
  range and cannot follow a link, while a docstring's reader is one link from
  the glossary page.
- **Primitive or assembly names the class, continuous or discrete the
  tier.** "Block" means only that the standard library ships the component.
  "Leaf" names only a leaf of a store, a leaf address or the leaf of a
  condition, never a component.
- **No `§`, no `D-nnn`, no FlightCore, no Flight.jl.** A docstring never
  cites the spec, the log or the predecessor. Those go to the `# Design:`
  comment.
- **A companion `*.md` pointer is a citation too.** A docstring names no
  design file, such as `linear_blocks.md`, and the pointer moves to the
  `# Design:` comment.
- **No coinages outside the glossary.** A term the glossary does not carry is
  unwound into plain words.
- **`Model` is the type; the authored tree is the component tree or the
  root.** As in `spec_style.md`.

## What moves and what stays

- **An edit deletes nothing.** Every sentence an edit takes out of the
  docstring moves into the `# Design:` comment, rewritten or as it was.
- **Every citation moves to the comment.** The comment's first line lists the
  sections and entries the docstring cited. Maintainer prose with content of
  its own, such as which policy an advance declares and where it lives
  afterwards, follows on further comment lines. A diff reviewer reads a
  comment as easily as a docstring.
- **The check is mechanical.** The set of `§` and `D-` citations before the
  edit equals the set after it, the comment counted. A citation that
  vanished is a finding.

## Examples

- **A `jldoctest` block only where it shows the call's shape in a few lines
  with stable output.** Cheap means under ten lines, a run of a few frames at
  most, and output that does not depend on timing or allocation.
- **Tiny inline components only, never the examples package.** The examples
  package changes shape on its own schedule, and a doctest that imports it
  rots with it.
- **`using Redstone` comes from the doctest setup, declared once.** The
  `DocTestSetup` meta in the module docstring or `docs/make.jl` provides it,
  so no block repeats it.
- **One example per entry point at most, and none for a type.** A type's
  example is its constructor's.

## Procedure and review

- **A sweep is staffed one source file per agent, this sheet as the brief's
  rule set, after a pilot file.** The pilot is one small file on the stable
  core, reviewed against this sheet, and what it teaches lands here first.
  Each agent rewrites every docstring in scope in its file and reports every
  finding from the rules above instead of resolving it. A cold review
  follows, by the checklist below.
- **The checklist is the rules' index.** A rule added above gets its line
  below in the same edit, since the reviewer works from the list.

The reviewer's checklist, one line per rule:

1. Signature lines mirror the method, `->` for the return type.
2. One summary sentence, under twenty words, imperative or noun phrase.
3. No `§`, `D-`, FlightCore or Flight.jl inside the quotes.
4. Every old citation appears in the `# Design:` comment.
5. Each glossary term's first mention linked as `[term](@ref g-id)`, no
   inline definition.
6. Keywords as a list, each with its meaning in one sentence.
7. Every refusal names its diagnostic kind.
8. Cross-references as [`name`](@ref), siblings not explained.
9. Doctests inline, short, stable, no examples package.
10. Nothing from the old docstring lost.
11. An internal-type method of a public function has a comment, not a
    docstring.
12. A fallback users extend names its argument.
13. No line for a method that only refuses or dispatches on an internal type.
14. A delegating method's line on its sibling's docstring.
15. A keyword block in its keyword form only, a forwarded `kw...` as the
    callee's keywords.
16. Public fields listed under a lead sentence.
17. Primitive, assembly, continuous, discrete, block and leaf as the
    vocabulary rule says, and library summaries in their forms.
18. No companion `*.md` pointer inside the quotes.
19. An unexported-constant default written as its value, or stated in the
    prose.
20. Short paragraphs, one burden per sentence, active voice, no colon as a
    mid-sentence connector.
21. Each paragraph answers what the call needs, produces or refuses.
22. Mechanism, a correction or a finding included, only where the user needs
    it to use the call correctly.
23. Nothing after the `# Keywords` list but `# Examples` and `See also`.
24. Each sentence stating a behaviour checked against the code, a probe where
    the code does not show it.
25. A sentinel default shown as required.
26. A signature that disagrees with Appendix B reported as a finding against
    B, never bent.
27. No coinage outside the glossary.
28. `Model` the type, the authored tree the component tree or the root.
29. A return type that is not one concrete type written in words, or `Any`.

## The battery

- **The Documenter build is the acceptance test.** `makedocs` with
  `doctest = true` and `checkdocs = :exports`, green. A failing doctest or an
  exported name missing from the reference page fails the build.
- **The mechanical checks are the second test, over the API page's
  docstrings.** `§`, `D-[0-9]`, a predecessor's name and a companion pointer
  come back empty, and no summary reaches twenty words. After a rewrite,
  each file's citation set is unchanged with its comments counted, and its
  AST with the docstrings stripped matches the base.
  `design/reports/20261104_docstring_audit/` holds `roster.jl` and
  `ast_check.jl`, which run them. The grep traps in `implementation.md` that
  read docstring text are re-checked after a file's rewrite.
