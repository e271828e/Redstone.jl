import difflib, re, sys
def paras(t):
    return [re.sub(r'\s+',' ',p).strip() for p in re.split(r'\n\s*\n', t) if p.strip()]
mode = sys.argv[1]
for U in "ABCD":
    if mode == 'norm':
        a = open(f'norm_old_{U}.txt').read(); b = open(f'norm_new_{U}.txt').read()
    else:
        a = open(f'base/{U}/new.md').read(); b = open(f'../../units/{U}/new.md').read()
    A, B = paras(a), paras(b)
    sm = difflib.SequenceMatcher(None, A, B, autojunk=False)
    k = 0
    for op, i1, i2, j1, j2 in sm.get_opcodes():
        if op == 'equal': continue
        x = ' ¶ '.join(A[i1:i2]).split(' '); y = ' ¶ '.join(B[j1:j2]).split(' ')
        s2 = difflib.SequenceMatcher(None, x, y, autojunk=False)
        for o, a1, a2, b1, b2 in s2.get_opcodes():
            if o == 'equal': continue
            k += 1
            ctx = ' '.join(x[max(0,a1-6):a1])
            print(f'[{U}{k}] ...{ctx} | -{" ".join(x[a1:a2])!r} +{" ".join(y[b1:b2])!r}')
    print(f'== {U}: {k} hunks\n')
