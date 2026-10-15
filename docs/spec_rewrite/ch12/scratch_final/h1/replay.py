import re, sys, subprocess
ROOT = "/Users/miguel/.julia/dev/Redstone.jl"
CH = "docs/spec_rewrite/ch12"

def parse(log):
    txt = open(f"{ROOT}/{CH}/{log}").read()
    ents = []
    for m in re.finditer(r"^### (.+?), unit (\w), `units/(\w)/([\w.]+)`\n(.*?)(?=^### |\Z)", txt, re.M | re.S):
        ids, u, u2, fn, body = m.groups()
        fences = re.findall(r"^````\w*\n(.*?)^````\n", body, re.M | re.S)
        ents.append((ids, u2, fn, fences, m.start()))
    return ents

def show(rev, path):
    return subprocess.run(["git", "-C", ROOT, "show", f"{rev}:{CH}/{path}"], capture_output=True, text=True).stdout

def replay(log, base, target, units, files):
    state = {(u, f): show(base, f"units/{u}/{f}") for u in units for f in files}
    n = 0
    for ids, u, fn, fences, pos in parse(log):
        if u not in units or fn not in files: continue
        if len(fences) != 2:
            print("BADFENCE", ids, u, fn, len(fences)); continue
        old, new = fences
        s = state[(u, fn)]
        c = s.count(old)
        if c != 1:
            # try without trailing newline for snippet entries
            o2, n2 = old.rstrip("\n"), new.rstrip("\n")
            c2 = s.count(o2)
            if c2 == 1:
                state[(u, fn)] = s.replace(o2, n2); n += 1; continue
            print(f"MATCH {c}/{c2}", ids, u, fn, repr(old[:80])); continue
        state[(u, fn)] = s.replace(old, new); n += 1
    print(log, "applied", n)
    for k, v in state.items():
        t = show(target, f"units/{k[0]}/{k[1]}")
        print(k, "IDENTICAL" if v == t else "DIFFERS")
        open(f"{ROOT}/{CH}/scratch_final/h1/{log[:-3]}_{k[0]}_{k[1]}", "w").write(v)
    return state

if __name__ == "__main__":
    replay(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4].split(","), sys.argv[5].split(","))
