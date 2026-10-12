import re,sys
lines=open(sys.argv[1]).read().split('\n')
lo,hi=int(sys.argv[2]),int(sys.argv[3])
want=set(sys.argv[4].split(','))
# paragraphs with start line
paras=[];cur=[];start=None
for i,l in enumerate(lines,1):
    if i<lo or i>hi: continue
    if l.strip()=='' :
        if cur: paras.append((start,' '.join(cur))); cur=[]
    else:
        if not cur: start=i
        cur.append(l.strip())
if cur: paras.append((start,' '.join(cur)))
for s,p in paras:
    for m in re.finditer(r'\*\*(.+?)\*\*',p):
        rest=p[m.end():]
        e=re.search(r'\.(\s|$)',rest)
        sent=p[m.start():m.end()+(e.end() if e else len(rest))]
        ds=set(re.findall(r'D-(\d{3})',sent))
        if ds & want or 'all' in want:
            print(s, sorted(ds), sent[:300])
