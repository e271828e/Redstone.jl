import sys
u = sys.argv[1]; ids = set(int(x) for x in sys.argv[2:])
L = open(f"/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/units/{u}/claims.md").read().split("\n")
cur, start, n = [], None, 0
def flush():
    global n
    if not cur: return
    body = [x for x in cur if not x.startswith("#")]
    if body and not body[0].startswith("added:"):
        n += 1
        if n in ids: print(f"--- C-{n:03d} (line {start})"); print("\n".join(cur))
for i, l in enumerate(L + [""], 1):
    if l.startswith("#") and not cur: continue
    if not l.strip():
        flush(); cur = []; continue
    if not cur: start = i
    cur.append(l)
