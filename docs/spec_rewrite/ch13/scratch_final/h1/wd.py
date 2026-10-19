import re, os, subprocess, tempfile
exec(open('replay.py').read().split("print(len(E1)")[0])
D='.'
for tag,E in (('FIX',E1),('RULED',E2)):
    for h,U,old,new in E:
        a=os.path.join('tmp_a'); b='tmp_b'
        open(a,'w').write(' '.join(old.split())+'\n'); open(b,'w').write(' '.join(new.split())+'\n')
        r=subprocess.run(['git','diff','--no-index','--word-diff=plain','--word-diff-regex=[^ ]+',a,b],capture_output=True,text=True).stdout
        body='\n'.join(r.splitlines()[5:])
        print('=====',tag,h); print(body or '(whitespace only)')
