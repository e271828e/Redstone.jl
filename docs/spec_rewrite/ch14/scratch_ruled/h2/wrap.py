"""Rewrap a paragraph to 80 rendered columns (link markup collapsed).
Usage: wrap.py FILE START END  (1-based inclusive line range, rewritten in place)
       wrap.py --check FILE    (print lines over 80 rendered columns)"""
import re, sys
LINK = re.compile(r'\[([^\]]*)\](?:\[[^\]]*\]|\([^)]*\))')
def w(s): return len(LINK.sub(r'\1', s).replace('*', '').replace('`', ''))
def toks(text):
    # split on spaces outside backtick code spans
    out, cur, inside = [], '', False
    for ch in text:
        if ch == '`': inside = not inside
        if ch.isspace() and not inside:
            if cur: out.append(cur); cur = ''
        else: cur += ch
    if cur: out.append(cur)
    return out
def wrap(text, width=80, prefix='', cont=''):
    lines, cur, empty = [], prefix, True
    for t in toks(text):
        if empty: cur, empty = cur + t, False
        elif w(cur + ' ' + t) <= width: cur = cur + ' ' + t
        else: lines.append(cur); cur = cont + t
    lines.append(cur)
    return lines
if __name__ == '__main__':
    if sys.argv[1] == '--check':
        for n, l in enumerate(open(sys.argv[2]).read().split('\n'), 1):
            if w(l) > 80 and not l.startswith('|') : print(n, w(l), l[:60])
        sys.exit()
    f, a, b = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
    L = open(f).read().split('\n')
    para = L[a-1:b]
    m = re.match(r'(\s*(?:[-*]|\d+\.)\s+)', para[0])
    prefix = m.group(1) if m else ''
    cont = ' ' * len(prefix) if m else ''
    text = ' '.join(x.strip() for x in para)
    body = text[len(prefix.strip()):].strip() if m else text
    new = wrap(body, prefix=prefix, cont=cont)
    L[a-1:b] = new
    open(f, 'w').write('\n'.join(L))
    print('\n'.join(new))
