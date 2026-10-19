import sys
class C:
    def __init__(s, u): s.p = f"ch13/units/{u}/claims.md"; s.L = open(s.p).read().split("\n")
    def find(s, line):
        idx = [i for i, l in enumerate(s.L) if l == line]
        assert len(idx) == 1, (line[:80], len(idx)); return idx[0]
    def rep(s, line, *new):
        i = s.find(line); s.L[i:i+1] = list(new)
    def after(s, line, *added):
        i = s.find(line)
        while i < len(s.L) and s.L[i].strip(): i += 1
        ins = []
        for a in added: ins += ["", a]
        s.L[i:i] = ins
    def save(s): open(s.p, "w").write("\n".join(s.L))
