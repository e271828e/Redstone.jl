"""Chapter 13 landing, step 1: edits outside the chapter. Asserts every match first."""
import sys
from pathlib import Path

D = Path("/Users/miguel/.julia/dev/Redstone.jl/docs/design")

EDITS = {
    "spec.md": [
        # §8.6 (brief, old 3410-3412)
        ("The read side\nwalks the full depth, as `\"systems/ldg/left/trn\"` does in a [snapshot](#g-snapshot) (the\nimmutable per-boundary publication) or the log tree. That read side is the\ninspection side. It resolves a path with `resolve` under the instance walk\n([§13.3][s13-3]).",
         "The read side\nwalks the full depth, as `\"systems/ldg/left/trn\"` does in a [snapshot](#g-snapshot) (the\nimmutable per-boundary publication) or the log tree. Snapshot and log\ninspection walk instances ([§13.3][s13-3])."),
        # B40, §8.5
        ("part of the starting inventory ([§13.7][s13-7], [D-184][d-184])",
         "part of the library ([§13.7][s13-7], [D-184][d-184])"),
        # §9.2 D-261 cite (brief)
        ("The edges are derived\n  from the structure's connections and the producers' stage-2 names.",
         "The edges are derived\n  from the structure's connections and the producers' stage-2 names\n  ([D-261][d-261])."),
        # B25, §9.3
        ("`UserCodeFraming`-wrapped build failure ([§13.1][s13-1]).",
         "`UserCodeFraming`-wrapped build failure ([§13.1][s13-1],\n[§13.2][s13-2])."),
        # B26, §9.5
        ("That site's frame holds the boundary time\nand the replay index.",
         "The carrier holds the clock at the failure\nand the replay pointer."),
        # §9.5 nonfinite (brief, F20; actually old 5096)
        ("catch site adds the loop-level nonfinite-state check",
         "catch site adds the model's nonfinite-state check"),
        # B36, §9.7
        ("The seam is diagnostic only ([§13.5][s13-5]), and it makes one promise.",
         "The seam is diagnostic only, and it makes one promise."),
        # B27, §10.6
        ("(the\nloop-state field recording where execution stands, [§13.4][s13-4])",
         "(the\nexecutor's field recording where execution stands, [§13.4][s13-4])"),
        # §11.2 7108 (brief) and B23, one rule across both paragraphs
        ("They reach any cell, since\ninspection reads admit deep paths.",
         "They reach any cell a path\nthrough no generic seam names ([§13.3][s13-3])."),
        ("Every cell is reachable, because the table is public throughout ([§8.3][s8-3]).",
         "Every cell a path through no generic seam names is reachable, because the\ntable is public throughout ([§8.3][s8-3], [§13.3][s13-3])."),
        # B35, §11.5
        ("keywords of each advance\n([§13.5][s13-5], [D-316][d-316])",
         "keywords of each advance\n([§12.6][s12-6], [D-316][d-316])"),
        # B37, §11.5
        ("its `Deployment` and `t₀` ([§13.5][s13-5],\n[Appendix B][sB])",
         "its `Deployment` and `t₀`\n([Appendix B][sB])"),
        # B35, §12.1
        ("what the caller declares for one advance ([§13.5][s13-5])",
         "what the caller declares for one advance ([§12.6][s12-6])"),
        # B35, §12.7 table
        ("each `replay!` call declares its own ([§13.5][s13-5])",
         "each `replay!` call declares its own ([§12.6][s12-6])"),
        # B24, Appendix A
        ("It sees everything and promises\n  nothing across builds.",
         "It sees everything and promises\n  nothing across builds ([§13.3][s13-3])."),
        # B28, Appendix B
        ("The getfield walk along `/`\n  segments. It enforces the one-level rule for wiring ([§6.1][s6-1]) and the\n  generic-holding rule for deep reads, at the primitive ([§13.3][s13-3]).",
         "Resolves an immediate child, a\n  container element's key segment included. Wiring resolution applies the\n  one-level rule ([§6.1][s6-1]), and the service walk enforces the\n  generic-holding rule ([§13.3][s13-3])."),
        # B35, Appendix B
        ("keywords of each advance\n  ([§13.5][s13-5]). A run ends",
         "keywords of each advance\n  ([§12.6][s12-6]). A run ends"),
        ("declared for **this advance**, validated per call | [§13.5][s13-5] |",
         "declared for **this advance**, validated per call | [§12.6][s12-6], [§13.5][s13-5] |"),
        ("nothing else keeps one ([§13.5][s13-5], [D-260][d-260])",
         "nothing else keeps one ([§12.6][s12-6], [§13.5][s13-5], [D-260][d-260])"),
        # B29, Appendix C
        ("The stages are the ones [§13][s13]\nfixes:",
         "The stages are the ones [§13.2][s13-2]\nnames:"),
        ("while *user code* runs (an interface-connection body, a\n  probe).",
         "while *user code* runs (a declaration body, a probe, an\n  activation's continuous-tier function)."),
        # B30, Appendix C
        ("collection ([§13.2][s13-2], [D-250][d-250]).",
         "collection ([§9.2][s9-2], [D-250][d-250])."),
        # B31, Appendix C
        ("  Cursor frame (component path, function, and the boundary phase, which is\n  an RK stage, an event round, a localization trial evaluation or a tick),\n  boundary time, frame-entry boundary index",
         "  Cursor frame (the component by its component-list index, the function, and\n  the boundary phase: the frame-top drain, an integration stage, the arrival\n  sweep, the θ = 0 validation, a localization trial, projection, an event\n  round or the ticks), the clock at the failure, frame-entry boundary index"),
        # B32, Appendix C
        ("  Component path, the offending state block, boundary time and index.",
         "  Component path, the offending state leaf and its value, the frame-top time\n  and the frame-entry boundary index."),
        # B34, glossary
        ("declares and the stop word is what anyone can issue ([§13.5][s13-5],\n[D-255][d-255]",
         "declares and the stop word is what anyone can issue ([§12.1][s12-1],\n[§12.6][s12-6], [§13.5][s13-5], [D-255][d-255]"),
        # B33, glossary
        ("**execution cursor** — the plain mutable field recording where execution\nstands in the compiled order. It holds three facts, the component path as an\nindex into the `Outputs`'s execution order, the function running, and the\nboundary phase. It costs one cheap store per dispatch, so a runtime failure\ngets its frame without exception frames in the hot path ([§13.4][s13-4]).",
         "**execution cursor** — the executor's plain mutable field recording where\nexecution stands in the compiled order. It holds three facts, the component by\nits index in the structure's component list, the function running, and the\nboundary phase. It costs one cheap store per dispatch, so a runtime failure\ngets its cursor frame without exception handlers in the hot path\n([§13.4][s13-4])."),
        # B41, glossary
        ("(global\nvalue-blind, or local primal-carrying at sampled states)",
         "(global\nvalue-blind, or sampled primal-carrying)"),
    ],
    "extensions.md": [
        # B38
        ("get the parametric spelling in the [§13.7][s13-7] migration — whether",
         "get the parametric spelling in the migration — whether"),
        # B40
        ("joins [§13.7][s13-7]'s starting inventory as",
         "joins [§13.7][s13-7]'s library as"),
    ],
    "companions/migration_outline.md": [
        # B39
        ("Falling-edge consumers wire a NOT gate (the Bool gates, [§13.7][s13-7]).",
         "Falling-edge consumers negate the `Bool` in their own stage, since the\nlibrary admits no `Not` ([D-311][d-311])."),
    ],
    "implementation.md": [
        # B41
        ("It is global on `true` and local\n  on `false`",
         "It is global on `true` and sampled\n  on `false`"),
    ],
}

texts = {f: (D / f).read_text() for f in EDITS}
bad = False
for f, edits in EDITS.items():
    for old, _ in edits:
        n = texts[f].count(old)
        if n != 1:
            print(f"MISMATCH {f}: {n}x: {old[:70]!r}")
            bad = True
if bad:
    sys.exit(1)
for f, edits in EDITS.items():
    t = texts[f]
    for old, new in edits:
        t = t.replace(old, new)
    (D / f).write_text(t)
    print(f"{f}: {len(edits)} edits")
