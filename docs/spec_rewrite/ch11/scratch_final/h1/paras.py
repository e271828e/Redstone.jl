import difflib, re, sys
def paras(t):
    return [re.sub(r'\s+',' ',p).strip() for p in re.split(r'\n\s*\n', t) if p.strip()]
U=sys.argv[1]
A=paras(open(f'base/{U}/new.md').read()); B=paras(open(f'../../units/{U}/new.md').read())
sm=difflib.SequenceMatcher(None,A,B,autojunk=False)
for op,i1,i2,j1,j2 in sm.get_opcodes():
    if op=='equal': continue
    print('---OLD'); [print(p) for p in A[i1:i2]]
    print('+++NEW'); [print(p) for p in B[j1:j2]]
    print()
