import sys, re, difflib
H = sys.argv[1]
for u in ["F","G1","G2","H","J"]:
    a = open(f"{H}/replay_fixes/{u}.md").read(); b = open(f"{H}/c3d69f1/{u}/new.md").read()
    ta, tb = a.split(), b.split()
    print(u, "tokens equal" if ta == tb else "TOKENS DIFFER")
    if ta != tb:
        for l in difflib.unified_diff(ta, tb, lineterm="", n=5): print("   ", l)
    fa = re.findall(r"^```.*?^```", a, re.S|re.M); fb = re.findall(r"^```.*?^```", b, re.S|re.M)
    print("  fences", len(fa), len(fb), "byte-identical" if fa == fb else "FENCES DIFFER")
    # headings, table rows byte identical
    ha = [l for l in a.splitlines() if l.startswith(("#","|"))]; hb = [l for l in b.splitlines() if l.startswith(("#","|"))]
    print("  headings/tables", "identical" if ha == hb else "DIFFER")
