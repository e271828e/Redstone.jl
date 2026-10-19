"""Rewrap markdown paragraphs/list items to 80 rendered columns, and apply edits."""
import re, sys, os

def rw(tok):
    t = re.sub(r'\]\([^)]*\)', '', tok)
    t = re.sub(r'\]\[[^\]]*\]', '', t)
    t = t.replace('[', '').replace(']', '')
    return len(t.replace('`', '').replace('*', ''))

def tokens(text):
    raw = text.split()
    out, buf, ticks = [], [], 0
    for w in raw:
        buf.append(w); ticks += w.count('`')
        if ticks % 2 == 0:
            out.append(' '.join(buf)); buf = []
    if buf: out.append(' '.join(buf))
    return out

BAD_START = re.compile(r'^(- |\d+\. |#|> |\+ |\* )')

def wrap(block, width=80):
    lines = block.split('\n')
    first = lines[0]
    if first.startswith('- '):
        p1, p2, body = '- ', '  ', ' '.join(l.strip() for l in lines)[2:]
    else:
        p1, p2, body = '', '', ' '.join(l.strip() for l in lines)
    toks = tokens(body)
    out, cur, curw, pre = [], [], 0, p1
    for t in toks:
        w = rw(t)
        add = w if not cur else curw + 1 + w
        if cur and len(pre) + add > width:
            out.append(pre + ' '.join(cur)); pre = p2; cur, curw = [t], w
        else:
            cur.append(t); curw = add
    if cur: out.append(pre + ' '.join(cur))
    for i, l in enumerate(out[1:], 1):
        if BAD_START.match(l[len(p2):]): sys.exit(f"bad line start: {l}")
    return '\n'.join(out)

def width_report(path):
    infence = False
    for i, s in enumerate(open(path).read().split('\n'), 1):
        if s.startswith('```'): infence = not infence; continue
        if infence or s.startswith('|'): continue
        r = sum(rw(t) for t in s.split()) + max(len(s.split()) - 1, 0) + (len(s) - len(s.lstrip()))
        if r > 80: print(path, i, r)
