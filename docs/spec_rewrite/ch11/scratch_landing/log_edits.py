import re, sys
p = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md"
t = open(p, encoding="utf-8").read()

def bare(s):
    return re.sub(r"\[(§[\d.]+|Appendix [A-Z])\]\[[^\]]+\]", r"\1", s)

# entry -> sections to add (B-13), or a full replacement (B-4, B-12)
adds = {
 "031": ["§11.3"], "044": ["§11.4"], "045": ["§11.4", "§11.6"],
 "047": ["§11.2", "§11.5", "§11.7"], "083": ["§11.2"], "101": ["§11.1"],
 "105": ["§11.4"], "106": ["§11.4", "§11.6"], "130": ["§11.2"],
 "194": ["§11.2"], "200": ["§11.3", "§11.4"], "215": ["§11.3"],
 "216": ["§11.3", "§11.6"], "218": ["§11.5"], "293": ["§11.2"],
 "305": ["§11.8"], "316": ["§11.5"], "319": ["§11.5"],
}
full = {"250": "§9.2, §11.6, §11.8, §13.2, Appendix C",
        "201": "§11.8, §12.4, §13.2, Appendix C"}

def key(c):
    if c.startswith("§"):
        return (0, tuple(int(x) for x in c[1:].split(".")))
    return (1, c)

def field_span(d):
    h = t.index(f"\n### D-{d} — ")
    s = t.index("\n**Spec.** ", h) + 1
    nxt = t.find("\n### D-", h + 1)
    assert s < nxt, d
    e = t.index("\n\n", s)
    return s, e

for d in sorted(set(adds) | set(full)):
    s, e = field_span(d)
    old = t[s:e]
    body = bare(old[len("**Spec.** "):])
    lines = body.split("\n")
    cites = [c.strip() for c in body.replace("\n", " ").split(",") if c.strip()]
    if d in full:
        new_cites = [c.strip() for c in full[d].split(",")]
        assert "§11.3" in cites if d == "250" else "§11.2" in cites
    else:
        for c in adds[d]:
            assert c not in cites, (d, c)
        new_cites = sorted(cites + adds[d], key=key)
        assert sorted(cites, key=key) == cites, (d, "unsorted")
    if len(lines) == 2:  # D-194: keep the break before the appendices
        sec = [c for c in new_cites if c.startswith("§")]
        app = [c for c in new_cites if not c.startswith("§")]
        new = "**Spec.** " + ", ".join(sec) + ",\n" + ", ".join(app)
    else:
        new = "**Spec.** " + ", ".join(new_cites)
    print(f"D-{d}: {new}")
    t = t[:s] + new + t[e:]

# B-10: D-102 annotation after its Rationale paragraph
h = t.index("\n### D-102 — ")
r = t.index("\n**Rationale.** ", h)
e = t.index("\n\n", r)
assert t[e:e+15] == "\n\n**Rejected.**"
ann = ("Annotation (2026-10-13): amended by D-366. Only `loop` is mandatory;\n"
       "`init!`, `shutdown!` and `unblock!` are optional hooks with no-op defaults.")
t = t[:e] + "\n\n" + ann + t[e:]

# D-366 before the link-definition block
entry = """### D-366 — Make `loop` the device contract's one mandatory function

**Status.** ratified

**Position.** A device must define `loop(dev, handle)`, and `attach!` refuses
a device with no `loop` method (`DeviceContractMismatch`, D-216). `init!`,
`shutdown!` and `unblock!` are optional, each with a no-op default.

**Spec.** §11.6

**Rationale.** A device with no OS resources has nothing to acquire or
release, so a mandatory `init!` or `shutdown!` would only force empty
methods. The code already gives the three hooks no-op defaults
(`src/devices.jl` 67–85). The owner ruled this on 2026-10-13, when chapter
11's rewrite found the spec reading as three mandatory functions. This
amends D-102's contract list.

**Rejected.**
- *Mandatory `init!` and `shutdown!`, as §11.6 read before ("four functions,
  one optional"):* every device without OS resources would define two empty
  methods.

"""
m = "<!-- citation link definitions"
assert t.count(m) == 1
t = t.replace(m, entry + m)

# Index row
row365 = t[t.index("| [D-365][d-365] |"):]
row365 = row365[:row365.index("\n") + 1]
assert t.count(row365) == 1
t = t.replace(row365, row365 + "| D-366 | Make `loop` the device contract's one mandatory function | ratified |\n")
open(p, "w", encoding="utf-8").write(t)
