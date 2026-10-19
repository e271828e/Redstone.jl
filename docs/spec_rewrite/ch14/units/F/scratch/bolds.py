import re,sys
t=open(sys.argv[1]).read()
want=set(sys.argv[2:])
lines=t.split('\n')
# map offsets to line numbers
flat=re.sub(r'\s+',' ',t)
# compute paragraph-based
off=0
for para in re.split(r'\n\s*\n',t):
    start=t.find(para,off); off=start+len(para)
    ln=t.count('\n',0,start)+1
    f=re.sub(r'\s+',' ',para)
    for m in re.finditer(r'\*\*(.+?)\*\*',f):
        rest=f[m.end():]; e=re.search(r'\.(\s|$)',rest)
        s=rest[:e.start()+1] if e else rest
        ds=set(re.findall(r'D-(\d{3})',m.group(1)+s))
        if ds & want: print(ln, sorted(ds&want), m.group(1)[:90])
