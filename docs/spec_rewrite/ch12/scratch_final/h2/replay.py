import re, subprocess, sys
ROOT='/Users/miguel/.julia/dev/Redstone.jl'
D='docs/spec_rewrite/ch12/'
def show(c,p):
    r=subprocess.run(['git','show',f'{c}:{D}{p}'],capture_output=True,text=True,cwd=ROOT)
    return r.stdout if r.returncode==0 else None
# fixer log
log=open('chapter_fixes_2.md').read()
pat=re.compile(r'^## (\d+)\. (\S+), unit (\w) \(([^)]*)\)\n(.*?)(?=^## |\Z)',re.S|re.M)
files={}
n=0
for m in pat.finditer(log):
    num,item,unit,kind,body=m.groups()
    p=f'units/{unit}/new.md'
    if p not in files: files[p]=show('69a3191',p)
    bl=re.findall(r'````\w+\n(.*?)\n````',body,re.S)
    if len(bl)!=2: print('BLOCKS',num,len(bl)); continue
    old,new=bl; c=files[p].count(old)
    if c!=1: print('FAIL',num,item,c); continue
    files[p]=files[p].replace(old,new); n+=1
print('fixer entries applied',n)
for p,t in files.items():
    print(p,'vs 509ea77:', 'MATCH' if t==show('509ea77',p) else 'DIFFER')
    open(f'scratch_final/h2/{p.split("/")[1]}_after_fix.md','w').write(t)
# ruled edits
log=open('ruled_edits.md').read()
pat=re.compile(r'^### (\S+), unit (\w), `([^`]+)`\n\n(.*?)(?=^### |\Z)',re.S|re.M)
f2={}; n=0
for m in pat.finditer(log):
    item,unit,path,body=m.groups()
    if unit not in 'FG': continue
    if path not in f2:
        f2[path]=files.get(path) if path.endswith('new.md') else show('509ea77',path)
    bl=re.findall(r'````\w+\n(.*?)\n````',body,re.S)
    if body.startswith('A new file'):
        f2[path]=bl[0]+'\n'; n+=1; continue
    old,new=bl; c=f2[path].count(old)
    if c!=1: print('FAIL',item,path,c); continue
    f2[path]=f2[path].replace(old,new); n+=1
print('ruled entries applied',n)
for p,t in f2.items():
    print(p,'vs 702ae15:', 'MATCH' if t==show('702ae15',p) else 'DIFFER')
