import re, sys, pathlib
D = pathlib.Path(__file__).parent
CH = D.parent.parent
units = {u: (D / f"{u}.verified.md").read_text() for u in "FGH"}

def entries(path):
    text = (CH / path).read_text()
    parts = re.split(r"^## ", text, flags=re.M)[1:]
    out = []
    for p in parts:
        head = p.split("\n", 1)[0]
        m = re.search(r"unit ([FGH])", head)
        blocks = re.findall(r"````text\n(.*?)````", p, flags=re.S)
        out.append((path, head, m.group(1) if m else None, blocks))
    return out

log = []
for path in ["chapter_fixes_2.md", "ruled_edits_2.md"]:
    for path_, head, u, blocks in entries(path):
        if u is None:
            continue
        if "P2-18" in head:
            s = units["F"]
            assert s.endswith("\n\n"), "F does not end in blank line"
            units["F"] = s[:-1]
            log.append(f"OK {path} {head}")
            continue
        if len(blocks) != 2:
            log.append(f"?? {path} {head}: {len(blocks)} blocks")
            continue
        old, new = blocks
        s = units[u]
        n = s.count(old)
        if n != 1:
            # try stripping trailing newline
            log.append(f"FAIL {path} {head}: old occurs {n} times")
            continue
        line = s[: s.index(old)].count("\n") + 1
        units[u] = s.replace(old, new)
        log.append(f"OK {path} {head} (at line {line})")

print("\n".join(log))
for u in "FGH":
    (D / f"{u}.replayed.md").write_text(units[u])
    cur = (D / f"{u}.current.md").read_text()
    print(u, "IDENTICAL" if cur == units[u] else "DIFFERS")
