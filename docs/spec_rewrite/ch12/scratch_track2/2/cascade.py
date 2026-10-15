import re,sys
def render(l):
    l=re.sub(r'<a id="[^"]*"></a>','',l)
    l=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',l)
    l=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    return l.replace('**','').replace('`','')
f=sys.argv[1]; lines=[int(x) for x in sys.argv[2:]]
L=open(f).read().split('\n')
def para_cont(s): return s.strip()!='' and not re.match(r'\s*([-*>|#]|\d+\.)\s',s) and not s.startswith('```')
for n in sorted(lines,reverse=True):
    i=n-1
    while len(render(L[i]))>80:
        toks=L[i].split(' ')
        # move tokens until fits
        moved=[]
        while len(render(' '.join(toks)))>80:
            moved.insert(0,toks.pop())
        L[i]=' '.join(toks)
        if i+1<len(L) and para_cont(L[i+1]):
            L[i+1]=' '.join(moved)+' '+L[i+1]
        else:
            L.insert(i+1,' '.join(moved))
        i+=1
open(f,'w').write('\n'.join(L))
