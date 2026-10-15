import re
S=open('scratch_survey/h1/spec.md').read()
ents=re.findall(r'<a id="g-([\w-]+)"></a>\*\*(.+?)\*\*',S)
L=open('chapter_new.md').read().split('\n')
secs=[('12.5',651,743),('12.6',744,1045),('12.7',1046,1362)]
for name,a,b in secs:
    body='\n'.join(L[a-1:b])
    plain=re.sub(r'```.*?```','',body,flags=re.S)
    for anc,names in ents:
        ns=[n.strip() for n in re.split(r' / |, ',names.replace('`',''))]
        # first link position
        lk=plain.find(f'(#g-{anc})')
        txt=re.sub(r'\]\(#g-[\w-]+\)',']',plain)
        first=None
        for n in ns:
            if len(n)<3: continue
            m=re.search(r'(?<![\w-])'+re.escape(n)+r'(s|es)?(?![\w-])',txt,re.I)
            if m and (first is None or m.start()<first[0]): first=(m.start(),n)
        if not first: continue
        if lk<0:
            ln=a+txt[:first[0]].count('\n')
            print(name,'UNLINKED',anc,repr(first[1]),'line',ln)
        else:
            # compare positions roughly via line numbers
            ll=a+plain[:lk].count('\n'); lf=a+txt[:first[0]].count('\n')
            if lf<ll: print(name,'LATE',anc,repr(first[1]),'first',lf,'link',ll)
