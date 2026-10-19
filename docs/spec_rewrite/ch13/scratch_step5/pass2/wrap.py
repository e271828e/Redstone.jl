import re
lines=open('chapter_new.md').read().split('\n')
def rend(l):
    r=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    return re.sub(r'\[([^\]]*)\]\(#[^)]*\)',r'\1',r)
inf=False
for i in range(612,1392):
    l=lines[i]
    if l.startswith('```'): inf=not inf; continue
    if inf or not l.strip() or l.startswith('#'): continue
    n=lines[i+1] if i+1<len(lines) else ''
    if not n.strip() or n.startswith('```') or n.startswith('#') or n.lstrip().startswith('- '): continue
    w=rend(n.strip()).split(' ')[0]
    if len(rend(l))+1+len(w)<=80-6: print(i+1,len(rend(l)),repr(w))
