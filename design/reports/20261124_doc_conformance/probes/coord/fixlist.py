import csv,sys
g,tip,ids=sys.argv[1],sys.argv[2],sys.argv[3].split(',')
notes=dict(a.split('=',1) for a in sys.argv[4:])
rows={r['id']:r for r in csv.DictReader(open(f'{g}/findings.tsv'),delimiter='\t')}
out=[f"# {g}: rows for the fixer","",f"Each row: the site at the pinned tip {tip}, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.",""]
for i in ids:
    r=rows[i]
    out+=[f"## {i} ({r['class']}, clear={r['clear']})","",f"- at: `{r['at']}`",f"- claim: {r['claim']}",f"- evidence: {r['ver_evidence']}",f"- fix: {r['fix']}"]
    if r['ver_note']: out.append(f"- note: {r['ver_note']}")
    if i in notes: out.append(f"- coordinator: {notes[i]}")
    out.append("")
open(f'{g}/fix_list.md','w').write("\n".join(out)); print(len(ids),'rows')
