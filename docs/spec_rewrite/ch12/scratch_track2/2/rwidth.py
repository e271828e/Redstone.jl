import re,sys
def render(l):
    l=re.sub(r'<a id="[^"]*"></a>','',l)
    l=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',l)
    l=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    return l.replace('**','').replace('`','')
f=sys.argv[1]; a=int(sys.argv[2]); b=int(sys.argv[3]); lim=int(sys.argv[4]) if len(sys.argv)>4 else 80
L=open(f).read().split('\n')
incode=False
for n in range(a,b+1):
    l=L[n-1]
    if l.startswith('```'): incode=not incode; continue
    if incode or l.startswith('|'): continue
    w=len(render(l))
    if w>lim: print(n,w,render(l))
