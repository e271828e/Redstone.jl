import re
spec=open('scratch_survey/h1/spec.md').read().split('\n')
anchors={}
for l in spec[13674:]:
    m=re.match(r'<a id="(g-[^"]+)"></a>\*\*(.+?)\*\*',l)
    if m:
        names=[n.strip(' `') for n in re.split(r'\s*/\s*|,\s*',m.group(2))]
        anchors[m.group(1)]=names
new=open('chapter_new.md').read().split('\n')
secs=[]; cur=None
for i in range(612,1392):
    l=new[i]
    if l.startswith('### '): cur=[l[4:9],[]]; secs.append(cur)
    cur[1].append((i+1,l))
for name,lines in secs:
    text='\n'.join(l for _,l in lines)
    linked=set(re.findall(r'\]\(#(g-[^)]+)\)',text))
    for a,names in anchors.items():
        if a in linked: continue
        for n in names:
            if len(n)<4: continue
            pat=re.compile(r'(?<![\w#-])'+re.escape(n)+r's?(?![\w-])',re.I)
            hit=[ln for ln,l in lines if pat.search(re.sub(r'\]\(#[^)]*\)','',l)) and not l.startswith('    ')]
            if hit:
                print(name,a,n,hit[:4]); break
