import re,sys
def render(l):
    l=re.sub(r'<a id="[^"]*"></a>','',l)
    l=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',l)
    l=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    return l.replace('**','').replace('`','')
for a in sys.argv[2:]:
    n=int(a); l=open(sys.argv[1]).read().split('\n')[n-1]
    print(n,len(render(l)),render(l))
