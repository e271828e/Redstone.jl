import re, sys, os, subprocess
D = os.path.dirname(os.path.abspath(__file__))
CH = os.path.dirname(os.path.dirname(D))
fx = open(os.path.join(CH, 'chapter_fixes_1.md')).read()
re_ = open(os.path.join(CH, 'ruled_edits_1.md')).read()

def entries(text, hdr, fence):
    out = []
    parts = re.split(hdr, text)
    # parts: [pre, h1, body1, h2, body2...]
    for i in range(1, len(parts), 2):
        h, body = parts[i], parts[i + 1]
        m = re.search(r'Old:\n\n' + fence + r'[a-z]*\n(.*?)\n' + fence + r'\n\nNew:\n\n' + fence + r'[a-z]*\n(.*?)\n' + fence + r'\n', body, re.S)
        if not m:
            continue
        um = re.search(r'unit ([AB])', h)
        out.append((h.strip(), um.group(1), m.group(1), m.group(2)))
    return out

fx_main = fx.split('## Unit A, `claims.md`')[0]
E1 = entries(fx_main, r'\n(### \d+\..*)\n', '~~~~')
E2 = entries(re_, r'\n(## \d+\..*)\n', '````')
print(len(E1), 'fixer entries;', len(E2), 'ruled entries')
txt = {U: open(os.path.join(D, 'base', U + '_new.md')).read() for U in 'AB'}
mid = None
for stage, E in (('fix', E1), ('ruled', E2)):
    for h, U, old, new in E:
        n = txt[U].count(old)
        if n != 1:
            print('COUNT', n, stage, h)
            continue
        txt[U] = txt[U].replace(old, new)
    if stage == 'fix':
        for U in 'AB':
            open(os.path.join(D, U + '_new.afterfix.md'), 'w').write(txt[U])
for U in 'AB':
    p = os.path.join(D, U + '_new.replay.md')
    open(p, 'w').write(txt[U])
    head = open(os.path.join(D, 'head', U + '_new.md')).read()
    print(U, 'new.md replay == head:', txt[U] == head)

# claims diffs from the fixer log
for U, sec in (('A', '## Unit A, `claims.md`'), ('B', '## Unit B, `claims.md`')):
    body = fx.split(sec)[1]
    m = re.search(r'~~~~diff\n(.*?)\n~~~~\n', body, re.S)
    patch = m.group(1) + '\n'
    pf = os.path.join(D, U + '_claims.patch')
    open(pf, 'w').write(patch)
    out = os.path.join(D, U + '_claims.afterfix.md')
    subprocess.run(['cp', os.path.join(D, 'base', U + '_claims.md'), out])
    r = subprocess.run(['patch', '--no-backup-if-mismatch', out, pf], capture_output=True, text=True)
    print(U, 'claims patch:', r.returncode, r.stdout.strip().replace('\n', ' | '), r.stderr.strip())
