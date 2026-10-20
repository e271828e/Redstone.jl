import re,sys
F=sys.argv[1]
lines=open(F+'/docs/design/spec.md').read().split('\n')
# section of each line: nearest ## or ### heading with a number
sec=[None]*len(lines); cur=None
for i,l in enumerate(lines):
    m=re.match(r'^#{2,4} (\d+(?:\.\d+)?)\.? ',l) or re.match(r'^#{2,4} (\d+\.\d+)',l)
    if re.match(r'^## Appendix ([A-D])',l): cur='App'+re.match(r'^## Appendix ([A-D])',l).group(1)
    elif re.match(r'^## (\d+)\. ',l): cur=re.match(r'^## (\d+)\. ',l).group(1)
    elif re.match(r'^### (\d+\.\d+)',l): cur=re.match(r'^### (\d+\.\d+)',l).group(1)
    sec[i]=cur
C0,C1=13753,14208
kinds=[k.strip() for k in open(F+'/../c_kinds.txt')]
app=lines[C0:C1]
txt='\n'.join(app)
entries={}
for m in re.finditer(r'^- \*\*`(\w+)`\*\* \(([^)]*(?:\([^)]*\)[^)]*)*)\)',txt,re.M):
    entries[m.group(1)]=set(re.findall(r'§(\d+(?:\.\d+)?)',m.group(2)))
for k in kinds:
    found=set()
    for i,l in enumerate(lines):
        if C0<=i<C1: continue
        if re.search(r'`'+k+r'[`({]',l) or re.search(r'\b'+k+r'\b',l):
            s=sec[i]
            if s and not s.startswith('App'): found.add(s)
    cited=entries.get(k,set())
    # a cited chapter (e.g. 14) covers its subsections
    def covered(s,S): return s in S or s.split('.')[0] in S
    missing=sorted(s for s in found if not covered(s,cited))
    unbacked=sorted(s for s in cited if not any(f==s or f.startswith(s+'.') for f in found))
    if missing or unbacked:
        print(f"{k}\tcited={sorted(cited)}\tnamed_in_but_uncited={missing}\tcited_but_never_names={unbacked}")
