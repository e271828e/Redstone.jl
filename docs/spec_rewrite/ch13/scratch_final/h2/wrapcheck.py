import re
exec(open('replay.py').read().split('txt={')[0])
def rend(l,bt):
    l=re.sub(r'\[([^\]]*)\]\(#[^)]*\)',r'\1',l)
    l=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',l)
    l=l.replace('**','')
    l=re.sub(r'(?<![\w*])\*([^*\s][^*]*)\*',r'\1',l)
    if not bt: l=l.replace('`','')
    return l
for bt in (True,False):
  print('== backticks counted' if bt else '== backticks not counted')
  for k,(h,U,o,n) in enumerate(edits,1):
    L=n.split('\n')
    for i,l in enumerate(L):
        r=rend(l,bt)
        if len(r)>80: print(k,'OVER',len(r),r)
        if i+1<len(L) and L[i+1].strip():
            nxt=rend(L[i+1].lstrip(),bt)
            # first token, not breaking inside code span
            m=re.match(r'(`[^`]*`\S*|\S+)',nxt); w=m.group(1) if m else ''
            if len(r)+1+len(w)<=80: print(k,'SHORT',len(r),'+',w)
