# Log-log interpolation of work at a given achieved error, from a probe's table output.
import sys, math
f, ecol, wcols, targets = sys.argv[1], sys.argv[2], sys.argv[3].split(','), [float(x) for x in sys.argv[4].split(',')]
rows = {}
hdr = None
for line in open(f):
    p = line.split()
    if p and p[0] == 'lab': hdr = p; continue
    if hdr and p and len(p) == len(hdr) and p[0] != 'reference:':
        rows.setdefault(p[0], []).append(dict(zip(hdr, p)))
def work_at(rs, target, wc):
    pts = sorted((math.log10(float(r[ecol])), math.log10(float(r[wc]))) for r in rs)
    lt = math.log10(target)
    for (e0, w0), (e1, w1) in zip(pts, pts[1:]):
        if e0 <= lt <= e1:
            return 10 ** (w0 + (lt - e0) / (e1 - e0) * (w1 - w0))
    return float('nan')
for wc in wcols:
    print(f"-- {wc} at achieved {ecol}, ratio to A")
    for t in targets:
        a = work_at(rows['A'], t, wc)
        s = f"  {t:.0e}: A {a:9.0f}"
        for lab in rows:
            if lab in ('A', "A'", 'C'): continue
            w = work_at(rows[lab], t, wc)
            s += f"  {lab} {w:9.0f} ({w/a:.3f})"
        print(s)
