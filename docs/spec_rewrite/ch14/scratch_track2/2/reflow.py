"""Push overflow words forward from each given line until every line of its
paragraph renders at 80 columns or less. usage: reflow.py FILE LINE..."""
import sys
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_track2/2")
from cols import rendered, width
f = sys.argv[1]
lines = open(f).read().split("\n")
W = lambda s: width(rendered(s))
for start in sorted((int(a) for a in sys.argv[2:]), reverse=True):
    i = start - 1
    while W(lines[i]) > 80:
        moved = []
        while W(lines[i]) > 80:
            head, _, last = lines[i].rpartition(" ")
            lines[i] = head; moved.insert(0, last)
        nxt = i + 1
        if nxt >= len(lines) or lines[nxt].strip() == "" or lines[nxt].startswith(("#", "|", "```", "- ")):
            lines.insert(nxt, " ".join(moved))
        else:
            lines[nxt] = " ".join(moved) + " " + lines[nxt]
        print("line %d: moved %r" % (i + 1, " ".join(moved)))
        i = nxt
open(f, "w").write("\n".join(lines))
