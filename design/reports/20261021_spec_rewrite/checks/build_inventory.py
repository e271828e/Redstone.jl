"""Build units/<U>/inventory.json from units/<U>/claims.md, then run the
checker. From docs/spec_rewrite:

    python3 checks/build_inventory.py ch12 A

claims.md holds one block per claim, blocks separated by blank lines, one
field per line, in any order:

    old: <the claim's verbatim span in the normalized old text>
    new: <its verbatim span in the normalized new text; omit when identical>
    tag: F | X | M | C | R
    ruling: R7              required with tag R
    where: units/B/old.md   omit for a span in this unit's new.md
    newcites: §11.3 D-174   the citations the new text attaches, when they
                            differ from the old span's, written as in the text
    note: <free text, kept>

and one block per declared addition:

    added: <the new sentence or clause with no old source, normalized>

A line starting with # is a comment. The tool fills `id` and `cites`,
refuses to write on any error, and runs check_unit.py on success.
Normalized text is what `check_unit.py show-old` and `show-new` print.
"""
import json, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.dont_write_bytecode = True
sys.path.insert(0, HERE)
from norm import norm

CITE = re.compile(r'§\d+(?:\.\d+)?|D-\d{3}|Appendix [A-D]')
FIELDS = {"old", "new", "tag", "ruling", "where", "newcites", "note", "added"}
TAGS = {"F", "X", "M", "C", "R"}


def blocks(text):
    cur, out, start = {}, [], 1
    for n, line in enumerate(text.split("\n"), 1):
        if line.startswith("#"):
            continue
        if not line.strip():
            if cur: out.append((start, cur)); cur = {}
            continue
        if not cur: start = n
        key, sep, val = line.partition(":")
        if not sep or key.strip() not in FIELDS:
            raise SystemExit(f"line {n}: not a field: {line[:60]!r}")
        key = key.strip()
        if key in cur:
            raise SystemExit(f"line {n}: {key} given twice")
        cur[key] = norm(val)
    if cur: out.append((start, cur))
    return out


def build(root, u):
    path = os.path.join(root, "units", u, "claims.md")
    claims, added, bad = [], [], 0
    for start, b in blocks(open(path).read()):
        if "added" in b:
            if len(b) > 1: print(f"line {start}: an added block takes no other field"); bad += 1
            added.append(b["added"]); continue
        if "old" not in b:
            print(f"line {start}: claim without old"); bad += 1; continue
        tag = b.get("tag", "F")
        if tag not in TAGS:
            print(f"line {start}: tag {tag!r} not one of F X M C R"); bad += 1
        if tag == "R" and "ruling" not in b:
            print(f"line {start}: tag R without ruling"); bad += 1
        new = b.get("new", b["old"])
        where = b.get("where", "new")
        cites = sorted(set(CITE.findall(b["old"])))
        d = {"id": f"C-{len(claims) + 1:03d}", "old": b["old"], "new": new,
             "where": where, "cites": cites}
        if "newcites" in b:
            d["newcites"] = sorted(set(CITE.findall(b["newcites"])))
        elif where == "new" and set(CITE.findall(new)) != set(cites):
            print(f"line {start}: note, the span's citations changed ({cites} -> "
                  f"{sorted(set(CITE.findall(new)))}) with no newcites; the checker "
                  "wants the old ones in the same paragraph")
        d["tag"] = tag
        for k in ("ruling", "note"):
            if k in b: d[k] = b[k]
        claims.append(d)
    if bad:
        raise SystemExit(f"errors: {bad}; inventory.json not written")
    out = os.path.join(root, "units", u, "inventory.json")
    json.dump({"claims": claims, "added": added}, open(out, "w"), indent=1, ensure_ascii=False)
    print(f"wrote {out}: {len(claims)} claims, {len(added)} added")


if __name__ == "__main__":
    root, u = os.path.abspath(sys.argv[1]), sys.argv[2]
    build(root, u)
    sys.exit(subprocess.call([sys.executable, os.path.join(HERE, "check_unit.py"), root, "check", u]))
