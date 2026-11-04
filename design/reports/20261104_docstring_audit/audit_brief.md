# Brief: audit the API docstrings against the style sheet

Repository `/Users/miguel/.julia/dev/Redstone.jl`, branch master. Your roster file
names the docstrings in scope, by file. The module exports nothing yet, so the
scope is the reference page `docs/src/api.md`, not an export list. A name's every
docstring on the page is in scope, its other methods' too.

## Read first

1. `design/tools/docstring_style.md`, whole. It is the rule set, its checklist
   included. Ignore its "Procedure" paragraph; this brief replaces it.
2. `design/tools/spec_style.md`, its "Sentences" section only.
3. The worked example: `LimitedIntegrator` in `src/blocks.jl`, its `# Design:`
   comment and docstring. It was rewritten to the sheet on purpose. Note how
   mechanism moved to the comment and how the paragraphs were shortened.

Read source files with grep and line ranges, not whole.

## The job

Check every docstring on your roster against every checklist line, and fix the
ones that break a rule. A docstring that breaks no rule stays byte-identical. Do
not polish a compliant docstring, and do not assume either way how many comply:
none or all is an acceptable result. In particular judge lines 20, 21 and 22,
which were added today and which earlier passes never checked: short paragraphs,
one burden per sentence, active voice, no colon as a mid-sentence connector, each
paragraph answers what the call needs, produces or refuses, and mechanism only
where the user needs it to use the call correctly. Delegating methods and
one-line signatures are often fine.

## Constraints

- **Docstrings and their `# Design:` comments only.** Change no code, no other
  comment, no test, no other file. Touch only the source files on your roster.
- **Change no fact.** Every claim comes from the old docstring, its comment or
  the method's code. Do not invent behaviour. If a docstring disagrees with the
  code, or a claim looks false, leave it and report it as a finding.
- **Nothing is deleted.** Every sentence either stays, rewritten for the reader,
  or moves to the `# Design:` comment above the opening quotes, at the content
  level. A docstring with no comment gains one when something moves. The comment
  sits directly above the opening quotes, its first line the citations if any.
  The set of `§` and `D-` citations is preserved exactly.
- **Glossary links.** Check an anchor exists with
  `rg -n 'id="g-NAME"' design/spec.md` before writing one. A term with no entry
  is written in plain words. Link only the first mention per docstring.
- **A family stays in one voice.** Methods of one function render together, so a
  summary you change keeps the form its siblings use. If a sibling sits in a file
  outside your roster, keep the existing form and report the mismatch.
- **Wrap prose at 80 columns or fewer.** A signature line may run longer. Rewrap
  only paragraphs you changed, plus any line over 80 inside a docstring on your
  roster.
- **Report rather than resolve** anything needing a ruling, such as a signature
  that disagrees with Appendix B or a rule that seems wrong for a case.

## Shared tree

Other agents are editing other source files in this working tree right now. Use
Edit on your own files only.

- No git writes: no commit, stash, checkout, reset, add. The coordinator commits.
- Do not run the test suite or the Documenter build. After your edits, check that
  each changed file parses:
  `julia --startup-file=no -e 'Meta.parseall(read(ARGS[1], String))' FILE`
  and that `git diff -- FILE` shows only comment and docstring lines changed.
- Use `fd` or `/bin/ls`, never `ls`: the shell alias can hang.
- A run longer than 600 s never applies here, and no polling loops.
- Do not write report files. Return the report as your final message.

## Report, under 30k characters

1. Per file: docstrings checked, changed, left as they were.
2. Per changed docstring: its name and the checklist lines it broke, one line.
3. Findings: each with file, line and what needs a ruling or looks false.

Be plain about what you did not get to. A short honest report beats a complete-
looking one.
