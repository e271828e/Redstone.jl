# Bold spans in spec.md (frozen base) with the D-citations of their sentence.
import re, sys
lines = open(sys.argv[1]).read().split("\n")
out = []
para, start = [], None
def flush():
    global para, start
    if not para: return
    text = " ".join(l.strip() for l in para)
    # sentence split
    sents = re.split(r"(?<=[.!?])\s+(?=[A-Z`*\[(])", text)
    for s in sents:
        for m in re.finditer(r"\*\*(.+?)\*\*", s):
            ds = sorted(set(re.findall(r"D-\d{3}", s)))
            out.append((start, m.group(1), ",".join(ds), s))
    para, start = [], None
infence = False
for i, l in enumerate(lines, 1):
    if l.startswith("<!-- citation link"): break
    if l.startswith("```"): infence = not infence; flush(); continue
    if infence: continue
    s = l.lstrip()
    if not l.strip() or s.startswith(("- ", "* ", "#", "|", ">")) or re.match(r"^\d+\. ", s):
        flush()
    if l.strip():
        if start is None: start = i
        para.append(l)
flush()
for st, b, ds, s in out:
    print(f"{st}\t{b}\t{ds}\t{s[:160]}")
