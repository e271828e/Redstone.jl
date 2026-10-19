import re,sys,os
sys.path.insert(0,'checks')
from norm import norm,units
U='ch14/units/F'
O=norm(open(f'{U}/old.md').read()); N=norm(open(f'{U}/new.md').read())
# split old into paragraph units, then sentences
paras=units(open(f'{U}/old.md').read())
out=[]
for p in paras:
    if p.startswith('`') and p.endswith('`') and '\n' not in p and len(p)>200:
        out.append(p); continue
    # sentence split: period/colon followed by space and uppercase/backtick/bracket
    parts=re.split(r'(?<=[.:!?])\s+(?=[A-Z`$"*\[(-])', p)
    out+=parts
for s in out:
    s=s.strip()
    if not s: continue
    print('old: '+s)
    print('tag: F' if s in N else 'tag: TODO')
    print()
