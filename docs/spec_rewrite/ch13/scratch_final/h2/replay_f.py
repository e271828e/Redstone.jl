import re,sys
d='/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch13/'
s=d+'scratch_final/h2/'
def parse(path,fence):
    t=open(path).read()
    out=[]
    # split by headings ### or ##
    parts=re.split(r'\n(?=#{2,3} )',t)
    for p in parts:
        h=p.split('\n',1)[0]
        m=re.search(r'unit ([FG])',h)
        if not m: continue
        blocks=re.findall(re.escape(fence)+r'[a-z]*\n(.*?)\n'+re.escape(fence)+r'\n',p+'\n',re.S)
        if len(blocks)!=2: print('bad',h,len(blocks));continue
        out.append((h,m.group(1),blocks[0],blocks[1]))
    return out
edits=parse(d+'final_fixes_2.md','````')
txt={U:open(s+U+'_base.md').read() for U in 'FG'}
for h,U,o,n in edits:
    c=txt[U].count(o)
    if c!=1: print('COUNT',c,h)
    else: txt[U]=txt[U].replace(o,n)
for U in 'FG':
    open(s+U+'_replayed.md','w').write(txt[U])
print(len(edits),'edits')
