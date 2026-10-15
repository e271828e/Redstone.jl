import re,subprocess
new=subprocess.run(['git','show','d19fe88:docs/design/decisions.md'],capture_output=True,text=True).stdout.split('\n')
ids="030 031 088 097 101 110 114 127 128 132 133 138 198 217 218 223 230 249 255 260 261 268 274".split()
heads=[i for i,l in enumerate(new) if l.startswith('### D-')]
for d in ids:
    s=[i for i in heads if new[i].startswith(f'### D-{d} ')][0]
    e=next(i for i in heads if i>s)
    seq=[]
    for i in range(s,e):
        l=new[i]; prev=new[i-1]
        m=re.match(r'^\*\*(\w+)\.\*\*',l)
        if m: seq.append(m.group(1))
        elif l.startswith('Annotation (') and prev=='' : seq.append('A'+l[12:22])
        elif l.startswith('- ') and seq and seq[-1]!='-': pass
    print(d,' '.join(seq))
