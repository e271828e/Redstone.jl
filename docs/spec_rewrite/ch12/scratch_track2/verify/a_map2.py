import re,subprocess
new=subprocess.run(['git','show','d19fe88:docs/design/decisions.md'],capture_output=True,text=True).stdout.split('\n')
diff=open('a_diff.txt').read()
hunks=re.split(r'\n(?=@@)',diff)[1:]
def unlink(s): return re.sub(r'\[([^\]]+)\]\[[^\]]+\]',r'\1',s)
def norm(s): return ' '.join(unlink(s).split())
log=open('../../track2_log_1.md').read()
secs=re.split(r'\n(?=### L\d+\.)',log.split('## Commit 2')[1].split('## Left or declined')[0])[1:]
logs=[]
for s in secs:
    head=s.split('\n')[0]
    did=re.search(r'D-\d+',head).group(0)
    m=re.search(r'New:\s*\n\n```+\n(.*?)```',s,re.S)
    nm=re.search(r'New: `(.*?)`\n',s)
    om=re.search(r'Old:\s*\n\n```+\n(.*?)```',s,re.S)
    logs.append([head,did,norm(m.group(1) if m else nm.group(1)),norm(om.group(1)) if om else '',0])
for i,h in enumerate(hunks):
    start=int(re.match(r'@@ -\d+,\d+ \+(\d+)',h).group(1))
    j=start
    while not new[j-1].startswith('### D-'): j-=1
    did=re.search(r'D-\d+',new[j-1]).group(0)
    added=norm(' '.join(l[1:] for l in h.split('\n')[1:] if l.startswith('+')))
    hits=[L for L in logs if L[1]==did and added in L[2]]
    for L in hits: L[4]+=1
    print(i+1,did,'->',[L[0][:30] for L in hits] or 'NO LOG MATCH')
    if not hits: print('   ',added[:400]); [print('   LOG',L[0],L[2][:400]) for L in logs if L[1]==did]
for L in logs:
    if L[4]!=1: print('LOG ENTRY hits',L[4],L[0])
