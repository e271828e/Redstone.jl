import sys, difflib
u=sys.argv[1]
a=open(f"norm/{u}.e16").read().split(); b=open(f"norm/{u}.head").read().split()
sm=difflib.SequenceMatcher(None,a,b,autojunk=False); n=0
for op,i1,i2,j1,j2 in sm.get_opcodes():
    if op=="equal": continue
    n+=1
    ctx=" ".join(a[max(0,i1-6):i1])
    print(f"[{n}] ...{ctx} | -{{{' '.join(a[i1:i2])}}} +{{{' '.join(b[j1:j2])}}} | {' '.join(a[i2:i2+6])}...")
print("hunks",n)
