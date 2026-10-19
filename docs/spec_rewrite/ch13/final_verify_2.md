# Chapter 13, step 6b: final verification, half 2 (units F and G)

Verifier `h2`. Edits since `5f21eba`, checked at `4de4315`. Logs, in order:
`chapter_fixes_2.md` (33 entries), then `ruled_edits_2.md` (16 entries).
The prompt's diff base `69a3191` is a chapter 12 commit; `5f21eba` is used
throughout.

## Counts

- Hunks: 33 in `new.md` (F 14, G 19), plus 2 in `units/F/rulings.md` (the
  B22 and B86 citations, as B86's status asks).
- Edits checked: 49 (33 editorial, 16 ruled).
- Replay: both logs replayed on `5f21eba` give `4de4315`'s `units/F/new.md`
  and `units/G/new.md` byte for byte. No unlogged hunk.
  `chapter_new.md` is current.
- `build_inventory.py`: `checks failed: 0` for A, B, F and G; the
  inventories are unchanged by the re-run.
- Bold: the only bold span changed is B5's, now the headline clause.
- Glossary links: no anchor twice in a section; each new link (port, roster,
  trace, condition, leaf walk, `Δt_base`, constant source, abstract entry,
  algebraic loop, projection) is at its term's first use in the section.
- Wrap: every logged paragraph fills to 80 columns, counting code-span
  backticks as the fixers did.
- Findings: 7.

## The special checks

- B12: the Simulink mapping now sits in R13's sentence. The cut also took
  "the inventory … is" the companion, which R13's "shipped list" narrows
  (finding 5).
- B7: no sentence of §13.8 says the sampled mode carries primals now
  (finding 1).
- B20: "(the addressable unit of the model)" is the first clause of
  `#g-port`, at the first use of *port* in §13.5, with one link.
- B13 and B8: the bold heads its sentence and opens the paragraph. The
  requester roster is glossed before every later use. The moved sentence
  makes line 102 the first use of "the ignore list" (finding 4).
- B2: "runs from the member's input face … to the output port" matches
  D-245 bullet 1 ("routes the entering face to the leaving port") and the
  hop of lines 374–376.
- Fixer 2's paragraph entries: a word diff of each finds nothing beyond its
  findings and the rewrap. Entries 18 and 32 add a second gloss to a
  sentence (findings 2 and 3), and entry 17's inserted sentence moves an
  antecedent away (finding 6).

## Findings

1. **G 324 (B7).** "The *sampled* set-tracer (the log's *local* mode) at
   sampled states is the fallback …". The old "(primal-carrying)" went with
   the gloss, and no other sentence of §13.8 states it. B7's ruling does not
   list the deletion; only the glossary (B41) keeps it. Fix: end the bullet
   with "Unlike the global tracer, it carries primals."
2. **G 6–9 (entry 18, P2-15).** "… for each root [face](#g-face) (the name a
   port wears …), and a standard library of [components](#g-component) (the
   units of modeling, …)." Two glosses in one sentence (R23). Fix: end the
   sentence at "a standard library of [components](#g-component)", then add
   "Components are the units of modeling, each a leaf or an assembly of
   components."
3. **G 335–337 (entry 32, P2-24).** "Derivatives, [guards](#g-guard) (…),
   handlers and [projections](#g-projection) (the optional per-component hook
   …) are outside …". Two glosses in one sentence (R23). Fix: drop the
   projection parenthetical and add "A projection is the optional
   per-component hook `x ← x_projection(x)`." after the sentence.
4. **F 102 (B13).** "The ignore list sits beside `t_end` at the same
   declaration site." This is now the term's first use, ahead of 105–111,
   and no sentence ties the term to the keyword. Fix: "The ignore list,
   `ignore_stop_requests`, sits beside `t_end` at the same declaration
   site."
5. **G 54–55 (B12).** "The shipped list, and the Simulink mapping that
   prunes it, live in `companions/library_inventory.md`." The cut clause
   pointed the whole inventory there. The companion also holds candidates
   and example-first blocks ("Status is one of *shipped*, *candidate* …"),
   so "shipped list" narrows the pointer. R13 dictated "shipped list", so
   this needs a ruling. Fix: "The inventory, candidates included, and the
   Simulink mapping that prunes it, live in
   `companions/library_inventory.md`."
6. **F 318–319 (entry 17, P2-12).** "A trace is a session's record of its
   drained inputs." now sits between "terminal, not resumable" and "enforce
   that non-resumability". Fix: "enforce the non-resumability".
7. **G 206 (entry 25, P2-24).** "[constant source](#g-constant-source) (a
   `Constant` holding it)". The gloss has four words and leans on "it"
   instead of saying what the term is. Fix: "(a `Constant`, publishing the
   value its instance holds)".

## Re-check

`final_fixes_2.md`, 7 entries, replayed on `4de4315` gives the working tree's
`units/F/new.md` and `units/G/new.md` byte for byte. A word diff of each
entry finds only its finding, or the orchestrator's ruled wording for
findings 1 and 5. Each edited paragraph fills to 80 columns. No anchor is
linked twice in a section. Each new sentence gloss follows its link, and no
sentence now carries two glosses. `build_inventory.py` reports
`checks failed: 0` for F and G.

Findings: 1.

1. **`chapter_new.md`** is stale. It does not hold the current F and G
   text, so `checks/assemble.sh` was not run after the final fixes. Fix: run
   `checks/assemble.sh ch13` once A and B are settled.

Note, no fix needed: "(the log's *local*, primal-carrying mode)" can read as
if the log says "primal-carrying". Only the old spec text and the glossary
use that word, and D-349 says "local" alone.
