import re,sys
t=open(sys.argv[1]).read()
want=set(sys.argv[2].split(','))
lines=t.split('\n')
# map char offset to line
offs=[];o=0
for l in lines: offs.append(o); o+=len(l)+1
import bisect
sec=''
secs=[(m.start(),m.group(0)) for m in re.finditer(r'^#{2,3} .*$',t,re.M)]
for m in re.finditer(r'\*\*(.+?)\*\*',t,re.S):
    rest=t[m.end():m.end()+600]
    e=re.search(r'\.(\s|$)',rest)
    s=rest[:e.start()+1] if e else rest
    ds=set(re.findall(r'D-(\d{3})',m.group(1)+s))
    hit=ds&want
    if hit:
        ln=bisect.bisect(offs,m.start())
        i=bisect.bisect([a for a,_ in secs],m.start())-1
        print(ln, secs[i][1][:30] if i>=0 else '', sorted(hit), re.sub(r'\s+',' ',m.group(1))[:90])
