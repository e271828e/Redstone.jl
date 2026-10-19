import re,difflib,sys
sys.path.insert(0,'.')
exec(open('replay.py').read().split('txt={')[0])
for i,(h,U,o,n) in enumerate(edits,1):
    a=o.split(); b=n.split()
    sm=difflib.SequenceMatcher(None,a,b,autojunk=False)
    print(f'=== {i}. {h[:90]}')
    for tag,i1,i2,j1,j2 in sm.get_opcodes():
        if tag!='equal':
            print(f'  {tag}: [{" ".join(a[i1:i2])}] -> [{" ".join(b[j1:j2])}]')
