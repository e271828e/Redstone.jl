"""apply.py ITEM UNIT OLD NEW: replace OLD by NEW (whitespace-insensitive) in the
one paragraph or bullet of units/UNIT/new.md that holds it, rewrap it to 80
rendered columns, and append the old and new blocks to ruled_edits_2.md."""
import re, sys
sys.path.insert(0, __file__.rsplit('/', 1)[0])
from wrap import wrap
item, u, old, new = sys.argv[1:5]
path = f'units/{u}/new.md'
L = open(path).read().split('\n')
# items: runs of non-blank lines, split before lines starting with "- "
items, cur = [], []
for i, l in enumerate(L):
    if not l.strip() or re.match(r'- ', l) or l.startswith('#'):
        if cur: items.append(cur); cur = []
        if l.strip() and not l.startswith('#'): cur = [i]
    else:
        cur.append(i)
if cur: items.append(cur)
col = lambda s: re.sub(r'\s+', ' ', s).strip()
o = col(old)
hits = [it for it in items if o in col(' '.join(L[k] for k in it))]
assert len(hits) == 1, f'{len(hits)} hits'
it = hits[0]; a, b = it[0], it[-1]
block = L[a:b+1]
text = col(' '.join(block))
assert text.count(o) == 1
text = text.replace(o, col(new))
m = re.match(r'(- )', block[0])
if m:
    out = wrap(text[2:], prefix='- ', cont='  ')
else:
    out = wrap(text)
L[a:b+1] = out
open(path, 'w').write('\n'.join(L))
with open('ruled_edits_2.md', 'a') as f:
    f.write(f'\n## {item}, unit {u}, from line {a+1} of the edited file\n\nOld:\n\n````text\n'
            + '\n'.join(block) + '\n````\n\nNew:\n\n````text\n' + '\n'.join(out) + '\n````\n')
print('\n'.join(block)); print('---->'); print('\n'.join(out))
