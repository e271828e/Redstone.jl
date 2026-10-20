"""Carry engine.py's edits into units/<U>/claims.md, from the verified commit.
Run from docs/spec_rewrite/ch14 after engine.py:

    python3 scratch_step5/fix1/claims_fix.py
"""
import os, re, subprocess, sys
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "..", "checks"))
from norm import norm

exec(open(os.path.join(HERE, "edits.py")).read())
exec(open(os.path.join(HERE, "claims_manual.py")).read())   # MANUAL, ADDED, DROP_ADDED


def base(u):
    return subprocess.run(["git", "show", f"b187775:docs/spec_rewrite/ch14/units/{u}/claims.md"],
                          capture_output=True, text=True, check=True).stdout


def parse(text):
    """Blocks as lists of (key, value) or ('#', line)."""
    out, cur = [], []
    for line in text.split("\n"):
        if not line.strip():
            if cur: out.append(cur); cur = []
            continue
        if line.startswith("#"):
            cur.append(("#", line)); continue
        k, _, v = line.partition(":")
        cur.append((k.strip(), v.strip()))
    if cur: out.append(cur)
    return out


def get(b, k):
    for kk, v in b:
        if kk == k: return v
    return None


def put(b, k, v, after=None):
    for i, (kk, _) in enumerate(b):
        if kk == k:
            b[i] = (k, v); return
    idx = len(b)
    if after:
        for i, (kk, _) in enumerate(b):
            if kk == after: idx = i + 1
    b.insert(idx, (k, v))


def note(b, s):
    n = get(b, "note")
    put(b, "note", (n + " " if n else "") + s)


def dump(blocks, head):
    out = []
    for b in blocks:
        out.append("\n".join(v if k == "#" else f"{k}: {v}" for k, v in b))
    return "\n\n".join(out) + "\n"


for u in "AB":
    blocks = parse(base(u))
    spans = [(op[1], norm(op[3]), norm(op[4])) for op in OPS if op[0] == "span" and op[2] == u]
    for b in blocks:
        if get(b, "old") is None or get(b, "where"):
            continue
        cur = get(b, "new") or get(b, "old")
        done = []
        for fid, o, n in spans:
            if o and o in cur:
                cur = cur.replace(o, n); done.append(fid)
        oid = get(b, "old")
        extra = None
        for key, f in MANUAL.get(u, {}).items():
            if oid.startswith(key):
                cur = f.get("new", cur); extra = f
        if done or extra:
            put(b, "new", cur, after="old")
            if extra and "newcites" in extra: put(b, "newcites", extra["newcites"], after="tag")
            if extra and "note" in extra: note(b, "Step 5 fix1: " + extra["note"])
            elif done: note(b, "Step 5 fix1: " + ", ".join(dict.fromkeys(done)) + ".")
    blocks = [b for b in blocks if not (get(b, "added") and any(get(b, "added").startswith(d) for d in DROP_ADDED.get(u, [])))]
    for a in ADDED.get(u, []):
        blocks.append([("added", a)])
    open(f"units/{u}/claims.md", "w").write(dump(blocks, None))
