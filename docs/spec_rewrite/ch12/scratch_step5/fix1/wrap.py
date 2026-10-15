"""Rewrap one paragraph of a file to 80 rendered columns.
usage: wrap.py FILE START END [INDENT_FIRST INDENT_REST]   (1-based inclusive lines)
       wrap.py FILE --check          (list lines over 80 rendered columns)"""
import re, sys
LINK = re.compile(r'\[[^\]]+\](?:\([^)]*\)|\[[^\]]*\])')
def rendered(s):
    s = re.sub(r'\[([^\]]+)\]\(#[^)]*\)', r'\1', s)
    s = re.sub(r'\[([^\]]+)\]\[[^\]]*\]', r'\1', s)
    return len(s)
def wrap(text, first, rest, width=80):
    text = re.sub(r'\s+', ' ', text).strip()
    # protect spaces inside links
    text = LINK.sub(lambda m: m.group().replace(' ', '\x00'), text)
    words = text.split(' ')
    lines, cur = [], first
    for w in words:
        cand = (cur + ' ' + w) if cur.strip() else cur + w
        if rendered(cand.replace('\x00', ' ')) <= width or not cur.strip():
            cur = cand
        else:
            lines.append(cur); cur = rest + w
    lines.append(cur)
    return [l.replace('\x00', ' ') for l in lines]
f = sys.argv[1]
L = open(f).read().split('\n')
if sys.argv[2] == '--check':
    for i, l in enumerate(L, 1):
        if rendered(l) > 80: print(i, rendered(l), l)
    sys.exit()
a, b = int(sys.argv[2]), int(sys.argv[3])
first = sys.argv[4] if len(sys.argv) > 4 else ''
rest = sys.argv[5] if len(sys.argv) > 5 else first
body = ' '.join(x.strip() for x in L[a-1:b])
body = body[len(first.strip()) and 0:]
new = wrap(body, first, rest)
L[a-1:b] = new
open(f, 'w').write('\n'.join(L))
print('\n'.join(new))
