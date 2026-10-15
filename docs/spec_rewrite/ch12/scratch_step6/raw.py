"""raw.py FILE LOG ITEM UNIT SPECFILE: exact unique replacement, logged verbatim."""
import sys
_, path, log, item, unit, spec = sys.argv
old, new = open(spec).read().rstrip('\n').split('\n=====\n')
s = open(path).read()
if s.count(old) != 1: sys.exit(f'old found {s.count(old)} times')
open(path, 'w').write(s.replace(old, new))
fence = 'markdown' if path.endswith('new.md') else 'text'
with open(log, 'a') as f:
    f.write(f'### {item}, unit {unit}, `{path.split("ch12/")[-1]}`\n\nOld:\n\n````{fence}\n{old}\n````\n\nNew:\n\n````{fence}\n{new}\n````\n\n')
print('ok')
