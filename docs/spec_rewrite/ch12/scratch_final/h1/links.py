import re, sys, collections
for f in sys.argv[1:]:
    txt = open(f).read()
    secs = re.split(r'^(?=### )', txt, flags=re.M)
    for s in secs:
        head = s.split('\n')[0][:30]
        c = collections.Counter(re.findall(r'\]\((#g-[^)]+)\)', s))
        d = {k: v for k, v in c.items() if v > 1}
        if d: print(f.split('/')[-1], head, d)
