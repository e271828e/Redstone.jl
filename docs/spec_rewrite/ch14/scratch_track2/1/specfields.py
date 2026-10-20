"""List every D-nnn the landed chapter 14 cites, per section, against each
entry's Spec field. Prints the entries cited in a §14.x that their Spec
field lacks (neither §14.x nor bare §14), with the citing lines."""
import re, sys
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_track2/1")
from entries import entries, plain

SPEC = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/spec.md"
lines = open(SPEC).read().split("\n")
start = next(i for i, l in enumerate(lines) if l.startswith("## 14. "))
end = next(i for i, l in enumerate(lines) if i > start and l.startswith("## ") )
sec, cites = "14", {}
for i in range(start, end):
    l = lines[i]
    m = re.match(r"### (14\.\d+) ", l)
    if m:
        sec = m.group(1)
    for d in re.findall(r"\[(D-\d{3})\]\[", l):
        cites.setdefault((d, sec), []).append(i + 1)

E = entries()
def specset(d):
    txt = plain(" ".join(l for _, l in E[d]["fields"].get("Spec", [])))
    return set(re.findall(r"§(\d+(?:\.\d+)?)", txt))

def status(d):
    return plain(E[d]["fields"]["Status"][0][1]).replace("**Status.** ", "")

missing = []
for (d, sec), ls in sorted(cites.items()):
    s = specset(d)
    if sec not in s and "14" not in s:
        missing.append((d, sec, ls))
print("cited (entry, section) pairs: %d; entries: %d" % (len(cites), len({d for d, _ in cites})))
print("pairs whose Spec field lacks the section: %d" % len(missing))
for d, sec, ls in missing:
    print("%s  §%s  lines %s  [%s]  Spec: %s" % (d, sec, ",".join(map(str, ls)), status(d),
          ", ".join(sorted(specset(d), key=lambda x: [int(p) for p in x.split(".")])) or "(none)"))
