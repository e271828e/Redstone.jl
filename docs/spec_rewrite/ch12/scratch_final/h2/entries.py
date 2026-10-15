import re, sys, difflib
def rw(s):
    s=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',s)
    s=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s)
    return len(s)
def wrapcheck(block):
    out=[]
    lines=block.split('\n')
    for i,l in enumerate(lines):
        w=rw(l)
        if w>80: out.append(f'  WIDE {w}: {l}')
        if i+1<len(lines) and lines[i+1].strip() and not lines[i+1].lstrip().startswith(('-','|','```','#')) and l.strip():
            nxt=lines[i+1].strip().split(' ')[0]
            # rendered length of next word
            if w+1+rw(nxt)<=80: out.append(f'  SHORT {w}+{rw(nxt)}: {l}')
    return out
def wd(a,b):
    A=a.split(); B=b.split()
    sm=difflib.SequenceMatcher(None,A,B,autojunk=False); r=[]
    for op,i1,i2,j1,j2 in sm.get_opcodes():
        if op!='equal': r.append(f'  {op}: [{" ".join(A[i1:i2])}] -> [{" ".join(B[j1:j2])}]')
    return r
log=open(sys.argv[1]).read()
mode=sys.argv[2]
if mode=='fix':
    pat=re.compile(r'^## (\d+)\. (\S+), unit (\w) \(([^)]*)\)\n(.*?)(?=^## |\Z)',re.S|re.M)
else:
    pat=re.compile(r'^### ()(\S+), unit (\w), `([^`]+)`\n\n(.*?)(?=^### |\Z)',re.S|re.M)
for m in pat.finditer(log):
    num,item,unit,kind,body=m.groups()
    if unit not in 'FG': continue
    bl=re.findall(r'````\w+\n(.*?)\n````',body,re.S)
    if len(bl)!=2: print(num,item,unit,kind,'(blocks',len(bl),')'); continue
    print(f'== {num} {item} {unit} {kind}')
    for x in wd(*bl): print(x)
    if not kind.endswith('claims.md'):
        for x in wrapcheck(bl[1]): print(x)
