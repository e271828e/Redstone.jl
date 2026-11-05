# Docstring style guide

The rules the API docstrings are written to, read before writing or changing
one, by the agent that does it and by the reviewer that checks it. Like
`spec_rules.md`, it is not in the check tools' rosters; the `§` marks below
are examples of what a docstring must not contain.

## Scope and reader

1. **The sheet governs the docstrings of exported names.** The exported-name
    audit (`pending.md`) fixes that set. Until it runs, the set is the API page,
    `docs/src/api.md`, which lists Appendix B's surface and the extension-only
    surface (the stage family, the binding traits, the device contract) with
    it. Unexported names keep their docstrings as they are.
2. **The reader is at `?name` or on the reference page.** They know Julia and
    hybrid simulation, have never opened `spec.md` or `log.md`, and do
    not know what `§12.6` or `D-255` means. Every rule below follows from that
    reader.
3. **What a docstring may not carry goes to the `# Design:` comment above the
    opening quotes.** That is every citation, maintainer prose, mechanism the
    user does not need, and the whole docstring of an internal-type method of a
    public function, which would render under the public name with a type the
    reader cannot construct. A sentence the user needs joins the docstring of
    the public type it concerns, as the simulation's frame hooks join
    `FrameHooks`. The comment cannot sit between the closing quotes and the
    definition, since Julia attaches a docstring only to the expression that
    immediately follows it.

## The shape

4. **One template, the manual's.** Indented signature lines, a blank line, a
    one-sentence summary, elaboration in short paragraphs, an optional
    `# Keywords` or `# Arguments` list, an optional `# Examples` block, and a
    `See also` line of [`name`](@ref) links. Nothing follows the keyword list
    but those two.

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

5. **Keywords and arguments are bulleted lists, not tables.** One bullet per
    name, its default in the signature, its meaning in one sentence. A list
    reads in the REPL at any width, where a wide table wraps. A table that is
    not a keyword list, such as `ControllerBlock`'s case table, stays where a
    list cannot carry it.
6. **A struct whose fields are public lists them under a lead sentence**, such
    as "A report holds these fields.", one bullet per field, its meaning in one
    sentence. One public field is named in prose.

## Signatures

7. **The signature line mirrors the method.** One line per method, with the
    positional arguments' type annotations and the keyword defaults as the
    definition writes them, then the return type after `->`. The code is what a
    user calls; Appendix B is an inventory of names, not a source of spelling,
    and writes `→` where a docstring writes `->`. A long line wraps at a
    keyword, the continuation aligned under the first argument.
8. **A return type that is not one concrete type is written in words, or as
    `Any`.** `x_init` returns `NamedTuple, value or nothing`, each member
    named. A read whose type is the cell's writes `-> Any`, which is for a
    return nothing narrower is true of.
9. **A fallback users extend names its argument**, as in
    `init!(dev::AbstractDevice) -> Nothing`, also where the prose refers to it.
    Otherwise the line keeps the method's form, `frame_top!(::NoHooks) -> Nothing`.
10. **A block with a keyword constructor shows the keyword form only.** The
    positional constructor the struct keeps gets no line, as
    `companions/library_inventory.md` states.
11. **A forwarded `kw...` is shown as the callee's keywords.**
    `DiscretizedStateSpace(; kwargs...)` shows `StateSpace`'s, so the line
    names every keyword the call accepts.
12. **A delegating method with no docstring of its own takes its line on its
    sibling's docstring.** `state(sim::Simulation, path::String)` sits under
    `state(model::Model, path::String)`, and the prose says the simulation
    reads its model's.
13. **A method that only refuses, or that dispatches on an internal type, gets
    no signature line.** One sentence of prose states its refusal or its role,
    as `trim!`'s does for a second argument that is not a `TrimProblem`.
14. **A sentinel default that exists only to raise a diagnostic is shown as
    required.** `Deployment`'s `h = nothing` makes a missing `h`
    `DeploymentInvalid` rather than a `MethodError`; the line writes `h` with
    no default, and the keyword list says it is required.
15. **A default that is an unexported constant is written as its value**,
    `width::Int = 8` for `LINEARIZE_WIDTH`. A default with no literal value,
    such as `_no_checks`, is left off the line and stated in the prose.
16. **A signature that disagrees with Appendix B is a finding against B.** The
    spec is corrected, and the docstring is never bent to match it.

## The summary sentence

17. **One sentence, under twenty words, stating what the call does or what the
    value is.** Functions take the imperative, `Return`, `Advance`, `Attach`;
    types a noun phrase, "The scalar-free artifact that fixes a build's grid
    parameters."
18. **No citation, no history, no defense.** No section, entry, predecessor or
    alternative. "This is not a defect" is a sentence for the log.
19. **A library block's summary names its class and tier**, "A continuous
    primitive that …", "A discrete primitive that …", and `Group`'s "An
    assembly …". The abstract parents and `AsPort` keep their own forms.

## Elaboration

20. **Short paragraphs in the spec's register.** `spec_rules.md`'s sentence
    rules carry over: one burden per sentence, active voice, topic sentences
    that state the paragraph's content, no em-dashes, no colon as a
    mid-sentence connector, at most one parenthetical.
21. **Each paragraph answers one of three questions.** What the call needs,
    what it produces, or what it refuses and with which diagnostic kind, named
    in code as Appendix B does: "refused as `DeploymentInvalid` when absent".
22. **Mechanism, a correction, a review finding or an increment's novelty
    enters only where the user needs it to use the call correctly.** How a
    run is paced belongs in `run!`'s docstring because `margin` is a keyword;
    how the pacer's wait is implemented does not. That a block declares its
    one port bare belongs in `u_types`'s docstring and the glossary; at the
    block, the reader needs the port's name and type, which the wire example
    gives. The rest goes to the comment or the companion.
23. **A sentence that states a behaviour is checked against the code.** The
    other rules govern form, and a rewrite that keeps every sentence keeps
    every error in them. A claim the code does not show on its face is settled
    by a probe, and a false one is a finding, reported with its replacement
    drafted. So is an imprecise one, true on the common path and false on a
    path a user can reach. A path only a poke at the internals reaches is
    neither.
24. **A sibling's job is a cross-reference, not an explanation**, a
    [`name`](@ref) link and a clause saying why the reader would go there.

## Vocabulary

25. **The first mention of a glossary term links to the glossary page**, as
    `[term](@ref g-id)` with Appendix D's anchor id, "the
    [snapshot](@ref g-snapshot)". A docstring is read alone, so each one links
    its own first mentions, the summary included. The page is generated from
    Appendix D and skips its meta-vocabulary group, so a term there, such as
    "artifact", takes no link. The spec keeps its glosses, since its readers
    cannot follow a link where a docstring's reader is one link from the page.
26. **A docstring never defines a term inline, and coins none.** The glossary
    carries the definitions, and a term it does not carry is unwound into plain
    words.
27. **A code-named entry is linked through its API link only.** `Model`,
    `TrimProblem` and `at` take [`Model`](@ref) and the like, never a glossary
    link, and prose "build", "deployment", "model" and "run" take none. A
    code-named entry with no API link, such as `should_abort` or `t*`, keeps
    its glossary link.
28. **Primitive or assembly names the class, continuous or discrete the
    tier.** "Block" means only that the standard library ships the component.
    "Leaf" names only a leaf of a store, a leaf address or the leaf of a
    condition, never a component.
29. **No `§`, no `D-nnn`, no FlightCore, no Flight.jl, no companion `*.md`
    pointer.** A docstring cites neither the spec, the log, the predecessor nor
    a design file such as `linear_blocks.md`. All of it goes to the comment.
30. **`Model` is the type; the authored tree is the component tree or the
    root.** As in `spec_rules.md`.
31. **A type parameter is named in prose only where the docstring defines
    it, in the sentence that first uses it.** The sentence says which values
    share the type, that it is the block's parameter, and what it may be and
    where it comes from: "the state and both ports share one type, the
    parameter `V`, `Float64` or an `SArray` of `Float64`, taken from
    `Float64.(x0)`, an array converted to an `SArray`". A later sentence may
    then say "pinned at `V`". A
    parameter the user never writes, such as the `R` that `reset = true`
    fixes, is mechanism under rule 22 and goes to the comment; the prose
    names the keyword.

## What moves and what stays

32. **An edit deletes nothing but a false sentence.** Every other sentence it
    takes out of the docstring moves into the comment, rewritten or as it was.
    A false sentence is replaced by its correction, and the comment does not
    keep it.
33. **Every citation moves to the comment**, whose first line lists the
    sections and entries the docstring cited. Maintainer prose with content of
    its own, such as which policy an advance declares and where it lives
    afterwards, follows on further lines.
34. **The check is mechanical.** The set of `§` and `D-` citations before the
    edit equals the set after it, the comment counted. A citation that vanished
    is a finding.

## Examples

35. **A `jldoctest` block only where it shows the call's shape in a few lines
    with stable output.** Under ten lines, a run of a few frames at most, and
    output that does not depend on timing or allocation.
36. **Tiny inline components only, never the examples package**, which changes
    shape on its own schedule and rots any doctest that imports it.
37. **`using Redstone` comes from the doctest setup, declared once** in the
    `DocTestSetup` meta of `docs/make.jl`, so no block repeats it.
38. **One example per entry point at most, and none for a type.** A type's
    example is its constructor's.

## Procedure and review

39. **A sweep is staffed one large source file per agent, the small files
    grouped by word count, this sheet as the brief's rule set, after a pilot
    file** on the stable core, whose lessons land here first. Each agent
    rewrites every docstring in scope in its files and reports every finding
    from the rules instead of resolving it. A cold review follows.
40. **The reviewer's checklist is the numbered headlines, read in order.** A
    rule is its headline, so the list cannot drift from the rules, and a brief
    cites a rule by its number.

## The battery

41. **The Documenter build is the acceptance test.** `makedocs` with
    `doctest = true` and `checkdocs = :exports`, green. A failing doctest or an
    exported name missing from the reference page fails the build.
42. **The mechanical checks are the second test, over the API page's
    docstrings.** `§`, `D-[0-9]`, a predecessor's name and a companion pointer
    come back empty, and no summary reaches twenty words. After a rewrite,
    each file's citation set is unchanged with its comments counted, and its
    AST with the docstrings stripped matches the base.
    `design/tools/docstring_roster.jl` lists the docstrings and runs the token
    and summary checks, `design/tools/docstring_signatures.jl` prints
    signature and keyword candidates for a reader, and `ast_check.jl` in
    `design/reports/20261104_docstring_audit/` compares the ASTs. The grep
    traps in `code_rules.md` that read docstring text are re-checked after a
    file's rewrite.
