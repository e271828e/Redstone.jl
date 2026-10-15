import re,sys
def rd(s):
    s=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',s)
    return re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s)
for f in sys.argv[1:]:
    L=open(f).read().split('\n'); inc=False
    for i,l in enumerate(L):
        if l.startswith('```'): inc=not inc; continue
        if inc or l.startswith('|') or l.startswith('#'): continue
        r=rd(l)
        if len(r)>80: print(f,i+1,'WIDE',len(r),r)
        if i+1<len(L) and l.strip() and L[i+1].strip() and not L[i+1].lstrip().startswith(('- ','|','```','#')):
            nw=rd(L[i+1]).strip().split(' ')[0]
            if len(r)+1+len(nw)<=80: print(f,i+1,'SHORT',len(r),'+',len(nw),r)
