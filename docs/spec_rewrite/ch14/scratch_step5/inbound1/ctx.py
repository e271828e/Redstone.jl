import csv
R='/Users/miguel/.julia/dev/Redstone.jl/'
C=R+'docs/spec_rewrite/ch14/'
rows=list(csv.reader(open(C+'inbound.tsv'),delimiter='\t'))[1:]
T={'§14','§14.1','§14.2','§14.3','§14.4','§14.5','§14.6'}
cache={}
def lines(f):
    if f not in cache:
        if f in('spec.md','decisions.md'): p=C+'scratch_survey/h1/'+f
        elif f in('extensions.md','implementation.md','pending.md'): p=R+'docs/design/'+f
        else: p=R+'docs/design/'+f
        cache[f]=open(p).read().split('\n')
    return cache[f]
out=[];i=0;seen={}
for r in rows:
    if r[2] not in T: continue
    i+=1
    key=(r[0],r[1])
    out.append((i,r))
import collections
grp=collections.OrderedDict()
for i,r in out:
    grp.setdefault((r[0],int(r[1])),[]).append((i,r))
for (f,l),rs in grp.items():
    L=lines(f)
    tg=','.join(f"{i}:{r[2]}" for i,r in rs)
    e=rs[0][1][3]; fd=rs[0][1][4]
    print(f"=== {f}:{l} [{tg}] {e} {fd}")
    for k in range(max(0,l-3),min(len(L),l+2)):
        print(('>' if k==l-1 else ' ')+L[k][:240])
