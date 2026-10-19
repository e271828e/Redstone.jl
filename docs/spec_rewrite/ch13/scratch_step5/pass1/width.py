import re,sys
lines=open(sys.argv[1],encoding='utf-8').read().split('\n')
a,b=int(sys.argv[2]),int(sys.argv[3])
infence=False
for i in range(a-1,b):
    s=lines[i]
    if s.startswith('```'): infence=not infence; continue
    if infence: continue
    r=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s)
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',r)
    r2=r.replace('`','').replace('**','').replace('*','')
    if len(r2)>80: print(i+1,len(r2),len(r),s[:60])
