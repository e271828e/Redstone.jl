"""Parse decisions.md into entries; print or grep fields.

usage: entries.py show D-108 [D-139 ...]     print whole entries
       entries.py pos REGEX                  grep Positions (unlinked text)
       entries.py spec D-108 ...             print Spec fields
"""
import re, sys

LOG = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md"
LINK = re.compile(r"\[([^\]]+)\]\[[^\]]+\]")

def entries():
    lines = open(LOG).read().split("\n")
    out, cur = {}, None
    for i, l in enumerate(lines, 1):
        if l.startswith("<!-- citation link definitions"):
            break
        m = re.match(r"### (D-\d{3}) — (.*)", l)
        if m:
            cur = m.group(1)
            out[cur] = {"title": m.group(2), "start": i, "lines": []}
            continue
        if cur:
            out[cur]["lines"].append((i, l))
    for d, e in out.items():
        fields, f, base = {}, None, None
        for i, l in e["lines"]:
            m = re.match(r"\*\*(Status|Position|Spec|Rationale|Rejected|Divergence)\.\*\*", l)
            if m:
                f = base = m.group(1)
            elif re.match(r"\s*Annotation \(", l):
                f = "Annotation@%d" % i
            elif f and f.startswith("Annotation@") and l.startswith("- ") and base:
                f = base
            elif l.startswith("## "):
                f = None
            if f:
                fields.setdefault(f, []).append((i, l))
        e["fields"] = fields
    return out

def plain(s):
    return LINK.sub(r"\1", s)

if __name__ == "__main__":
    E = entries()
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd == "show":
        for d in args:
            e = E[d]
            print("### %s — %s  (line %d)" % (d, e["title"], e["start"]))
            for i, l in e["lines"]:
                if l.startswith("### ") or l.startswith("## "):
                    break
                print("%6d %s" % (i, plain(l)))
    elif cmd == "pos":
        rx = re.compile(args[0])
        for d, e in E.items():
            txt = " ".join(plain(l) for _, l in e["fields"].get("Position", []))
            txt = re.sub(r"\s+", " ", txt)
            for m in rx.finditer(txt):
                a, b = max(0, m.start() - 90), m.end() + 90
                st = plain(e["fields"]["Status"][0][1]) if "Status" in e["fields"] else ""
                print("%s [%s]: ...%s..." % (d, st.replace("**Status.** ", ""), txt[a:b]))
    elif cmd == "spec":
        for d in args:
            print(d, plain(" ".join(l for _, l in E[d]["fields"].get("Spec", []))))
