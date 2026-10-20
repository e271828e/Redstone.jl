"""Apply half 1's ruled edits (B1, B2, B3, B5, B6) to units A and B as
chapter_fixes_1.md left them, and write ruled_edits_1.md. Run once from
docs/spec_rewrite/ch14:

    python3 scratch_ruled/h1/apply.py
"""
import re, subprocess, sys, os
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "checks"))
from norm import render


W = 80
PROT = re.compile(r'\[[^\]]*\]\([^)]*\)|\[[^\]]*\]\[[^\]]*\]|`[^`]*`|\$[^$]*\$')


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

OPS = [
    ("raw", "B1", "B", "### 14.4 One plan, two ways to apply it",
     "### 14.4 Two ways to apply a resolved condition"),
    ("span", "B2", "B",
     "ever hold live stores ([§11.2][s11-2]). That inspection is the [replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the trace.",
     "ever hold live stores ([§11.2][s11-2]). That inspection is the [replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the trace. Of these holders, only the service evaluations' readers take a store selector."),
    ("span", "B2", "B",
     "which today are the services' ([§14.7][s14-7], [§14.10][s14-10]).",
     "which today are the services' ([§14.8][s14-8], [§14.10][s14-10])."),
    ("span", "B3", "B",
     "Snapshot inspection reads a cell by path and port name instead ([§11.2][s11-2]).",
     "Snapshot inspection ([§11.2][s11-2]) reads a cell by path and port name instead."),
    ("span", "B5", "A",
     "**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]),",
     "**The blend rejection is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]),"),
    ("span", "B6", "B",
     "**A commit-fired handler is not the only mover**, and the second one is unconditional ([D-155][d-155]).",
     "A commit-fired handler is not the only mover. **Projection is the second, and it is unconditional** ([D-155][d-155])."),
]

texts = {u: open(f"units/{u}/new.md").read() for u in "AB"}
for kind, fid, u, *args in OPS:
    texts[u] = globals()[kind](texts[u], fid, u, *args)
for u in "AB":
    open(f"units/{u}/new.md", "w").write(texts[u])

with open("ruled_edits_1.md", "w") as f:
    f.write("# Chapter 14, step 6: the ruled edits, half 1 (units A and B)\n\n"
            "Each entry gives the ruling, the unit, and the old and new text of the edited\n"
            "heading or paragraph, verbatim. Replay them in order on the units as\n"
            "`chapter_fixes_1.md` left them: an entry's old text is the file as the entries\n"
            "before it left it, and occurs once there. Every edited paragraph or bullet is\n"
            "rewrapped to 80 rendered columns (link markup collapsed), so the old and new\n"
            "blocks are whole paragraphs. A fenced block holds the text verbatim, with no\n"
            "added newline.\n\n")
    for n, (fid, u, old, new) in enumerate(LOG, 1):
        f.write(f"## {n}. {fid}, unit {u}\n\nOld:\n\n````text\n{old}\n````\n\nNew:\n\n````text\n{new}\n````\n\n")

for u in "AB":
    for n, l in enumerate(texts[u].split("\n"), 1):
        if l.startswith(("|", "  |", "#", "```")) or "```" in l: continue
        if len(render(l)) > W: print(f"{u}:{n} {len(render(l))} cols")
print(f"{len(LOG)} log entries")
