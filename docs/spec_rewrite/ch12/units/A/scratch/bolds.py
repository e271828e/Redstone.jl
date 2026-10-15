import re, sys
lines = open(sys.argv[1]).read().split("\n")
ents = set(sys.argv[2].split(","))
lo, hi = int(sys.argv[3]), int(sys.argv[4])  # skip range (1-based inclusive)
txt = "\n".join(l if not (lo <= i+1 <= hi) else "" for i, l in enumerate(lines))
# map offsets to line numbers
starts=[0]
for l in txt.split("\n"): starts.append(starts[-1]+len(l)+1)
import bisect
flat = txt
for m in re.finditer(r'\*\*(.+?)\*\*', flat, re.S):
    rest = flat[m.end():m.end()+600]
    end = re.search(r'\.(\s|$)', rest)
    sent = rest[:end.start()+1] if end else rest
    ds = set(re.findall(r'D-\d{3}', m.group(1)+sent))
    hit = ds & ents
    if hit:
        ln = bisect.bisect_right(starts, m.start())
        print(ln, sorted(hit), re.sub(r'\s+',' ',m.group(1))[:90])
