import sys
R = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/"
edits = [
 ("B-29", "spec.md",
  "- **The write-surface and entry violations** ([§11.3][s11-3]), all raised at",
  "- **The write-surface and entry violations** (§11.3, §11.4), all raised at"),
 ("B-30", "spec.md",
  "what the device may write rather than what it will | [§11.4][s11-4] |",
  "what the device may write rather than what it will | §11.3, §11.4 |"),
 ("B-31", "spec.md",
  "Declarations, error messages, [device](#g-device)/[trace](#g-trace) addressing ([§11.3][s11-3]) and the HDF5 log\n"
  "tree share it verbatim. A device is any attached participant outside the loop,\n"
  "and the trace is the primary record of a session. [Container children](#g-container-children) (the\n",
  "Declarations, error messages, inspection reads of the snapshot and the log\n"
  "(§11.2) and the HDF5 log tree share it verbatim. [Container children](#g-container-children) (the\n"),
 ("B-32", "companions/flight_case_studies.md",
  "- `attach!` of the GUI under the greedy binding, then\n"
  "  `run!(sim; pace = 1, t_end = 1000)`, makes a\n"
  "  greedy claim over every unclaimed face and settles\n"
  "  liveness with zero configuration, both at run start against the\n"
  "  frozen roster ([§11.3][s11-3]). Axis\n",
  "- `attach!` of the GUI under the greedy binding makes a greedy claim over\n"
  "  every unclaimed face at the attach point (§11.3). Then\n"
  "  `run!(sim; pace = 1, t_end = 1000)` settles liveness with zero\n"
  "  configuration at run start, against the frozen roster (§11.7). Axis\n"),
 ("B-33", "implementation.md",
  "Spec: §10.7, §11.3, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,",
  "Spec: §10.7, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,"),
 ("B-34 Appendix B", "spec.md",
  "| `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2] |",
  "| `reads(b)` / `map_output(nt, b)` | — | the output side | [§14.4][s14-4], [§11.2][s11-2], §11.6 |"),
 ("B-34 walkthrough", "companions/frame_walkthrough.md",
  "counter ([§11.2][s11-2], [D-230][d-230]).",
  "counter (§12.3, [D-230][d-230])."),
 ("B-34 case study", "companions/flight_case_studies.md",
  "The GUI peek-batch ([§11.7][s11-7]) therefore survives as",
  "The GUI peek-batch (D-047) therefore survives as"),
 ("B-34 glossary", "spec.md",
  "([§11.1][s11-1]). Distinct from a *boundary* ([§D.4][sD-4]), and from the",
  "(§10.1, §11.1). Distinct from a *boundary* ([§D.4][sD-4]), and from the"),
]
texts = {}
for tag, f, old, new in edits:
    t = texts.setdefault(f, open(R+f, encoding="utf-8").read())
    n = t.count(old)
    if n != 1:
        sys.exit(f"{tag}: old text matches {n} times")
for tag, f, old, new in edits:
    texts[f] = texts[f].replace(old, new, 1)
for f, t in texts.items():
    open(R+f, "w", encoding="utf-8").write(t)
print("ok")
