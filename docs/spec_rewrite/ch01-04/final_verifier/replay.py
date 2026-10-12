import re, subprocess, sys, os
ROOT = "/Users/miguel/.julia/dev/Redstone.jl"
CH = ROOT + "/docs/spec_rewrite/ch01-04"
OUT = CH + "/final_verifier/replayed"
log = open(CH + "/chapter_fixes.md").read()
heads = list(re.finditer(r"^### (E\d+)\. (.*)$", log, re.M))
entries = []
for i, h in enumerate(heads):
    body = log[h.end(): heads[i+1].start() if i+1 < len(heads) else len(log)]
    blocks = re.findall(r"^~~~~\n(.*?)\n?^~~~~$", body, re.M | re.S)
    # re-extract precisely: lines between fences
    lines = body.split("\n"); blks = []; cur = None
    for ln in lines:
        if ln == "~~~~":
            if cur is None: cur = []
            else: blks.append("\n".join(cur)); cur = None
        elif cur is not None: cur.append(ln)
    assert len(blks) == 2, (h.group(1), len(blks))
    m = re.search(r"unit ([A-G])( rulings\.md)?\s*$", h.group(2))
    f = "rulings.md" if m.group(2) else "new.md"
    entries.append((h.group(1), m.group(1), f, blks[0], blks[1]))
files = {}
def get(u, f):
    k = (u, f)
    if k not in files:
        files[k] = subprocess.run(["git", "-C", ROOT, "show", f"f8afe64:docs/spec_rewrite/ch01-04/units/{u}/{f}"], capture_output=True, text=True, check=True).stdout
    return files[k]
ok = True
for eid, u, f, old, new in entries:
    t = get(u, f)
    if old.endswith("<end of file>"):
        o = old[:-len("<end of file>")]; n = new[:-len("<end of file>")]
        if not t.endswith(o): print(eid, "EOF old not found"); ok = False; continue
        files[(u, f)] = t[:len(t)-len(o)] + n; print(eid, u, f, "EOF ok"); continue
    c = t.count(old)
    if c != 1: print(eid, u, f, "count", c); ok = False
    if c >= 1: files[(u, f)] = t.replace(old, new, 1)
    print(eid, u, f, "ok" if c == 1 else "PROBLEM")
os.makedirs(OUT, exist_ok=True)
for (u, f), t in files.items():
    os.makedirs(f"{OUT}/{u}", exist_ok=True)
    open(f"{OUT}/{u}/{f}", "w").write(t)
    cur = open(f"{CH}/units/{u}/{f}").read()
    print("MATCH" if cur == t else "DIFFER", u, f)
for u in "ABCDEFG":
    if (u, "new.md") not in files: print("untouched", u)
