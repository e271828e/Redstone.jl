import re, sys
def parse(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    entries = []; cur = None; i = 0
    while i < len(lines):
        l = lines[i]
        m = re.match(r'^## (\d+)\. (.*), unit ([AB])$', l)
        if m:
            cur = {'n': int(m.group(1)), 'src': m.group(2), 'unit': m.group(3), 'pairs': []}
            entries.append(cur); i += 1; continue
        if l in ('Old:', 'New:') and cur is not None:
            kind = l[:-1]
            j = i + 1
            while lines[j] == '': j += 1
            assert lines[j] == '````text', (path, i, lines[j])
            k = j + 1; body = []
            while lines[k] != '````':
                body.append(lines[k]); k += 1
            text = '\n'.join(body)
            if kind == 'Old': cur['pairs'].append([text, None])
            else: cur['pairs'][-1][1] = text
            i = k + 1; continue
        i += 1
    return entries
d = sys.argv[1]
files = {u: open(f'{d}/{u}_verified.md', encoding='utf-8').read() for u in 'AB'}
ok = True
for log in sys.argv[2:]:
    for e in parse(log):
        for old, new in e['pairs']:
            c = files[e['unit']].count(old)
            if c != 1:
                ok = False; print(f'{log} #{e["n"]} ({e["src"]}, {e["unit"]}): old occurs {c} times')
                continue
            files[e['unit']] = files[e['unit']].replace(old, new)
        print(f'{log} #{e["n"]} {e["unit"]} {e["src"]} pairs={len(e["pairs"])}', file=sys.stderr)
for u in 'AB':
    open(f'{d}/{u}_replayed.md', 'w', encoding='utf-8').write(files[u])
print('ok' if ok else 'failures')
