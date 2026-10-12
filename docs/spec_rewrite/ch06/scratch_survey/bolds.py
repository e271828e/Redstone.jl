# list bold spans in a spec line range with the D-citations of their sentence
import re, sys
lines = open("/Users/miguel/.julia/dev/Redstone.jl/docs/design/spec.md").read().split("\n")
a, b = int(sys.argv[1]), int(sys.argv[2])
want = set(sys.argv[3].split(",")) if len(sys.argv) > 3 else None
# paragraphs
paras, cur, start = [], [], None
incode = False
for n in range(a, b + 1):
    l = lines[n - 1]
    if l.startswith("```"):
        incode = not incode
        if cur: paras.append((start, " ".join(cur))); cur = []
        continue
    if incode: continue
    s = l.strip()
    if not s or s.startswith(("- ", "|", "#")) or re.match(r"^\d+\. ", s):
        if cur: paras.append((start, " ".join(cur))); cur = []
        if not s: continue
    if not cur: start = n
    cur.append(s)
if cur: paras.append((start, " ".join(cur)))
for start, p in paras:
    sents = re.split(r"(?<=[.!?])\s+(?=[A-Z`*\[(])", p)
    for s in sents:
        for m in re.finditer(r"\*\*(.+?)\*\*", s):
            ds = set(re.findall(r"D-\d{3}", s))
            if want is None or ds & want:
                print(f"{start}\t{','.join(sorted(ds))}\t**{m.group(1)}**\t|| {s[:220]}")
