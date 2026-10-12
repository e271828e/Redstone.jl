import re,sys
spec=open('spec_b08.md').read().split('\n')
i=next(k for k,l in enumerate(spec) if l.startswith('## Appendix D'))
terms={}
for l in spec[i:]:
    m=re.match(r'<a id="(g-[^"]+)"></a>(.*)',l)
    if m:
        a=m.group(1); names=re.findall(r'\*\*(.+?)\*\*',m.group(2))
        al=[]
        for n in names:
            for p in n.split(' / '):
                al.append(p.replace('`','').strip())
        terms[a]=al
txt=open(sys.argv[1]).read().split('\n')
# sections
secs=[];cur=None
for n,l in enumerate(txt,1):
    if re.match(r'#{2,3} ',l): cur=[l,[]]; secs.append(cur)
    elif cur: cur[1].append((n,l))
for h,body in secs:
    print('=====',h)
    incode=False; plain=[]
    for n,l in body:
        if l.startswith('```'): incode=not incode; continue
        if incode: continue
        plain.append((n,l))
    for a,al in terms.items():
        firstuse=None; firstlink=None; links=[]
        for n,l in plain:
            if '(#'+a+')' in l: links.append(n)
            s=re.sub(r'\]\([^)]*\)',']',l)
            s=re.sub(r'\]\[[^]]*\]',']',s)
            for t in al:
                if len(t)<3: continue
                if re.search(r'(?<![\w-])'+re.escape(t)+r'(s|es)?(?![\w])',s,re.I):
                    if firstuse is None: firstuse=(n,t)
        if firstuse or links:
            flag=''
            if not links: flag='UNLINKED'
            elif len(links)>1: flag='MULTI'
            elif firstuse and links[0]!=firstuse[0]: flag='NOT-FIRST'
            print(f'{a:28} first={firstuse} links={links} {flag}')
