import re,sys
f,a,b=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
lines=open(f,encoding='utf-8').read().split('\n')
seen={}
for i in range(a-1,b):
    for m in re.finditer(r'\[([^\]]+)\]\(#(g-[^)]+)\)',lines[i]):
        seen.setdefault(m.group(2),[]).append((i+1,m.group(1)))
for k,v in sorted(seen.items(),key=lambda kv:kv[1][0][0]):
    print(k, v)
