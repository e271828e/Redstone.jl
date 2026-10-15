import re
W = 80
ATOM = re.compile(r'\[(?:[^\[\]]|\[[^\]]*\])*\](?:\([^)]*\)|\[[^\]]*\])|`[^`]+`')

def rw(s):
    s = re.sub(r'\[((?:[^\[\]]|\[[^\]]*\])*)\](?:\([^)]*\)|\[[^\]]*\])', r'\1', s)
    return len(s)

BAD_START = re.compile(r'^(- |\+ |\* |#|>|\||\d+[.)] )')

def wrap(text, first='', cont=''):
    text = ' '.join(text.split())
    prot = ATOM.sub(lambda m: m.group(0).replace(' ', '\x00'), text)
    words = [w.replace('\x00', ' ') for w in prot.split(' ')]
    lines, cur = [], []
    def width(ws, pre): return rw(pre + ' '.join(ws))
    for w in words:
        pre = first if not lines else cont
        if cur and width(cur + [w], pre) > W:
            lines.append(cur); cur = [w]
        else:
            cur.append(w)
    lines.append(cur)
    # avoid markdown-significant line starts
    for i in range(1, len(lines)):
        while BAD_START.match(' '.join(lines[i])) and len(lines[i-1]) > 1:
            lines[i].insert(0, lines[i-1].pop())
    out = []
    for i, ws in enumerate(lines):
        out.append((first if i == 0 else cont) + ' '.join(ws))
    return '\n'.join(out)

def blocks(src):
    """Yield (start, end) char spans of paragraphs / bullet items."""
    lines = src.split('\n')
    spans, i, pos = [], 0, []
    off = 0
    for l in lines:
        pos.append(off); off += len(l) + 1
    n = len(lines)
    infence = False
    while i < n:
        l = lines[i]
        if l.startswith('```'):
            infence = not infence; i += 1; continue
        if infence or not l.strip() or l.startswith('|') or l.startswith('#'):
            i += 1; continue
        j = i + 1
        while j < n and lines[j].strip() and not lines[j].startswith('- ') \
                and not lines[j].startswith('```') and not lines[j].startswith('|'):
            j += 1
        spans.append((pos[i], pos[j-1] + len(lines[j-1])))
        i = j
    return spans

def para_containing(src, phrase):
    hits = []
    for a, b in blocks(src):
        if phrase in ' '.join(src[a:b].split()):
            hits.append((a, b))
    assert len(hits) == 1, (phrase, len(hits))
    return hits[0]

def rewrap_block(block_text, reps):
    first_line = block_text.split('\n')[0]
    if first_line.startswith('- '):
        first, cont, body = '- ', '  ', ' '.join(block_text.split())[2:]
    else:
        first, cont, body = '', '', ' '.join(block_text.split())
    for o, nw in reps:
        assert body.count(o) == 1, (o, body.count(o))
        body = body.replace(o, nw)
    return wrap(body, first, cont)
