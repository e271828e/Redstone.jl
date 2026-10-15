import re, sys
def rendered(s):
    s = re.sub(r'\[([^\]]+)\]\(#[^)]*\)', r'\1', s)
    s = re.sub(r'\[([^\]]+)\]\[[^\]]*\]', r'\1', s)
    return len(s)
L = open(sys.argv[1]).read().split('\n')
fence = False
for i, l in enumerate(L):
    if l.startswith('```'): fence = not fence; continue
    if fence:
        if len(l) > 80: print(i+1, 'CODE', len(l))
        continue
    if not l.strip() or l.startswith('#') or l.startswith('|'): continue
    r = rendered(l)
    if r > 80: print(i+1, 'LONG', r, l[:60]); continue
    if i+1 < len(L):
        n = L[i+1]
        if n.strip() and not n.startswith(('#','|','```','> ')) and not re.match(r'\s*(\d+\.|-) ', n):
            w = n.strip().split(' ')[0]
            # keep link text together
            m = re.match(r'\[[^\]]+\](?:\([^)]*\)|\[[^\]]*\])\S*', n.strip())
            if m: w = m.group()
            if rendered(l + " " + w) <= 72: print(i+1, 'SHORT', r, '+', rendered(w), repr(l[-30:]), repr(w))
