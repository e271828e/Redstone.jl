import re,difflib
exec(open('replay.py').read().split('edits=')[0])
d='/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch13/'
E=parse(d+'final_fixes_2.md','````')
import subprocess
for U in 'FG':
    t=subprocess.run(['git','show',f'4de4315:docs/spec_rewrite/ch13/units/{U}/new.md'],capture_output=True,text=True,cwd=d).stdout
    for h,u,o,n in E:
        if u!=U: continue
        c=t.count(o)
        if c!=1: print('COUNT',c,h)
        t=t.replace(o,n)
        a,b=o.split(),n.split()
        for tag,i1,i2,j1,j2 in difflib.SequenceMatcher(None,a,b,autojunk=False).get_opcodes():
            if tag!='equal': print(h,'|',tag,' '.join(a[i1:i2]),'->',' '.join(b[j1:j2]))
    cur=open(d+f'units/{U}/new.md').read()
    print(U,'IDENTICAL' if cur==t else 'DIFFERS')
    if cur!=t:
        for l in difflib.unified_diff(t.split('\n'),cur.split('\n'),lineterm='',n=0): print(l)
