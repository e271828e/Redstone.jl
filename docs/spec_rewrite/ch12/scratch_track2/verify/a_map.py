import re,subprocess
new=subprocess.run(['git','show','d19fe88:docs/design/decisions.md'],capture_output=True,text=True).stdout.split('\n')
diff=open('a_diff.txt').read()
hunks=re.split(r'\n(?=@@)',diff)[1:]
def unlink(s): return re.sub(r'\[([^\]]+)\]\[[^\]]+\]',r'\1',s)
log=open('../../track2_log_1.md').read()
secs=re.split(r'\n(?=### L\d+\.)',log.split('## Commit 2')[1])[1:]
logs=[]
for s in secs:
    head=s.split('\n')[0]
    m=re.search(r'New:\s*\n\n```\n(.*?)\n```',s,re.S)
    nm=re.search(r'New: `(.*?)`\n',s)
    txt=m.group(1) if m else (nm.group(1) if nm else None)
    logs.append((head,txt))
for i,h in enumerate(hunks):
    m=re.match(r'@@ -\d+,\d+ \+(\d+)',h); start=int(m.group(1))
    j=start
    while not new[j-1].startswith('### D-'): j-=1
    added=[l[1:] for l in h.split('\n')[1:] if l.startswith('+')]
    a=unlink(' '.join(x for x in added if x)).split()
    head,txt=logs[i] if i<len(logs) else ('NONE',None)
    t=' '.join((txt or '').split())
    # log new for Spec includes whole line; for annotation includes context lines possibly
    aj=' '.join(a)
    ok = aj in t or t in aj
    print(i+1,new[j-1][:12],'|',head[:40],'|','MATCH' if ok else 'DIFF')
    if not ok: print('  HUNK:',aj[:300]); print('  LOG :',t[:300])
