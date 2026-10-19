import re,sys
L=open(sys.argv[1],encoding='utf-8').read().split('\n')
a,b=int(sys.argv[2]),int(sys.argv[3])
sec=None;seen={}
for i in range(a-1,b):
    s=L[i]
    if s.startswith('### ') or s.startswith('## '): sec=s[:12]; seen={}
    nxt=s+' '+(L[i+1] if i+1<len(L) else '')
    for m in re.finditer(r'\[([^\]]+)\]\(#(g-[^)]+)\)',s):
        after=nxt[m.end():m.end()+40]
        gl='GLOSS' if re.match(r"[a-z'’\-]*s?\)?\s*\(",after) and not re.match(r"[a-z'’\-]*\s*\(\[",after) else '-'
        print(i+1,sec,m.group(2),gl,'DUP' if m.group(2) in seen else '',after[:30].replace('\n',' '))
        seen[m.group(2)]=1
