"""Rewrap paragraphs of a markdown file to 80 rendered columns.

python3 wrap.py FILE START END   rewraps the paragraph(s) within lines START..END
python3 wrap.py FILE check       prints prose lines over 80 rendered columns
Rendered width collapses link markup and drops '*'.
"""
import re, sys

LINK = re.compile(r'\[([^\]]+)\](\(#[^)]*\)|\[[^\]]*\])')


def mask(s):
    """Per-character flags: True where the character renders."""
    keep = [c != '*' for c in s]
    for m in LINK.finditer(s):
        keep[m.start()] = False                      # '['
        for k in range(m.end(1), m.end()): keep[k] = False  # '](...)'
    return keep


def width(s):
    return sum(mask(s))


def wrap_para(lines):
    first = lines[0]
    bullet = first.startswith('- ')
    text = ' '.join(l.strip() for l in lines)
    if bullet: text = text[2:]
    keep = mask(text)
    words, out, cur, curw = [], [], '', 0
    pos = 0
    code = [False] * len(text)
    for m in re.finditer(r'`[^`]*`', text):
        for k in range(m.start(), m.end()): code[k] = True
    for m in re.finditer(r'\S+', text):
        w = (m.group(), sum(keep[m.start():m.end()]))
        if words and code[m.start()] and m.start() > 0 and code[m.start() - 1]:
            pw, pww = words.pop(); w = (pw + ' ' + w[0], pww + 1 + w[1])
        words.append(w)
    prefix, indent = ('- ', '  ') if bullet else ('', '')
    lead = prefix
    for w, ww in words:
        if not cur:
            cur, curw = lead + w, len(lead) + ww
        elif curw + 1 + ww <= 80:
            cur += ' ' + w; curw += 1 + ww
        else:
            out.append(cur); lead = indent
            cur, curw = lead + w, len(lead) + ww
    out.append(cur)
    return out


def main():
    path = sys.argv[1]
    L = open(path).read().split('\n')
    if sys.argv[2] == 'check':
        fence, para = False, []
        def flush():
            if not para: return
            text = '\n'.join(l for _, l in para); keep = mask(text); i = 0
            for n, l in para:
                w = sum(keep[i:i + len(l)]); i += len(l) + 1
                if w > 80: print(n, w, l[:60])
            para.clear()
        for n, l in enumerate(L, 1):
            if l.startswith('```'): flush(); fence = not fence; continue
            if fence or l.startswith('|'): continue
            if not l.strip(): flush(); continue
            para.append((n, l))
        flush()
        return
    a, b = int(sys.argv[2]) - 1, int(sys.argv[3])
    seg, out, para = L[a:b], [], []
    for l in seg + ['']:
        if l.strip() == '' or (l.startswith('- ') and para):
            if para: out += wrap_para(para); para = []
            if l.strip() == '': out.append(l); continue
        para.append(l)
    out = out[:-1]
    L[a:b] = out
    open(path, 'w').write('\n'.join(L))


main()
