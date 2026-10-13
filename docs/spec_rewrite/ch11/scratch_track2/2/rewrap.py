"""Reflow each over-80 line in chapter 11 through the end of its paragraph."""
import re, sys
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch11/scratch_final/h1")
W = 80
LINK = re.compile(r'\[([^\]]+)\]\((#[^)]*)\)|\[([^\]]+)\]\[([^\]]*)\]')
rw = lambda s: len(LINK.sub(lambda m: m.group(1) or m.group(3), s))
def tokens(s):
    out, i, cur = [], 0, ""
    while i < len(s):
        ch = s[i]
        if ch == " ":
            if cur: out.append(cur); cur = ""
            i += 1; continue
        if ch == "`":
            j = s.index("`", i + 1); cur += s[i:j + 1]; i = j + 1; continue
        if ch == "[":
            m = LINK.match(s, i)
            if m: cur += m.group(); i = m.end(); continue
        cur += ch; i += 1
    if cur: out.append(cur)
    return out
f = sys.argv[1]; skip = {int(x) for x in sys.argv[2:]}
lines = open(f).read().split("\n")
lo = next(i for i,l in enumerate(lines) if l.startswith("## 11. "))
hi = next(i for i,l in enumerate(lines) if l.startswith("## 12. "))
over, fence = [], False
for k in range(lo, hi):
    l = lines[k]
    if l.startswith("```"): fence = not fence; continue
    if not fence and rw(l) > W and k+1 not in skip: over.append(k)
for k in reversed(over):
    e = k + 1
    while e < len(lines) and lines[e].strip() and not lines[e].startswith(("```", "#")) \
            and not re.match(r'\s*(- |\d+\. )', lines[e]):
        e += 1
    ind = re.match(r'\s*', lines[k]).group()
    m = re.match(r'\s*(- |\d+\. )', lines[k]); lead = m.group() if m else ind
    text = " ".join(x.strip() for x in lines[k:e])
    out, cur = [], lead
    first = True
    for t in tokens(text[len(lead.strip()):] if m else text):
        if first: cur += t; first = False
        elif rw(cur + " " + t) <= W: cur += " " + t
        else: out.append(cur); cur = (" " * len(lead) if m else ind) + t
    out.append(cur)
    for l in out[1:]:
        assert not re.match(r'\s*([-+*>]|#+|\d+[.)])( |$)', l), l
    assert " ".join(x.strip() for x in out) == text
    print(f"reflow {k+1}-{e}: {e-k} -> {len(out)} lines")
    lines[k:e] = out
open(f, "w").write("\n".join(lines))
