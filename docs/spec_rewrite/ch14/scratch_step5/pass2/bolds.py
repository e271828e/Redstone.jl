import re,sys
# print bold spans with D-cites in the same paragraph-sentence; args: file start end
f,a,b=sys.argv[1],int(sys.argv[2]),int(sys.argv[3])
lines=open(f,encoding='utf-8').read().split('\n')
text='\n'.join(lines[a-1:b])
# map offset->line
starts=[];o=0
for i,l in enumerate(lines[a-1:b]):
    starts.append(o);o+=len(l)+1
import bisect
for m in re.finditer(r'\*\*(.+?)\*\*',text,re.S):
    ln=a+bisect.bisect_right(starts,m.start())-1
    # sentence: up to next ". " followed by capital or end para
    rest=text[m.start():m.start()+700]
    end=re.search(r'\.(\s+[A-Z`\[*]|\s*\n\n|$)',rest[len(m.group(0))-2:])
    sent=rest[:len(m.group(0))-2+(end.start()+1 if end else 400)]
    ds=sorted(set(re.findall(r'D-\d+',sent)))
    w=len(re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',m.group(1)).split())
    print(ln,w,' '.join(ds),'|',' '.join(m.group(1).split())[:90])
