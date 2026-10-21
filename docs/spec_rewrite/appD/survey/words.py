"""Rendered word count per Appendix D entry: anchor dropped, section
citations and D-citations dropped, link markup collapsed. Usage:
python3 words.py appD.md [first_spec_line]"""
import re, sys
path = sys.argv[1]; base = int(sys.argv[2]) if len(sys.argv) > 2 else 14322
lines = open(path).read().split('\n')
starts = [i for i, l in enumerate(lines) if l.startswith('<a id="g-')]
for k, i in enumerate(starts):
    j = starts[k+1] if k+1 < len(starts) else len(lines)
    body = []
    for l in lines[i:j]:
        if l.startswith('### ') or l.startswith('<!--'): break
        body.append(l)
    t = ' '.join(body)
    a = re.match(r'<a id="(g-[^"]+)"></a>', t).group(1)
    t = re.sub(r'<a id="[^"]+"></a>', '', t)
    t = re.sub(r'\[§[^\]]+\]\[[^\]]+\]', '', t)
    t = re.sub(r'\bD-\d{3}\b', '', t)
    t = re.sub(r'\[([^\]]+)\]\([^)]*\)', r'\1', t)
    t = re.sub(r'\(\s*(,\s*)*\)', '', t)
    print(f"{a}\t{base+i}\t{len(t.split())}")
