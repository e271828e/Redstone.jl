import sys
R="/Users/miguel/.julia/dev/Redstone.jl/"
src={"spec.md":R+"docs/spec_rewrite/ch12/scratch_survey/h1/spec.md","decisions.md":R+"docs/spec_rewrite/ch12/scratch_survey/h1/decisions.md"}
cache={}
def lines(f):
    if f not in cache:
        p=src.get(f,R+"docs/design/"+f)
        cache[f]=open(p).read().split("\n")
    return cache[f]
rows=[l.rstrip("\n").split("\t") for l in open(R+"docs/spec_rewrite/ch12/inbound.tsv")][1:]
n=0
for r in rows:
    if r[2] not in ("§12.5","§12.6","§12.7"): continue
    n+=1
    f,ln=r[0],int(r[1]); L=lines(f)
    a=ln-1
    while a>0 and L[a-1].strip()!="" and ln-a<6: a-=1
    b=ln-1
    while b<len(L)-1 and L[b+1].strip()!="" and b-ln<5: b+=1
    print(f"=== #{n} {f}:{ln} {r[2]} {r[3]} {r[4]}")
    for i in range(a,b+1):
        print(("> " if i==ln-1 else "  ")+L[i])
