import re,sys
lines=open(sys.argv[1]).read().split('\n')
a,b=int(sys.argv[2]),int(sys.argv[3])
infence=False
for i in range(a-1,b):
    l=lines[i]
    if l.startswith('```'): infence=not infence; 
    r=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',l)
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',r)
    r=r.replace('**','').replace('`','') if not infence else r
    r2=re.sub(r'(?<![\w*])\*([^*]+)\*',r'\1',r) if not infence else r
    n=len(r2)
    if n>80: print(i+1,n,'FENCE' if infence else '',l[:100])
