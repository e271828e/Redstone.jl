"""Replay chapter_fixes_2.md on e16a63c, then ruled_edits.md on the result."""
import re, sys, os
H = os.path.dirname(os.path.abspath(__file__))
CH = os.path.abspath(os.path.join(H, "..", ".."))
UNITS = ["F", "G1", "G2", "H", "J"]

def blocks(md):
    return re.findall(r"```text\n(.*?)\n```", md, re.S)

def parse_fixes():
    md = open(os.path.join(CH, "chapter_fixes_2.md")).read()
    md = md.split("## Inventory changes")[0]
    out = []
    for sec in re.split(r"\n### ", md)[1:]:
        head = sec.split("\n")[0]
        n = int(head.split(".")[0])
        units = re.findall(r"unit (\w+)", head)
        b = blocks(sec)
        out.append((n, head, units, b))
    return out

def ws_re(s):
    toks = s.split()
    return r"\s+".join(re.escape(t) for t in toks)

def apply_ws(text, old, new, tag):
    pat = re.compile(ws_re(old))
    hits = pat.findall(text)
    if len(hits) != 1:
        print(f"  {tag}: {len(hits)} hits");
        if not hits: return text
    return pat.sub(lambda m: new, text, count=1)

def main():
    texts = {u: open(os.path.join(H, "e16a63c", u, "new.md")).read() for u in UNITS}
    for n, head, us, b in parse_fixes():
        if n == 41: continue
        u = us[0]
        if n == 40:
            old, new = b
            c = texts[u].count(old)
            print(f"  edit 40: {c} verbatim hits")
            texts[u] = texts[u].replace(old, new, 1)
            continue
        texts[u] = apply_ws(texts[u], b[0], b[1], f"edit {n} ({u})")
    for u in UNITS:
        open(os.path.join(H, "replay_fixes", u + ".md"), "w").write(texts[u])
    # ruled edits, verbatim on c3d69f1
    md = open(os.path.join(CH, "ruled_edits.md")).read()
    cur = {u: open(os.path.join(H, "c3d69f1", u, "new.md")).read() for u in UNITS}
    for sec in re.split(r"\n## ", md)[1:]:
        head = sec.split("\n")[0]
        u = re.findall(r"unit (\w+)", head)[0]
        if u not in UNITS: continue
        b = blocks(sec)
        if len(b) != 2: print("  ruled", head, "blocks", len(b)); continue
        c = cur[u].count(b[0])
        if c != 1: print(f"  ruled {head}: {c} hits")
        cur[u] = cur[u].replace(b[0], b[1], 1)
    for u in UNITS:
        open(os.path.join(H, "replay_ruled", u + ".md"), "w").write(cur[u])

main()
