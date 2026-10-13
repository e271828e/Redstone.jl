import re,sys
L=open('spec.md').read().split('\n')
gl={}
for i in range(13308,14813):
    m=re.match(r'<a id="(g-[^"]+)"></a>\*\*([^*]+)\*\*',L[i])
    if m: gl[m.group(1)]=(m.group(2),i+1)
secs=[(7579,7708,'11.5'),(7709,8086,'11.6'),(8087,8244,'11.7'),(8245,8386,'11.8')]
for a,b,name in secs:
    print('==',name)
    text=[(n,L[n-1]) for n in range(a,b+1)]
    for anc,(term,gline) in sorted(gl.items()):
        t=term.strip('`')
        # strip link markup for search
        pat=re.compile(r'(?<![\w-])'+re.escape(t)+r's?(?![\w-])',re.I)
        first=None;firstlink=None;nlinks=0
        for n,l in text:
            plain=re.sub(r'\]\([^)]*\)',']',l)
            plain=re.sub(r'\]\[[^\]]*\]',']',plain)
            if first is None and pat.search(plain): first=n
            c=l.count('(#'+anc+')')
            if c:
                nlinks+=c
                if firstlink is None: firstlink=n
        if first or firstlink:
            flag=''
            if firstlink is None: flag='UNLINKED'
            elif first and first<firstlink: flag='LATE'
            if nlinks>1: flag+=' x%d'%nlinks
            print(f'  {anc} "{term}" first={first} link={firstlink} {flag}')
