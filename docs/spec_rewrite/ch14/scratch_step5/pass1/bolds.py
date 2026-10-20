import re,sys
def paras(path,lo,hi):
    L=open(path,encoding='utf-8').read().split('\n')
    out=[];cur=[];start=lo
    for i in range(lo-1,min(hi,len(L))):
        if L[i].strip()=='' or L[i].startswith('- ') :
            if cur: out.append((start,' '.join(cur)))
            cur=[];start=i+1
            if L[i].startswith('- '): cur=[L[i]];start=i+1
        else:
            if not cur: start=i+1
            cur.append(L[i])
    if cur: out.append((start,' '.join(cur)))
    return out
def bolds(path,lo,hi):
    res=[]
    for s,p in paras(path,lo,hi):
        for sent in re.split(r'(?<=[.!?])\s+(?=[A-Z*`\[])',p):
            if '**' in sent:
                ds=sorted(set(re.findall(r'D-\d{3}',sent)))
                for b in re.findall(r'\*\*(.+?)\*\*',sent):
                    res.append((s,ds,b))
    return res
mode=sys.argv[1]
if mode=='half1':
    for s,ds,b in bolds('chapter_new.md',1,725): print(s,ds,b[:70])
else:
    ents=set(sys.argv[2].split(','))
    for path,lo,hi in [('scratch_survey/h1/spec.md',1,11266),('scratch_survey/h1/spec.md',12731,20000),('chapter_new.md',726,1734)]:
        for s,ds,b in bolds(path,lo,hi):
            if ents & set(ds): print(path.split('/')[-1],s,ds,b[:80])
