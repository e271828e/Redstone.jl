import re,sys,os
B="/Users/miguel/.julia/dev/Redstone.jl"
C=B+"/docs/spec_rewrite/ch13/"
new=open(C+"chapter_new.md").read().splitlines()
old=open(C+"chapter_old.md").read().splitlines()
NR={"§13.5":(613,883),"§13.6":(884,955),"§13.7":(956,1390),"§13.8":(1250,1390)}
NR["§13.7"]=(956,1249)
OR={"§13.5":(535,762),"§13.6":(763,819),"§13.7":(820,1097),"§13.8":(1098,len(old))}
def sec(lines,r): return "\n".join(lines[r[0]-1:r[1]])
cache={}
def get(f):
    if f not in cache:
        p = C+"scratch_survey/h1/"+f if f in("spec.md","decisions.md") else B+"/docs/design/"+f
        cache[f]=open(p).read().splitlines()
    return cache[f]
rows=[l.rstrip("\n").split("\t") for l in open(C+"inbound.tsv")][1:]
mine=[r for r in rows if re.match(r"§13\.[5-8]$",r[2])]
out=open(C+"scratch_step5/inbound2/rows.txt","w")
for k,r in enumerate(mine,1):
    f,ln,cited,ent,fld=r[:5]; ln=int(ln)
    L=get(f)
    extra=""
    if fld=="Spec":
        d=ent.lower()
        inn = ("["+d+"]") in sec(new,NR[cited])
        ino = ("["+d+"]") in sec(old,OR[cited])
        extra=f"  [{ent} cited in new {cited}: {inn}; old: {ino}]"
        ctx=[L[ln-1]]
    else:
        ctx=L[max(0,ln-3):ln+2]
    out.write(f"=== #{k} {f}:{ln} {cited} {ent} {fld}{extra}\n")
    for c in ctx: out.write("    "+c+"\n")
print(len(mine))
