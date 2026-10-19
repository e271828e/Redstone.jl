"""rep.py FILE OLDFILE NEWFILE: replace the one occurrence of OLD with NEW."""
import sys
p, o, n = sys.argv[1:4]
s = open(p).read(); old = open(o).read().rstrip('\n'); new = open(n).read().rstrip('\n')
assert s.count(old) == 1, s.count(old)
open(p, 'w').write(s.replace(old, new))
