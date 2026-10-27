# Docstring style guide

The rules the API docstrings are written to. Consulted before rewriting one,
by the agent that rewrites a file and by the reviewer that checks it. Like
`spec_style.md`, it is not in the check tools' rosters; the `§` marks below
are examples of what a docstring must not contain.

## Scope and reader

- **The sheet governs the docstrings of exported names.** The exported-name
  audit (`pending.md`) fixes that set. Until it runs, the provisional set is
  Appendix B's surface less the extension-only surface (the stage family,
  the binding traits, the device contract) and less the names the audit
  flags. Unexported names keep their docstrings as they are.
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
  tables; the REPL renders a list and mangles a table. One bullet per name,
  its default in the signature, its meaning in one sentence.
- **A struct whose fields are public lists them under a lead sentence.** A
  sentence such as "A report holds these fields." opens one bullet per field,
  its meaning in one sentence.

## Signatures

- **The signature line mirrors the method.** One line per method, with the
  type annotations on its positional arguments and the keyword defaults as
  the definition writes them, then the return type after `->`. The code is
  what a user calls; Appendix B is the inventory of names in scope, not a
  source of spelling, and it writes `→` as typography where a docstring
  writes `->`.
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
- **A sibling's job is a cross-reference, not an explanation.** The docstring
  links the sibling with [`name`](@ref) and says in a clause why the reader
  would go there.

## Vocabulary

- **The first mention of a glossary term links to the glossary page.** The
  link is `[term](@ref g-id)`, with Appendix D's anchor id, as in "the
  [snapshot](@ref g-snapshot)". A docstring is read alone, so each one links
  its own first mentions, the summary included. The page is generated from
  Appendix D, so the link resolves where the definition lives.
- **A docstring never defines a term inline.** The glossary page carries the
  definition. A term with no entry is written in plain words, as the coinage
  rule below says.
- **A code-named entry is linked through its API link only.** `Model`,
  `TrimProblem` and `at` take [`Model`](@ref) and the like, never a glossary
  link. Prose "build", "deployment", "model" and "run" take no glossary link.
- **The spec keeps its glosses.** Its readers arrive at a section or a line
  range and cannot follow a link, while a docstring's reader is one link from
  the glossary page.
- **Primitive or assembly names the class, continuous or discrete the
  tier.** "Block" means only that the standard library ships the component.
  "Leaf" names only a leaf of a store or a leaf address, never a component.
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

- **Nothing is deleted.** Every sentence of the old docstring either stays,
  rewritten for the reader, or moves into the `# Design:` comment.
- **Every citation moves to the comment.** The comment's first line lists the
  sections and entries the docstring cited. Maintainer prose with content of
  its own, such as which policy an advance declares and where it lives
  afterwards, follows on further comment lines. A diff reviewer reads a
  comment as easily as a docstring.
- **The check is mechanical.** The set of `§` and `D-` citations in the old
  docstring equals the set in the new docstring plus its comment. A citation
  that vanished is a finding.

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

- **The pilot file first.** One small file on the stable core, reviewed
  against this sheet, before any agent is briefed. What the pilot teaches
  lands here before the sweep starts.
- **One source file per agent, this sheet as the brief's rule set.** The
  agent rewrites every docstring in scope in its file and reports every
  finding from the rules above instead of resolving it.
- **A cold review after, by the checklist below.**

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

## The battery

- **The Documenter build is the acceptance test.** `makedocs` with
  `doctest = true` and `checkdocs = :exports`, green. A failing doctest or an
  exported name missing from the reference page fails the build.
- **A grep is the second test.** Over the docstrings of exported names, `§`
  and `D-[0-9]` come back empty. The grep traps in `implementation.md` that
  read docstring text are re-checked after a file's rewrite.
