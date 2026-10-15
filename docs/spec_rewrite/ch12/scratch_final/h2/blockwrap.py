import re,sys
def rd(s):
    s=re.sub(r'\[([^\]]*)\]\[[^\]]*\]',r'\1',s)
    return re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',s)
log=open(sys.argv[1]).read()
for m in re.finditer(r'^(#+ [^\n]*)\n(.*?)(?=^#+ |\Z)',log,re.S|re.M):
    head,body=m.groups()
    if not re.search(r'unit [FG]',head): continue
    bl=re.findall(r'````(\w+)\n(.*?)\n````',body,re.S)
    if len(bl)<2: continue
    L=bl[1][1].split('\n')
    for i,l in enumerate(L):
        r=rd(l)
        if len(r)>80: print(head,'WIDE',len(r),r)
        if i+1<len(L) and L[i+1].strip() and not L[i+1].lstrip().startswith(('- ','|')):
            nw=rd(L[i+1]).strip().split(' ')[0]
            if len(r)+1+len(nw)<=80: print(head,'| SHORT',len(r),'+',len(nw),'|',r)
