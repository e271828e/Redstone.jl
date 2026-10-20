"""Paragraph-level edits with rewrap and a replayable log (fix2's scratch tool)."""
import re

ROOT = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14"
LINK = re.compile(r'\[[^\]]*\]\([^)]*\)|\[[^\]]*\]\[[^\]]*\]|`[^`]*`|\$[^$]+\$')


def width(line):
    t = re.sub(r'\[([^\]]+)\]\(#[^)]*\)', r'\1', line)
    t = re.sub(r'\[([^\]]+)\]\[[^\]]*\]', r'\1', t)
    return len(t.replace('*', '').replace('`', ''))


def blocks(lines):
    """Yield (start, end) line-index ranges of editable paragraphs or bullet items."""
    out, i, n = [], 0, len(lines)
    while i < n:
        l = lines[i]
        if not l.strip():
            i += 1; continue
        if l.startswith('```'):
            j = i + 1
            while not lines[j].startswith('```'): j += 1
            i = j + 1; continue
        if l.startswith('|') or l.startswith('#') or l.startswith('$$') or l.startswith('---'):
            j = i
            if l.startswith('$$'):
                while not lines[j].rstrip().endswith('$$') or j == i and lines[j].strip() == '$$': j += 1
            i = j + 1; continue
        j = i + 1
        bullet = l.startswith('- ')
        while j < n and lines[j].strip() and not lines[j].startswith('- ') \
                and not lines[j].startswith('```') and not lines[j].startswith('$$') \
                and not lines[j].startswith('|'):
            j += 1
        out.append((i, j, bullet))
        i = j
    return out


def wrap(text, bullet):
    prot = LINK.sub(lambda m: m.group().replace(' ', '\x00'), text)
    toks = prot.split()
    first, rest = ('- ', '  ') if bullet else ('', '')
    lines, cur = [], first
    for t in toks:
        cand = cur + ('' if cur.strip() == '' or cur in (first, rest) else ' ') + t
        if cur not in (first, rest) and width(cand.replace('\x00', ' ')) > 80:
            lines.append(cur); cur = rest + t
        else:
            cur = cand
    lines.append(cur)
    return [l.replace('\x00', ' ') for l in lines]


class Fixer:
    def __init__(self):
        self.files, self.log = {}, []

    def text(self, u):
        if u not in self.files:
            self.files[u] = open(f"{ROOT}/units/{u}/new.md").read().split('\n')
        return self.files[u]

    def edit(self, fid, unit, find, repl=None, note=None):
        lines = self.text(unit)
        hits = []
        for s, e, b in blocks(lines):
            body = ' '.join(x.strip() for x in lines[s:e])
            if b: body = body[2:]
            if body.count(find) : hits.append((s, e, b, body))
        total = sum(h[3].count(find) for h in hits)
        if total != 1:
            raise SystemExit(f"{fid} {unit}: {find!r} found {total} times")
        s, e, b, body = hits[0]
        new_body = body if repl is None else body.replace(find, repl)
        new = wrap(new_body, b)
        old = lines[s:e]
        lines[s:e] = new
        self.log.append((fid, unit, s + 1, old, new, note))

    def save(self, logpath, header):
        for u, ls in self.files.items():
            open(f"{ROOT}/units/{u}/new.md", 'w').write('\n'.join(ls))
        out = [header]
        for k, (fid, unit, ln, old, new, note) in enumerate(self.log, 1):
            out.append(f"## {k}. {fid}, unit {unit}, from line {ln} of the edited file\n")
            if note: out.append(note + "\n")
            out.append("Old:\n\n````text\n" + '\n'.join(old) + "\n````\n")
            out.append("New:\n\n````text\n" + '\n'.join(new) + "\n````\n")
        open(logpath, 'w').write('\n'.join(out))
