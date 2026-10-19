import re
L=open('spec.md').read().split('\n')
# glossary entries: <a id="g-x"></a>**name (alt)** —
gl={}
for i,l in enumerate(L[13803:],13804):
    m=re.match(r'<a id="(g-[^"]+)"></a>\*\*(.+?)\*\*',l)
    if m: gl[m.group(1)]=(m.group(2),i)
secs=[(11267,11319,'head'),(11320,11375,'14.1'),(11376,11487,'14.2'),(11488,11558,'14.3'),(11559,11717,'14.4'),(11718,11820,'14.5'),(11821,11873,'14.6')]
for a,b,n in secs:
    links={}
    for i in range(a,b+1):
        for m in re.finditer(r'\]\(#(g-[^)]+)\)',L[i-1]):
            links.setdefault(m.group(1),[]).append(i)
    print('==',n)
    for k,v in sorted(links.items(), key=lambda kv: kv[1][0]):
        print(f'  {k:32s} linked at {v}  [{gl.get(k,("?",0))[0]}]')
