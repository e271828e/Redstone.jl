"""Print every entry's Position field, one line per entry: positions.py <decisions.md> > out"""
import re, sys
text = open(sys.argv[1]).read().split('<!-- citation link definitions')[0]
for m in re.finditer(r'^### (D-\d{3}) — .*?(?=^### D-|\Z)', text, re.S | re.M):
    body = m.group(0)
    st = re.search(r'\*\*Status\.\*\* (.*)', body).group(1)
    p = re.search(r'\*\*Position\.\*\*(.*?)(?=^\*\*(Spec|Rationale)\.\*\*)', body, re.S | re.M)
    pos = ' '.join(p.group(1).split()) if p else ''
    pos = re.sub(r'\]\[[^\]]*\]', ']', pos).replace('[', '').replace(']', '')
    print(f"{m.group(1)} [{st[:12]}] {pos}")
