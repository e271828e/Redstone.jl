import sys, difflib, importlib.util
spec = importlib.util.spec_from_file_location('r', sys.argv[1]); 
sys.argv_saved = sys.argv
src = open(sys.argv[1]).read().split("d = sys.argv[1]")[0]
ns = {}; exec(src, ns)
for log in sys.argv[2:]:
    for e in ns['parse'](log):
        for old, new in e['pairs']:
            a, b = old.split(), new.split()
            out = []
            for op, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
                if op == 'equal':
                    seg = a[i1:i2]
                    out.append(' '.join(seg) if len(seg) <= 8 else ' '.join(seg[:4]) + ' … ' + ' '.join(seg[-4:]))
                else:
                    if i2 > i1: out.append('[-' + ' '.join(a[i1:i2]) + '-]')
                    if j2 > j1: out.append('{+' + ' '.join(b[j1:j2]) + '+}')
            print(f'### {log.split("_")[0]}{log[-4:-3]} #{e["n"]} {e["unit"]} {e["src"]}')
            print(' '.join(out)); print()
