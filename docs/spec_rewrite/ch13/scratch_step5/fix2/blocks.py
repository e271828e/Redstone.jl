import sys,re
path=sys.argv[1]; ids=set(sys.argv[2].split(',')); adds=sys.argv[3:] if len(sys.argv)>3 else []
L=open(path).read().split('\n'); cur=[]; start=1; n=0
def flush():
    global n
    if not cur: return
    if any(l.startswith('added:') for l in cur):
        if any(a in cur[0] for a in adds): print(f"[{start}] ADDED"); print('\n'.join(cur)); print()
        return
    n+=1
    if f"C-{n:03d}" in ids: print(f"[{start}] C-{n:03d}"); print('\n'.join(cur)); print()
for i,l in enumerate(L+[''],1):
    if l.startswith('#'): continue
    if not l.strip():
        flush(); cur=[]; continue
    if not cur: start=i
    cur.append(l)
