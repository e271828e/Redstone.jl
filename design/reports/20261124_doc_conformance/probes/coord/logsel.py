import re,sys,json
L=open('design/log.md').read().split('\n')
cur=None;ent={}
for i,l in enumerate(L):
    m=re.match(r'### (D-\d+)',l)
    if m: cur=m[1]; ent[cur]={}
    elif cur and l.startswith('**Status.**'): ent[cur].setdefault('status',l[11:].strip())
    elif cur and l.startswith('**Spec.**'): ent[cur].setdefault('spec',l)
by={}
for d,e in ent.items():
    if not e.get('status','').startswith('ratified'): continue
    m=re.search(r'§(\d+)',e.get('spec',''))
    by.setdefault(m[1] if m else 'none',[]).append(d)
json.dump(by,open(sys.argv[1],'w'))
print({k:len(v) for k,v in sorted(by.items(),key=lambda x:(len(x[0]),x[0]))})
