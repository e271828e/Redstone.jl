"""Split Stage M's output into one leads file per slice of a chapter group.

usage: python3 split_leads.py <worktree> <stage_m_dir> <slices.json> <out_dir>

slices.json maps a slice key to its sources, any of:
  "spec": [[first, last], ...]   design/spec.md line ranges
  "files": ["design/companions/x.md", ...]   whole Markdown files
  "log": ["D-064", ...]   ratified log entries (their line ranges are written too)
  "code": ["src/trim.jl", ...]   source files: docstring names, citations, signatures
Reads names.tsv, kwargs.tsv, citations.tsv and signatures.txt from stage_m_dir.
Run it at the same tip Stage M ran at, so the line numbers agree.
"""
import json, os, re, sys

wt, sm, spec_path, out = sys.argv[1:5]
slices = json.load(open(spec_path))
os.makedirs(out, exist_ok=True)

lines = open(os.path.join(wt, "design/log.md")).read().split("\n")
heads = [(i + 1, re.match(r"### (D-\d+)", l)[1]) for i, l in enumerate(lines) if l.startswith("### D-")]
entry = {}
for k, (ln, i) in enumerate(heads):
    entry[i] = (ln, heads[k + 1][0] - 1 if k + 1 < len(heads) else len(lines))

leads = {k: [] for k in slices}
def rows(name):
    return [r.split("\t") for r in open(os.path.join(sm, name)).read().strip().split("\n")[1:] if r]

for t, f, n, ls in rows("names.tsv"):
    for x in map(int, ls.split(",")):
        for k, s in slices.items():
            if f == "design/spec.md" and any(a <= x <= b for a, b in s.get("spec", [])):
                leads[k].append(f"names {t}: `{n}` at spec.md:{x}")
            elif f == "design/log.md":
                for d in s.get("log", []):
                    a, b = entry[d]
                    if a <= x <= b:
                        leads[k].append(f"names {t}: `{n}` at log.md:{x} ({d})")
            elif f in s.get("files", []):
                leads[k].append(f"names {t}: `{n}` at {f}:{x}")
            elif f in s.get("code", []):
                leads[k].append(f"names {t}: `{n}` in a docstring near {f}:{x}")
for t, ln, n, d in rows("kwargs.tsv"):
    for k, s in slices.items():
        if ln and any(a <= int(ln) <= b for a, b in s.get("spec", [])):
            leads[k].append(f"kwargs {t}: `{n}` keyword `{d}`, Appendix B at spec.md:{ln}")
for t, f, ln, c, d in rows("citations.tsv"):
    for k, s in slices.items():
        if f in s.get("code", []):
            leads[k].append(f"citation {t}: {c} at {f}:{ln} ({d})")
for l in open(os.path.join(sm, "signatures.txt")):
    m = re.match(r"(\w+\.jl):\d+", l)
    for k, s in slices.items():
        if m and any(os.path.basename(c) == m[1] for c in s.get("code", [])):
            leads[k].append("signature: " + l.strip())

for k, v in leads.items():
    with open(os.path.join(out, f"{k}.txt"), "w") as f:
        if slices[k].get("log"):
            f.write("# The entries of this slice, at log.md lines (heading to the line before the next heading)\n")
            for d in slices[k]["log"]:
                f.write(f"{d}: {entry[d][0]}-{entry[d][1]}\n")
            f.write("\n# Stage M leads\n")
        f.write("\n".join(v) + "\n" if v else "(none)\n")
    print(k, len(v))
