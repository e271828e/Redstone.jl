import re, subprocess, sys
log = open('ruled_edits.md').read()
files = {}
pat = re.compile(r'^### (\S+), unit (\w), `([^`]+)`\n\n(.*?)(?=^### |\Z)', re.S | re.M)
for m in pat.finditer(log):
    item, unit, path, body = m.groups()
    full = 'docs/spec_rewrite/ch12/' + path
    if path not in files:
        r = subprocess.run(['git', 'show', f'509ea77:{full}'], capture_output=True, text=True, cwd='/Users/miguel/.julia/dev/Redstone.jl')
        files[path] = r.stdout if r.returncode == 0 else None
    blocks = re.findall(r'````\w+\n(.*?)\n````', body, re.S)
    if body.startswith('A new file'):
        files[path] = blocks[0] + '\n'; continue
    old, new = blocks
    c = files[path].count(old)
    if c != 1: print('FAIL', item, path, c); continue
    files[path] = files[path].replace(old, new)
for path, txt in files.items():
    cur = open(path).read()
    print(path, 'MATCH' if cur == txt else 'DIFFER')
