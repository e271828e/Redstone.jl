"""Rewrap, in place, the paragraph of FILE that contains MARKER to 80
rendered columns (link markup collapsed, * dropped). Links and code spans
stay whole. A list item wraps with a two-space continuation.

    python3 wrap.py FILE MARKER
"""
import re, sys

ATOM = re.compile(r'\[[^\]]*\]\([^)]*\)|\[[^\]]*\]\[[^\]]*\]|`[^`]*`')


def width(t):
    t = re.sub(r'\[([^\]]+)\]\(#[^)]*\)', r'\1', t)
    t = re.sub(r'\[([^\]]+)\]\[[^\]]*\]', r'\1', t)
    return len(t.replace('*', ''))


def tokens(text):
    prot = ATOM.sub(lambda m: m.group().replace(' ', '\0'), text)
    return [t.replace('\0', ' ') for t in prot.split()]


def fill(text, first, rest, w=80):
    lines, cur = [], first
    for tok in tokens(text):
        base = cur.rstrip() if cur.strip() else cur
        cand = (base + ' ' + tok) if cur.strip() else cur + tok
        if width(cand) <= w or not cur.strip():
            cur = cand
        else:
            lines.append(cur)
            cur = rest + tok
    lines.append(cur)
    return lines


def main(path, marker):
    src = open(path).read()
    paras = src.split('\n\n')
    mp = re.compile(r'\s+'.join(re.escape(w) for w in marker.split()))
    hits = [i for i, p in enumerate(paras) if mp.search(p)]
    if len(hits) != 1:
        sys.exit(f"marker found in {len(hits)} paragraphs")
    p = paras[hits[0]]
    if p.lstrip().startswith('```'):
        sys.exit("refusing to wrap code")
    items = re.split(r'\n(?=- )', p)
    out = []
    for it in items:
        if len(items) > 1 and not mp.search(it):
            out.append(it); continue
        joined = ' '.join(l.strip() for l in it.split('\n'))
        if joined.startswith('- '):
            out += fill(joined[2:], '- ', '  ')
        else:
            out += fill(joined, '', '')
    paras[hits[0]] = '\n'.join(out)
    open(path, 'w').write('\n\n'.join(paras))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
