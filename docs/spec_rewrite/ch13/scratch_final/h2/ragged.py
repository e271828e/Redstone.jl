import re,sys
exec(open('scratch_final/h2/width.py').read().split('for f in')[0])
for f in sys.argv[1:]:
    L=open(f).read().split('\n'); code=False
    for i,l in enumerate(L):
        if l.startswith('```'): code=not code; continue
        if code or not l.strip() or l.startswith('#'): continue
        if i+1<len(L) and L[i+1].strip() and not L[i+1].startswith(('```','- ','#')):
            r=rend(l); nxt=L[i+1].split()[0] if L[i+1].split() else ''
            if len(r)+1+len(rend(nxt))<=80: print(f,i+1,len(r),'| next word:',rend(nxt))
