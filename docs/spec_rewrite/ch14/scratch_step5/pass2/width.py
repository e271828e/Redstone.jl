import re,sys
f,a,b=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
lines=open(f,encoding='utf-8').read().split('\n')
infence=False
for i in range(a-1,min(b,len(lines))):
    l=lines[i]
    if l.startswith('```'): infence=not infence; continue
    if infence or l.startswith('|'): continue
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    r=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',r)
    r=r.replace('**','').replace('`','')
    r=re.sub(r'(?<![\\*])\*(?!\*)','',r)
    if len(r)>80: print(i+1,len(r),r)
