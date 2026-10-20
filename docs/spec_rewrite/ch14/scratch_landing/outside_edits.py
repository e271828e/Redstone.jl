"""Chapter 14 landing, step 1: edits outside the chapter (B21-B27, B29-B31).

Every old text must occur exactly once; nothing is written unless all match.
"""
import sys
from pathlib import Path

ROOT = Path("/Users/miguel/.julia/dev/Redstone.jl/docs/design")
SPEC = "spec.md"

EDITS = [
    # B21, §9.3: bold goes plain, four sites.
    (SPEC, "B21 §9.3",
     """uninitialized root inputs. **Every complete-world application, namely
`init!`, trim setup and trim commit, carries the pre-write
`UninitializedInputs` check** ([§14.6][s14-6], [D-149][d-149]).""",
     """uninitialized root inputs. Every complete-world application, namely
`init!`, trim setup, trim commit and linearization's operating condition
under `about`, carries the pre-write `UninitializedInputs` check
([§14.6][s14-6], [D-149][d-149])."""),
    # B25, §9.6: the fallback as design.
    (SPEC, "B25 §9.6 fallback",
     """  ([§14.7][s14-7]). The derivative-free fallback runs the same loop
  on the nominal `Float64` activation, with no new activation needed. The
  always-on checks ride along either way.""",
     """  ([§14.7][s14-7]). The derivative-free fallback is designed and not yet
  built, and `pending.md` lists it ([D-070][d-070]). It would run the same
  loop on the nominal `Float64` activation, with no new activation needed.
  The always-on checks ride along either way."""),
    # B25, §9.6: the get_x_ss pointer after F64.
    (SPEC, "B25 §9.6 get_x_ss",
     """  hand-written per-aircraft state-space mapping layer. That replacement
  discharges the layer's deletion ([§7.1][s7-1]). Root inputs are the input
  surface.""",
     """  hand-written per-aircraft state-space mapping layer, so none remains
  ([§7.1][s7-1], [D-072][d-072]). Root inputs are the input surface."""),
    # B21, §11.3.
    (SPEC, "B21 §11.3",
     """Totality is enforced pre-write at every complete-world application, namely
`init!`, trim setup and trim commit ([§14.6][s14-6], [D-149][d-149]).""",
     """Totality is enforced pre-write at every complete-world application, namely
`init!`, trim setup, trim commit and linearization's operating condition
under `about` ([§14.6][s14-6], [D-149][d-149])."""),
    # B24, §13.2.
    (SPEC, "B24 §13.2",
     """A stopped-sim service returns an artifact, so its warnings live on it. `trim!`
returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and
`TrimCommitChecks` are that report's fields ([§14.8][s14-8]). The line the call prints at
return is presentation.""",
     """A stopped-sim service returns an artifact, so the facts its warnings report
live on it. `trim!` returns a `TrimReport`, which holds the fired events and
both residual sets, and logs `TrimCommitEvents`, `TrimCommitResiduals` and
`TrimCommitChecks` beside it ([§14.8][s14-8]). The line the call prints at
return is presentation."""),
    # B26, Appendix B.
    (SPEC, "B26 nine fields",
     "order is the declared side's. The problem itself closes at seven fields",
     "order is the declared side's. The problem itself closes at nine fields"),
    (SPEC, "B26 commit spelling",
     "  The commit is `init!` with `override(baseline, solution)`, boundary zero",
     "  The commit is `init!` with `override(baseline, condition(solution))`, boundary zero"),
    (SPEC, "B26 never throws",
     "Non-convergence reports, never throws ([§14.7][s14-7], [§14.8][s14-8]).",
     "Non-convergence reports, never throws ([§14.8][s14-8])."),
    # B27, Appendix C.
    (SPEC, "B27 ArgumentInvalid",
     "[§12.6][s12-6], [§12.7][s12-7], [§13.5][s13-5], [§14.7][s14-7]).",
     "[§12.6][s12-6], [§12.7][s12-7], [§13.5][s13-5], [§14.8][s14-8], [§14.10][s14-10])."),
    (SPEC, "B27 ReadSetMisuse",
     "- **`ReadSetMisuse`** ([§14.4][s14-4]). Error · service · fail-fast. The",
     "- **`ReadSetMisuse`** ([§14.9][s14-9]). Error · service · fail-fast. The"),
    # B23, glossary selector.
    (SPEC, "B23 g-selector",
     "against a source before any client policy applies. Table sources are a",
     "against a source. Table sources are a"),
    # B22, glossary baseline (drop init!, align gloss with §14.8 after P2-8).
    (SPEC, "B22 g-baseline",
     """<a id="g-baseline"></a>**baseline** — an aircraft-shipped, full-coverage condition function
(`ready_for_taxi(ac)`, `cold_and_dark(ac)`), layered under tweaks by
`override`. It is also the `baseline` keyword `init!`/`trim!` take
([§14.6][s14-6]).""",
     """<a id="g-baseline"></a>**baseline** — a full-coverage condition, such as an aircraft-shipped
function (`ready_for_taxi(ac)`, `cold_and_dark(ac)`) returns, layered under
tweaks by `override`. It is also the `baseline` keyword `trim!` takes
([§14.6][s14-6])."""),
    # B21, glossary totality.
    (SPEC, "B21 glossary totality",
     """establishing a complete world over virgin stores (`init!`, trim setup, trim
commit) cover every root input. Conditions themselves are legitimately""",
     """establishing a complete world over virgin stores (`init!`, trim setup, trim
commit, linearization's operating condition under `about`) cover every root
input. Conditions themselves are legitimately"""),
    # B22, glossary service lifecycle.
    (SPEC, "B22 g-service-lifecycle",
     "`ServiceLifecycle`, and `errored` is terminal for all four services ([§14][s14]).",
     "`ServiceLifecycle`, and `errored` is terminal for all five services ([§14][s14])."),
    # B29, glossary taps.
    (SPEC, "B29 g-taps",
     """by a leaf address resolving to one scalar leaf. Their selectors are validated""",
     """by a leaf address resolving to one scalar leaf. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a
`.name` step, and its leaf is exactly `Float64`. Their selectors are validated"""),
    # B29, glossary TrimProblem.
    (SPEC, "B29 g-trimproblem",
     "residuals and committed as an `init!` of `override(baseline, solution)`",
     "residuals and committed as an `init!` of `override(baseline, condition(solution))`"),
    # B29, glossary recorded, not built.
    (SPEC, "B29 g-recorded-not-built",
     "activation and declarative non-participation, [§14.10][s14-10]).",
     "activation and the tooling over declared non-participation, [§14.10][s14-10])."),
    # B30, companions.
    ("companions/linearization_walkthrough.md", "B30 selectors",
     """The selectors are [§14.4][s14-4]'s closed family. `get_state(path, field[, i])` names
a state leaf, with an optional component index for a vector leaf.
`get_input(face[, i])` names a root input and `get_face(name[, i])` a
root-exported output face, both with the same index since [D-271][d-271].
`get_output(path, name[, i])` names a component's own output port.""",
     """The selectors are [§14.4][s14-4]'s closed family. `get_state(path, leaf)` names
a state leaf, and a leaf address such as `"q[1]"` picks one component of a
vector leaf. `get_input(leaf)` names a root input and `get_face(leaf)` a
root-exported output face, taking the same leaf address since [D-276][d-276].
`get_output(path, leaf)` names a component's own output port."""),
    ("companions/trim_environment_walkthrough.md", "B30 line 65",
     """sweep is the "init as a third scheduled sweep" that [§14.2][s14-2] rejects by name.""",
     """sweep is the "init as a third scheduled sweep" that [D-064][d-064] rejects by name."""),
    ("companions/trim_environment_walkthrough.md", "B30 line 537",
     """pre-sweeping the environment subtree, which is [§14.2][s14-2]'s rejected "init as a""",
     """pre-sweeping the environment subtree, which is [D-064][d-064]'s rejected "init as a"""),
    ("companions/lqr_tracker.md", "B30 Freeze",
     "frozen at its nominal value routes the port through `Freeze` ([§14.10][s14-10]).",
     "frozen at its nominal value routes the port through `Freeze` ([§13.7][s13-7])."),
    ("companions/pid_anti_windup.md", "B30 Freeze",
     "nominal value routes the port through `Freeze` ([§14.10][s14-10]).",
     "nominal value routes the port through `Freeze` ([§13.7][s13-7])."),
    # B31, migration outline.
    ("companions/migration_outline.md", "B31 gear cell",
     "saturation rank-deficiency (LM-tolerated, reported), the gear identically zero airborne |",
     "saturation rank-deficiency (LM-tolerated, reported), the gear identically zero airborne (Flight.jl's model alone, below) |"),
    ("companions/migration_outline.md", "B31 paragraph",
     """projection, never as construction.

<!-- citation link definitions""",
     """projection, never as construction.

**The C172 AD audit for trim.** [§14.8][s14-8] keeps the audit's guidance on
Interpolations tables and in-model saturations. Its two other findings are
facts about Flight.jl's Cessna 172 model (`c172.jl`). The landing gear is
never evaluated off-zero airborne. The `norm`-at-zero guards are already in
place.

<!-- citation link definitions"""),
]

texts = {}
for f, *_ in EDITS:
    if f not in texts:
        texts[f] = (ROOT / f).read_text()

ok = True
work = dict(texts)
for f, label, old, new in EDITS:
    n = work[f].count(old)
    if n != 1:
        print(f"MISMATCH {label} in {f}: {n} matches")
        ok = False
        continue
    work[f] = work[f].replace(old, new)
if not ok:
    sys.exit(1)
for f, t in work.items():
    (ROOT / f).write_text(t)
    print(f"wrote {f}")
