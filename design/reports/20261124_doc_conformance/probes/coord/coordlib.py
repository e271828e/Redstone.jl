# The coordinator's helpers for the audit's group args.
import json, os, re, subprocess
R = "/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance"
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
def cm(*files):
    L = open(f"{W}/design/code_map.md").read().split('\n')
    hs = [(i + 1, m[1]) for i, l in enumerate(L) if (m := re.match(r'### `([^`]+)`', l))]
    out = []
    for f in files:
        for k, (ln, n) in enumerate(hs):
            if n == f: out.append(f"{ln}-{(hs[k+1][0]-1) if k+1 < len(hs) else len(L)} ({f})")
    return ", ".join(out)
def write(group, tip, slices, leads):
    d = f"{R}/ledgers/{group}"; os.makedirs(d, exist_ok=True)
    json.dump(leads, open(f"{d}/slices.json", "w"), indent=1)
    json.dump(dict(group=group, W=W, tip=tip, R=R, slices=slices), open(f"{d}/args.json", "w"), indent=1, ensure_ascii=False)
    subprocess.run(["python3", f"{R}/probes/split_leads.py", W, f"{R}/ledgers/stage_m", f"{d}/slices.json", f"{R}/ledgers/stage_m/leads_{group}"])
def tip():
    return subprocess.check_output(["git", "-C", W, "rev-parse", "--short=8", "HEAD"]).decode().strip()
def hl(prefix):
    """Line of the first spec heading starting with prefix, e.g. '## 9.' or '#### Rendering'."""
    for i, l in enumerate(open(f"{W}/design/spec.md")):
        if l.startswith(prefix): return i + 1
    raise KeyError(prefix)
def logs(ch):
    return json.load(open(os.path.join(os.path.dirname(__file__), "logby.json")))[ch]
