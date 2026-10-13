import re, subprocess, shutil, os, sys
log = open('../../chapter_fixes_1.md').read()
secs = re.split(r'\n(?=## )', log)
os.makedirs('replay', exist_ok=True)
files = {}
for U in "ABCD":
    os.makedirs(f'replay/{U}', exist_ok=True)
    files[U] = open(f'base/{U}/new.md').read()
blk = r'````text\n(.*?)\n````(?!`)'
for s in secs:
    h = re.match(r'## (\d+)\. (.*)', s)
    if not h: continue
    n = int(h.group(1))
    if n == 51: break
    U = re.search(r'unit ([ABCD])', h.group(2)).group(1)
    o = re.search(r'Old:\n\n' + blk, s, re.S)
    nw = re.search(r'New:\n\n' + blk, s, re.S)
    if not o:
        print(n, 'no old block (inventory only?)'); continue
    old, new = o.group(1), nw.group(1)
    c = files[U].count(old)
    if c != 1:
        # entry 8 trailing blank-line case: try with trailing newline
        print(n, U, 'count', c, repr(old[-30:]))
        if c == 0: continue
    files[U] = files[U].replace(old, new, 1)
for U in "ABCD":
    open(f'replay/{U}/new.md','w').write(files[U])
    subprocess.run(['python3','wrap.py','apply',f'replay/{U}/new.md','all'],check=True)
# ruled edits
rl = open('../../ruled_edits.md').read()
for s in re.split(r'\n(?=## )', rl):
    h = re.match(r'## (\d+)\. (.*)', s)
    if not h: continue
    m = re.search(r'unit ([A-Z0-9]+)', h.group(2))
    if not m or m.group(1) not in "ABCD" or len(m.group(1))!=1: continue
    U = m.group(1)
    bl = re.findall(r'```text\n(.*?)\n```', s, re.S)
    if len(bl) != 2: print('ruled', h.group(1), 'blocks', len(bl)); continue
    f = open(f'replay/{U}/new.md').read()
    c = f.count(bl[0]); print('ruled', h.group(1), U, 'count', c)
    open(f'replay/{U}/new.md','w').write(f.replace(bl[0], bl[1], 1))
for U in "ABCD":
    r = subprocess.run(['diff', f'replay/{U}/new.md', f'../../units/{U}/new.md'], capture_output=True, text=True)
    print('==', U, 'identical' if not r.stdout else 'DIFF'); print(r.stdout)
