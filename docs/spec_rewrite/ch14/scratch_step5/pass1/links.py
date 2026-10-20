import re,sys
lines=open(sys.argv[1],encoding='utf-8').read().split('\n')
lo,hi=int(sys.argv[2]),int(sys.argv[3])
sec=None; seen={}
for i in range(lo-1,hi):
    l=lines[i]
    if l.startswith('## ') or l.startswith('### '):
        sec=l[:12]; seen={}; print('==',l[:60]); continue
    for m in re.finditer(r'\[([^\]]*)\]\(#(g-[^)]*)\)',l):
        a=m.group(2); after=l[m.end():m.end()+40]
        nxt=lines[i+1][:30] if i+1<len(lines) else ''
        tag='DUP' if a in seen else ''
        g='gloss' if after.lstrip().startswith('(') or after.startswith("'s") and '(' in after[:12] else ''
        if not g and after.strip()=='' and nxt.lstrip().startswith('('): g='gloss'
        print(i+1,a,tag,g,'|',after[:35])
        seen[a]=i+1
