import re, sys
LINK = re.compile(r'\[([^\]]+)\]\((#[^)]*)\)|\[([^\]]+)\]\[([^\]]*)\]')
rw = lambda s: len(LINK.sub(lambda m: m.group(1) or m.group(3), s))
f = sys.argv[1]; lines = open(f).read().split("\n")
lo = next(i for i,l in enumerate(lines) if l.startswith("## 11. "))
hi = next(i for i,l in enumerate(lines) if l.startswith("## 12. "))
fence = False
for k in range(lo, hi):
    l = lines[k]
    if l.startswith("```"): fence = not fence; continue
    if not fence and rw(l) > 80: print(k+1, rw(l), l[:70])
