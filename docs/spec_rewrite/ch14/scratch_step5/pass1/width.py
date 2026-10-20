import re,sys
lines=open(sys.argv[1],encoding='utf-8').read().split('\n')
lo,hi=int(sys.argv[2]),int(sys.argv[3])
incode=False
for i in range(lo-1,hi):
    l=lines[i]
    if l.startswith('```'): incode=not incode; continue
    if incode or l.startswith('|'): continue
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    r=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',r)
    r=r.replace('`','').replace('**','').replace('\\*','*')
    r=re.sub(r'(?<!\*)\*(?!\*)','',r)
    if len(r)>80: print(i+1,len(r),r)
