import re, sys, difflib, pathlib
D = pathlib.Path(__file__).parent
CH = D.parent.parent

def rendered(line):
    s = re.sub(r"\[([^\]]+)\]\((#[^)]+)\)", r"\1", line)
    s = re.sub(r"\[([^\]]+)\]\[[^\]]+\]", r"\1", s)
    s = s.replace("`", "").replace("*", "")
    return len(s)

def entries(path):
    text = (CH / path).read_text()
    parts = re.split(r"^## ", text, flags=re.M)[1:]
    for p in parts:
        head = p.split("\n", 1)[0]
        notes = [l for l in p.split("\n")[1:] if l and not l.startswith(("Old:", "New:", "````"))]
        blocks = re.findall(r"````text\n(.*?)````", p, flags=re.S)
        yield head, blocks, p

for path in ["chapter_fixes_2.md", "ruled_edits_2.md"]:
    for head, blocks, p in entries(path):
        if len(blocks) != 2:
            continue
        old, new = blocks
        pre = p.split("Old:")[0].split("\n", 1)[1].strip()
        ow, nw = old.split(), new.split()
        sm = difflib.SequenceMatcher(a=ow, b=nw, autojunk=False)
        out = []
        for op, a1, a2, b1, b2 in sm.get_opcodes():
            if op == "equal":
                continue
            ctx_l = " ".join(ow[max(0, a1 - 4):a1])
            ctx_r = " ".join(ow[a2:a2 + 4])
            out.append(f"   …{ctx_l} [-{' '.join(ow[a1:a2])}-]{{+{' '.join(nw[b1:b2])}+}} {ctx_r}…")
        widths = [(i, rendered(l)) for i, l in enumerate(new.split("\n")) if rendered(l) > 80]
        lines = new.rstrip("\n").split("\n")
        short = [i for i, l in enumerate(lines[:-1]) if rendered(l) + len(lines[i + 1].split()[0]) + 1 <= 80 and not lines[i+1].lstrip().startswith(("-", "|", "#"))] if len(lines) > 1 else []
        print(f"== {path[:13]} {head}")
        if pre:
            print("   NOTE:", pre.replace("\n", " "))
        print("\n".join(out) if out else "   (no word change)")
        if widths:
            print("   WIDE:", widths)
        if short:
            print("   RAGGED (next word fits):", short)
