import re
pdf=open('scratch_pdf/out.txt').read().split('=====PAGE 11=====')[1]
pdf=re.sub(r'=====PAGE \d+=====','',pdf)
norm=lambda s: re.sub(r'[\s­\-‑–]+','',s)
P=norm(pdf)
md=open('chapter_new.md').read()
# strip fences
fences=re.findall(r'```.*?```',md,re.S)
md=re.sub(r'```.*?```','',md,flags=re.S)
md=re.sub(r'^\[[^\]]+\]:.*$','',md,flags=re.M)
md=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',md)
md=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',md)
md=re.sub(r'[`*]|^#+ |^> ?','',md,flags=re.M).replace('\\','')
bad=0
for ln in md.split('\n'):
    ln=ln.strip()
    if len(ln)<3: continue
    for s in re.split(r'(?<=[.;:?!])\s+',ln):
        n=norm(s)
        if len(n)>3 and n not in P:
            bad+=1; print('MISS:',s[:140])
print(bad)
