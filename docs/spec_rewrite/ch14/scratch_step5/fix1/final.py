"""Apply final_verify_1.md's eleven fixes to the current units A and B, log
them in final_fixes_1.md, and carry them into claims.md. Run once, from
docs/spec_rewrite/ch14."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(HERE, "engine.py")).read()
exec(src[:src.index("exec(open(")])          # the helpers only

t = {u: open(f"units/{u}/new.md").read() for u in "AB"}
G_OVR = "(the ordered, asymmetric layering combinator)"
TOT = "(the requirement that an application establishing a complete world cover every root input)"
PROJ = "(the optional per-component hook `x ← x_projection(x)`)"
OPS = [
 ("span", "Finding 1", "A",
  "[§14.9][s14-9] mounting and [§14.10][s14-10] linearization.",
  "[§14.9][s14-9] mounting, which together cover the trim service in full, and [§14.10][s14-10] linearization."),
 ("span", "Finding 2", "A",
  "[root input](#g-root-input)) and `override`,",
  f"[root input](#g-root-input)) and [`override`](#g-override) {G_OVR},"),
 ("raw", "Finding 2", "A",
  "the scratch world is [`override`](#g-override)`(baseline, condition(guess))`",
  "the scratch world is `override(baseline, condition(guess))`"),
 ("span", "Finding 3", "A",
  "`n_eng → ω = n_eng·ω_rated`, and nothing above it should have to. `n_eng` is the engine speed as a fraction of its rated speed `ω_rated`.",
  "`n_eng → ω = n_eng·ω_rated`, where `n_eng` is the engine speed as a fraction of its rated speed, and nothing above it should have to."),
 ("span", "Finding 4", "A",
  f"belongs with the use case of [root-input totality](#g-root-input-totality) {TOT} ([§14.6][s14-6]).",
  f"belongs with the use case that [root-input totality](#g-root-input-totality) {TOT} produces ([§14.6][s14-6])."),
 ("span", "Finding 5", "B",
  "That inspection is the [replay](#g-replay)-to-inspect, where",
  "That inspection is the [replay](#g-replay)-to-inspect ([§11.2][s11-2]), where"),
 ("span", "Finding 6", "B",
  "and a guard is the declared function defining an event's predicate. A due component is a discrete component whose schedule admits the boundary's tick index, and a snapshot is the immutable per-boundary publication.",
  "and a guard is the declared function that decides when an event fires. A due component is a discrete component scheduled to run here, and a snapshot is the immutable publication that closes the sequence."),
 ("span", "Finding 7", "B",
  "They are the user fragment math, the leaf stores,",
  "They are the user [fragment](#g-fragment) math, the leaf stores,"),
 ("span", "Finding 7", "B",
  "the current state). The fragment math is",
  "the current state). A fragment is the leaf node of the condition algebra, built by `set`. The fragment math is"),
 ("span", "Finding 7", "B",
  "the locality law ([§6.1][s6-1]) and [fragment](#g-fragment) scoping ([§14.2][s14-2]) describe. A fragment is the leaf node of the condition algebra, built by `set`. A service read,",
  "the locality law ([§6.1][s6-1]) and fragment scoping ([§14.2][s14-2]) describe. A service read,"),
 ("span", "Finding 8", "B",
  "Projection, the sweep, events and the due `s_update` calls come first, then the `t₀` argument, then what [boundary zero](#g-boundary-zero)",
  f"[Projection](#g-projection) {PROJ}, the sweep, events and the due `s_update` calls come first. Then come the `t₀` argument and what [boundary zero](#g-boundary-zero)"),
 ("span", "Finding 8", "B",
  f"After condition writes, [projection](#g-projection) {PROJ} holds the same position",
  "Projection after condition writes holds the same position"),
 ("span", "Finding 9", "B",
  f"and baselines layered by [`override`](#g-override) {G_OVR}.",
  "and [baselines](#g-baseline) (aircraft-shipped, full-coverage condition functions) layered by [`override`](#g-override), the ordered, asymmetric layering combinator."),
 ("span", "Finding 9", "B",
  "**[Baselines](#g-baseline) are aircraft-shipped condition functions**",
  "**Baselines are aircraft-shipped condition functions**"),
 ("span", "Finding 10", "B",
  "rule (when a GUI widget stages a new value) ([§11.7][s11-7]).",
  "rule (the rule that a GUI widget stages a new value only on interaction, never per render pass) ([§11.7][s11-7])."),
]
for kind, fid, u, *a in OPS:
    t[u] = globals()[kind](t[u], fid, u, *a)
for u in "AB":
    open(f"units/{u}/new.md", "w").write(t[u])

with open("final_fixes_1.md", "w") as f:
    f.write("# Chapter 14, step 6b: final fixes, half 1 (units A and B)\n\n"
            "The fixes of `final_verify_1.md`, applied to `units/A/new.md` and\n"
            "`units/B/new.md` after `chapter_fixes_1.md` and `ruled_edits_1.md`. Each\n"
            "entry replaces its old text, which occurs once in the unit's file at that\n"
            "point, by its new text; replay them in order. Each edited paragraph is\n"
            "rewrapped to 80 rendered columns.\n\n")
    for n, (fid, u, old, new) in enumerate(LOG, 1):
        f.write(f"## {n}. {fid}, unit {u}\n\nOld:\n\n````text\n{old}\n````\n\nNew:\n\n````text\n{new}\n````\n\n")
    f.write("""## Claims and notes

- Finding 1 restores the cut claim: its `claims.md` block keeps the old
  phrase, tagged F, with no ruling.
- Finding 8 splits the run-order sentence in two, so the projection gloss and
  the boundary-zero gloss each sit in their own sentence.
- Finding 9: `override`'s gloss becomes an appositive, so the sentence keeps
  one parenthetical.
- Finding 11 edits only `units/B/claims.md`: B1's note now points at "its own
  plan" and "A compiled plan", since P1-15 cut "the compiled plans".
""")

for u in "AB":
    for n, l in enumerate(t[u].split("\n"), 1):
        if l.startswith(("|", "  |", "#", "```")): continue
        if len(render(l)) > W: print(f"{u}:{n} {len(render(l))} cols")
print(len(LOG), "entries")
