import sys
D = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
E = [
 # B-2
 ("spec.md", "criterion. It mutates the roster, so `EmptyGreedyClaim` lands in\nthe roster entry's cell ([§11.3][s11-3]). The committed",
             "criterion. It mutates the roster, so `EmptyGreedyClaim` lands in\nthe roster entry's cell ([§11.6][s11-6]). The committed"),
 # B-3
 ("implementation.md", "`attach!` into the roster entry's own cell (§11.3, D-250);",
                       "`attach!` into the roster entry's own cell (§11.6, D-250);"),
 # B-5
 ("companions/inbound_periphery_walkthrough.md",
  "like any other claim and gets the same schema, cell, drain and trace\n([§11.6][s11-6]). A second greedy binding attached afterwards finds nothing left",
  "like any other claim and gets the same schema, cell, drain and trace\n([§11.3][s11-3]). A second greedy binding attached afterwards finds nothing left"),
 # B-6 Appendix B
 ("spec.md", "- `stage!(sim, \"face\" => value, …)`. Task-free staging from the calling task\n  into the harness writer ([§11.3][s11-3]). Its surface is the currently",
             "- `stage!(sim, \"face\" => value, …)`. Staging from any task, the calling\n  task included, into the harness writer ([§11.3][s11-3]). Its surface is the currently"),
 # B-6 harness cell
 ("spec.md", "written by `stage!(sim, \"face\" => value, …)` from the calling task itself.",
             "written by `stage!(sim, \"face\" => value, …)` from any task, the calling task included."),
 # B-6 harness writer
 ("spec.md", "**harness writer** — the framework-owned write path of the calling task,\n`stage!(sim, …)` and its cell, and the design's sole *derived* surface. That",
             "**harness writer** — the framework-owned write path `stage!(sim, …)`, open\nto any task, with its cell; the design's sole *derived* surface. That"),
 # B-6 §12.6
 ("spec.md", "`stage!(sim, \"face\" => value, …)` ([§11.3][s11-3]), with the calling task as\nwriter. Staged batches are ordinary batches.",
             "`stage!(sim, \"face\" => value, …)` ([§11.3][s11-3]), from any task, the calling\ntask included. Staged batches are ordinary batches."),
 # B-7 Appendix B
 ("spec.md", "data-driven binding, and the standard GUI binding is the shipped greedy one",
             "data-driven binding, and the standard GUI binding is the greedy one"),
 # B-7 greedy claim
 ("spec.md", "legal and reported (`EmptyGreedyClaim`), and the shipped GUI binding is the\nshipped instance ([§11.3][s11-3], [§11.6][s11-6]).",
             "legal and reported (`EmptyGreedyClaim`), and the standard GUI binding is its\ninstance ([§11.3][s11-3], [§11.6][s11-6])."),
 # B-7 should_abort
 ("spec.md", "advisory in one deployment and decisive in another. The shipped GUI\nattaches with `true` ([§11.6][s11-6], [§12.4][s12-4]).",
             "advisory in one deployment and decisive in another ([§11.6][s11-6],\n[§12.4][s12-4])."),
 # B-8
 ("spec.md", "        mark_dead!(entry)                 # from boundary zero; no task is spawned\n",
             " " * 42 + "# no dead-marking: no task is spawned (§12.2)\n"),
 # B-9
 ("spec.md", "`AbstractDevice` under one authoring contract (`init!`/`loop`/`shutdown!`,\noptional `unblock!`) and one handle. Input-only and",
             "`AbstractDevice` under one authoring contract (a mandatory `loop`, and\noptional `init!`, `shutdown!` and `unblock!` hooks) and one handle. Input-only and"),
 # B-11
 ("spec.md", "- **`CheckpointMismatch`** ([§11.5][s11-5], [§12.6][s12-6], [§12.7][s12-7]).",
             "- **`CheckpointMismatch`** ([§12.6][s12-6], [§12.7][s12-7])."),
 ("spec.md", "- **`ReplaySchemaMismatch`** ([§11.5][s11-5], [§12.7][s12-7]). Error ·",
             "- **`ReplaySchemaMismatch`** ([§12.7][s12-7]). Error ·"),
 # B-14 checkpoint (rewrap)
 ("spec.md", "guard priors, `t` and `t₀`, and the fingerprint. It is not a condition and\nhas no algebra (",
             "guard priors, `t` and `t₀`, the fingerprint and the deployment. It is not a\ncondition and has no algebra ("),
 # B-14 framework status
 ("spec.md", "plus, per writer, this boundary's drained diagnostics (`recent`), the counts",
             "plus, per writer, the diagnostics the frame's drain took (`recent`), the counts"),
]
texts = {}
for f, o, n in E:
    if f not in texts:
        texts[f] = open(D + f, encoding="utf-8").read()
for f, o, n in E:
    c = texts[f].count(o)
    if c != 1:
        sys.exit(f"MATCH {c} in {f}: {o[:70]!r}")
    texts[f] = texts[f].replace(o, n)
for f, t in texts.items():
    open(D + f, "w", encoding="utf-8").write(t)
print("applied", len(E))
