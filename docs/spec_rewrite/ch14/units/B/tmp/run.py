exec(open('tmp/gen1.py').read())
exec(open('tmp/gen2.py').read())
exec(open('tmp/gen3.py').read())
out=["# Unit B (§14.4, §14.5, §14.6): claims", ""]
for e in E:
    if 'added' in e:
        out.append("added: "+e['added']); out.append(""); continue
    for k in ('old','new','tag','ruling','where','newcites','note'):
        if k in e: out.append(f"{k}: {e[k]}")
    out.append("")
open('claims.md','w').write("\n".join(out))
print(len(E))
