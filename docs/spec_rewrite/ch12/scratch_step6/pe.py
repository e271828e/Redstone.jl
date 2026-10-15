"""Paragraph edit with rewrap to 80 rendered columns (link markup collapsed).

pe.py edit FILE LOG ITEM UNIT SPECFILE   SPECFILE holds 'OLD\n=====\nNEW' (flattened text)
pe.py check FILE                          report paragraphs a rewrap would change
"""
import re, sys

LINK = re.compile(r'\[([^\[\]]*)\](\([^)]*\)|\[[^\]]*\])')
W = 80

def is_start(line):
    return bool(re.match(r'(\d+\. |- |#|> |```)', line))

def paragraphs(lines):
    """Yield (start, end) index ranges of prose paragraphs / list items."""
    i, n, out, fence = 0, len(lines), [], False
    while i < n:
        l = lines[i]
        if l.startswith('```'):
            j = i + 1
            while not lines[j].startswith('```'): j += 1
            i = j + 1; continue
        if not l.strip() or l.startswith('#') or l.startswith('>') or l.startswith('|'):
            i += 1; continue
        j = i + 1
        while j < n and lines[j].strip() and not is_start(lines[j]) and not lines[j].startswith('|'):
            j += 1
        out.append((i, j)); i = j
    return out

def prefixes(first):
    m = re.match(r'(\d+\. |- )', first)
    if m: return m.group(1), ' ' * len(m.group(1))
    return '', ''

def flat(lines):
    p0, _ = prefixes(lines[0])
    body = [lines[0][len(p0):]] + [l.strip() for l in lines[1:]]
    return p0, ' '.join(s.strip() for s in body)

def wrap(p0, text):
    zero = [False] * len(text)
    for m in LINK.finditer(text):
        zero[m.start()] = True
        for k in range(m.start(1) + len(m.group(1)), m.end()): zero[k] = True
    nb = [False] * len(text)
    for m in re.finditer(r'`[^`]*`', text):
        for k in range(m.start(), m.end()): nb[k] = True
    toks, start = [], None
    for k in range(len(text) + 1):
        brk = k == len(text) or (text[k] == ' ' and not nb[k])
        if brk:
            if start is not None:
                toks.append((text[start:k], sum(1 for j in range(start, k) if not zero[j])))
            start = None
        elif start is None:
            start = k
    _, pc = prefixes(p0 + 'x') if p0 else ('', '')
    pc = ' ' * len(p0)
    lines, cur, cw = [], [], len(p0)
    for t, w in toks:
        if cur and cw + 1 + w > W:
            lines.append(cur); cur, cw = [t], len(pc) + w
        else:
            cw += (1 if cur else 0) + w; cur.append(t)
    lines.append(cur)
    res = [(p0 if i == 0 else pc) + ' '.join(l) for i, l in enumerate(lines)]
    for r in res[1:]:
        if is_start(r.strip()): sys.stderr.write(f'WARNING line starts like a block: {r!r}\n')
    return res

def main():
    if sys.argv[1] == 'check':
        lines = open(sys.argv[2]).read().split('\n')
        for a, b in paragraphs(lines):
            p0, t = flat(lines[a:b])
            if wrap(p0, t) != lines[a:b]: print(f'differs at {a+1}-{b}')
        return
    _, _, path, log, item, unit, spec = sys.argv
    old, new = open(spec).read().rstrip('\n').split('\n=====\n')
    lines = open(path).read().split('\n')
    hits = []
    for a, b in paragraphs(lines):
        p0, t = flat(lines[a:b])
        if old in t: hits.append((a, b, p0, t))
    total = sum(h[3].count(old) for h in hits)
    if total != 1: sys.exit(f'old text found {total} times')
    a, b, p0, t = hits[0]
    newlines = wrap(p0, t.replace(old, new))
    oldpara = '\n'.join(lines[a:b]); newpara = '\n'.join(newlines)
    lines[a:b] = newlines
    open(path, 'w').write('\n'.join(lines))
    with open(log, 'a') as f:
        f.write(f'### {item}, unit {unit}, `{path.split("ch12/")[-1]}`\n\nOld:\n\n````markdown\n{oldpara}\n````\n\nNew:\n\n````markdown\n{newpara}\n````\n\n')
    print(newpara)

main()
