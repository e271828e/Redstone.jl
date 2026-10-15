import re,sys
f='/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md'
L=open(f).read().split('\n')
out=[];cur=None;inpos=False
for i,l in enumerate(L,1):
    m=re.match(r'### (D-\d+) ',l)
    if m: cur=m.group(1);inpos=False;continue
    if l.startswith('**Position.**'): inpos=True
    elif re.match(r'\*\*(Spec|Rationale|Rejected|Divergence|Status)\.\*\*',l) or l.startswith('Supersedes') or l.startswith('<!-- citation'): inpos=False
    if inpos and cur: out.append(f'{cur}:{i}: {l}')
open('positions.txt','w').write('\n'.join(out))
