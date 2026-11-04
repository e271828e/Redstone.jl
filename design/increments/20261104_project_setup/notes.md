# Project setup overhaul: notes

Rulings taken while restructuring `design/` and moving the agent-facing
instructions from the memory repo into the tree, 2026-11-04. Each
step is one commit; each cut names its reason so it can be reversed from
the diff.

## Step 1: `rules/` and the split of `implementation.md`

- `implementation.md` splits on its own headers: "What is real here"
  becomes `code_map.md`, named to pair with `rules/code_rules.md`; the
  "Every file" rules from the old head and "Authoring caveats", "Naming"
  and "Running the suite" become `rules/code_rules.md`.
- Cut from the old head: the increment-1 bench sentence (D-162 holds its
  numbers), "spec and code are peers" (it goes to `AGENTS.md`), and the
  docstring sentence (now a rule under "Every file").
- Cut from "Running the suite": the 600 s foreground timeout and the
  background wait. They describe one harness and go to the user's global
  instructions in step 5.
- Briefs and reports keep `implementation.md` where they cite it: they
  cite it by line number and by tree hash, so a rewrite would falsify the
  record. The pure renames (`spec_style.md`, `decisions_style.md`,
  `docstring_style.md`) are swept in records too, since the file is the
  same file.
- The log's citations of `implementation.md` and `decisions_style.md` are
  substituted under `decisions_rules.md` rule 2's pure-substitution
  exception.
