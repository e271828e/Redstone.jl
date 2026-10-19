import re, sys
want = set(sys.argv[2].split(","))
text = open(sys.argv[1]).read()
# track line numbers and section headings
lines = text.split("\n")
sec = ""
paras = []
buf = []; start = 0
for i, l in enumerate(lines, 1):
    if l.startswith("#"):
        sec = l
    if not l.strip():
        if buf: paras.append((start, sec, " ".join(buf))); buf = []
        continue
    if not buf: start = i
    buf.append(l)
if buf: paras.append((start, sec, " ".join(buf)))
for start, sec, p in paras:
    for m in re.finditer(r'\*\*(.+?)\*\*', p):
        rest = p[m.end():]
        end = re.search(r'\.(\s|$)', rest)
        seg = rest[: end.start()+1] if end else rest
        ds = set(re.findall(r'D-\d{3}', m.group(1) + seg))
        hit = ds & want
        if hit:
            print(start, sec[:50], sorted(hit), "|", m.group(1)[:90])
