import sys, os
sys.path.insert(0, "checks")
from build_inventory import blocks
u = sys.argv[1]; ids = sys.argv[2:]
text = open(f"ch13/units/{u}/claims.md").read()
L = text.split("\n")
n = 0
for start, b in blocks(text):
    if "added" in b:
        if "added" in ids: print(start, "ADDED", b["added"][:120])
        continue
    n += 1
    if f"C-{n:03d}" in ids:
        i = start - 1
        print(f"--- C-{n:03d} line {start}")
        while i < len(L) and L[i].strip():
            print(f"{i+1}: {L[i]}"); i += 1
