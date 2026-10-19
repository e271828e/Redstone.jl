import re,sys
lines=open('chapter_new.md').read().split('\n')
lo,hi=613,1392
infence=False
sec=None
links={}
for i in range(lo-1,hi):
    l=lines[i]
    if l.startswith('```'): infence=not infence; continue
    if l.startswith('### '): sec=l[4:9]
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    r=re.sub(r'\[([^\]]*)\]\(#[^)]*\)',r'\1',r)
    if not infence and len(r)>80: print('WIDE',i+1,len(r))
    if not infence:
        for m in re.finditer(r'\]\(#(g-[^)]*)\)',l):
            links.setdefault((sec,m.group(1)),[]).append(i+1)
for k,v in links.items():
    if len(v)>1: print('DUPLINK',k,v)
print('--links per section')
for k,v in sorted(links.items()): print(k,v)
