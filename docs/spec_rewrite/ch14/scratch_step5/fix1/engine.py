"""Apply half 1's editorial fixes to units A and B from the verified commit,
and write the replayable log. Run from docs/spec_rewrite/ch14:

    python3 scratch_step5/fix1/engine.py
"""
import re, subprocess, sys, os
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "checks"))
from norm import render

VERIFIED = "b187775"
W = 80
PROT = re.compile(r'\[[^\]]*\]\([^)]*\)|\[[^\]]*\]\[[^\]]*\]|`[^`]*`|\$[^$]*\$')


def base(u):
    return subprocess.run(["git", "show", f"{VERIFIED}:docs/spec_rewrite/ch14/units/{u}/new.md"],
                          capture_output=True, text=True, check=True).stdout


def units_of(t):
    """(start, end, prefix) of every prose unit: blank-line blocks, split at list items."""
    out, pos = [], 0
    lines = t.split("\n")
    offs, o = [], 0
    for l in lines:
        offs.append(o); o += len(l) + 1
    i = 0
    while i < len(lines):
        if not lines[i].strip():
            i += 1; continue
        j = i
        while j < len(lines) and lines[j].strip():
            j += 1
        k = i
        while k < j:
            m = k + 1
            while m < j and not lines[m].startswith("- "):
                m += 1
            first = lines[k]
            pre = "- " if first.startswith("- ") else ("  " if first.startswith("  ") else "")
            out.append((offs[k], offs[m - 1] + len(lines[m - 1]), pre))
            k = m
        i = j
    return out


def flex(s):
    return re.compile(r'\s+'.join(re.escape(w) for w in s.split()))


def find_unit(t, needle):
    ms = list(flex(needle).finditer(t))
    if len(ms) != 1:
        raise SystemExit(f"needle matches {len(ms)} times: {needle[:70]!r}")
    m = ms[0]
    for s, e, p in units_of(t):
        if s <= m.start() and m.end() <= e:
            return s, e, p, m
    raise SystemExit(f"needle spans units: {needle[:70]!r}")


def flatten(raw, pre):
    ls = raw.split("\n")
    ls[0] = ls[0][len(pre):]
    return " ".join(l.strip() for l in ls).strip()


def wrap(flat, pre):
    rest = "  " if pre else ""
    prot = [False] * len(flat)
    for m in PROT.finditer(flat):
        for k in range(m.start(), m.end()): prot[k] = True
    toks, cur = [], ""
    for k, ch in enumerate(flat):
        if ch == " " and not prot[k]:
            if cur: toks.append(cur)
            cur = ""
        else:
            cur += ch
    if cur: toks.append(cur)
    lines, line, empty = [], pre, True
    for tk in toks:
        cand = line + tk if empty else line + " " + tk
        if not empty and len(render(cand)) > W:
            lines.append(line); line = rest + tk
        else:
            line = cand
        empty = False
    lines.append(line)
    for l in lines[1:]:
        if re.match(r'\s*(- |#|> |\d+\. |\| )', l):
            raise SystemExit(f"wrap would start a line with markup: {l!r}")
    return "\n".join(lines)


LOG = []


def log(fid, u, old, new, t):
    if t.count(old) != 1:
        raise SystemExit(f"{fid}: logged old text not unique ({t.count(old)})")
    LOG.append((fid, u, old, new))
    return t.replace(old, new)


def span(t, fid, u, old, new):
    s, e, p, _ = find_unit(t, old)
    raw = t[s:e]
    flat = flatten(raw, p)
    o = " ".join(old.split()); n = " ".join(new.split())
    if flat.count(o) != 1:
        raise SystemExit(f"{fid}: span not once in unit: {o[:70]!r}")
    return log(fid, u, raw, wrap(flat.replace(o, n), p), t)


def rewrap(t, fid, u, needle):
    s, e, p, _ = find_unit(t, needle)
    raw = t[s:e]
    return log(fid, u, raw, wrap(flatten(raw, p), p), t)


def split(t, fid, u, needle):
    s, e, p, _ = find_unit(t, needle)
    raw = t[s:e]
    flat = flatten(raw, p); nd = " ".join(needle.split())
    i = flat.index(nd)
    return log(fid, u, raw, wrap(flat[:i].strip(), p) + "\n\n" + wrap(flat[i:], p), t)


def delete(t, fid, u, needle):
    s, e, p, _ = find_unit(t, needle)
    nxt_end = t.index("\n", e + 2)
    old = t[s:nxt_end]
    assert t[e:e + 2] == "\n\n", fid
    return log(fid, u, old, t[e + 2:nxt_end], t)


def insert_after(t, fid, u, anchor, flat, pre=""):
    return log(fid, u, anchor, anchor + "\n\n" + wrap(" ".join(flat.split()), pre), t)


def replace_units(t, fid, u, first, last, paras):
    s1, _, _, _ = find_unit(t, first)
    _, e2, _, _ = find_unit(t, last)
    return log(fid, u, t[s1:e2], "\n\n".join(wrap(" ".join(x.split()), "") for x in paras), t)


def raw(t, fid, u, old, new):
    return log(fid, u, old, new, t)


exec(open(os.path.join(os.path.dirname(__file__), "edits.py")).read())

texts = {"A": base("A"), "B": base("B")}
for op in OPS:
    kind, fid, u, *args = op
    texts[u] = globals()[kind](texts[u], fid, u, *args)
for u in "AB":
    open(f"units/{u}/new.md", "w").write(texts[u])

with open("chapter_fixes_1.md", "w") as f:
    f.write("# Chapter 14, step 5: editorial fixes, half 1 (units A and B)\n\n")
    f.write(f"Applied by fix1 to `units/A/new.md` and `units/B/new.md` from commit\n"
            f"`{VERIFIED}`. Each entry replaces its old text, which occurs once in the\n"
            "unit's file at that point, by its new text; replay them in order. A\n"
            "fenced block holds the text verbatim, with no added newline.\n\n")
    for n, (fid, u, old, new) in enumerate(LOG, 1):
        f.write(f"## {n}. {fid}, unit {u}\n\nOld:\n\n````text\n{old}\n````\n\nNew:\n\n````text\n{new}\n````\n\n")
    f.write(NOTES)

for u in "AB":
    for n, l in enumerate(texts[u].split("\n"), 1):
        if l.startswith(("|", "  |", "#", "```")) or "```" in l: continue
        if len(render(l)) > W: print(f"{u}:{n} {len(render(l))} cols")
print(f"{len(LOG)} log entries")
