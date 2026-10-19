import re,sys
def sentences(path,a,b):
    L=open(path,encoding='utf-8').read().split('\n')
    out=[];buf=[];start=None
    for i in range(a-1,min(b,len(L))):
        s=L[i]
        if not s.strip() or s.startswith('#') or s.startswith('```') or s.startswith('<!--'):
            if buf: out.append((start,' '.join(buf)))
            buf=[];start=None;continue
        if start is None: start=i+1
        buf.append(s.strip())
    if buf: out.append((start,' '.join(buf)))
    res=[]
    for st,p in out:
        for sent in re.split(r'(?<=[.!?])\s+(?=[A-Z*`\[])',p):
            res.append((st,sent))
    return res
ds=sys.argv[1].split(',')
for path,a,b,tag in [('chapter_new.md',613,1392,'half2'),('scratch_survey/h1/spec.md',1,9908,'spec<13'),('scratch_survey/h1/spec.md',11142,20000,'spec>13')]:
    for st,s in sentences(path,a,b):
        if '**' not in s: continue
        for d in ds:
            if re.search(r'\['+d+r'\]',s):
                bolds=re.findall(r'\*\*(.+?)\*\*',s)
                print(tag,st,d,'|',' || '.join(b[:90] for b in bolds))
