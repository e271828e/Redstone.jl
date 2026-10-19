import re,sys
def rend(l):
    l=re.sub(r'\[([^\]]*)\]\(#[^)]*\)',r'\1',l)
    l=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    l=l.replace('**','').replace('`','')
    l=re.sub(r'(?<!\w)\*([^*]+)\*',r'\1',l)
    l=l.replace('$','')
    return l
for f in sys.argv[1:]:
    code=False
    for i,l in enumerate(open(f).read().split('\n'),1):
        if l.startswith('```'): code=not code; continue
        if code: continue
        r=rend(l)
        if len(r)>80: print(f,i,len(r),r)
