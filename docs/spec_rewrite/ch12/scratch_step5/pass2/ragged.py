import re,sys
lines=open(sys.argv[1]).read().split('\n')
a,b=int(sys.argv[2]),int(sys.argv[3])
def rend(l):
    r=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',l)
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',r)
    return r.replace('**','').replace('`','')
infence=False
for i in range(a-1,b):
    l=lines[i]
    if l.startswith('```'): infence=not infence; continue
    if infence or l.startswith('|') or l.startswith('#') or not l.strip(): continue
    nxt=lines[i+1]
    if not nxt.strip() or nxt.startswith(('- ','|','#','```')): continue
    w=rend(nxt).split()[0]
    if len(rend(l))+1+len(w)<=78: print(i+1,len(rend(l)),repr(l[:90]))
