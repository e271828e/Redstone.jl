"""Write units/<U>/brief.md, the chapter's brief with the rulings that do
not reach unit U reduced to one-line stubs. From docs/spec_rewrite:

    python3 checks/slice_brief.py ch12 A

A ruling is a bullet `- **Rn. ...** (...)` under a `## Rulings ...`
heading. It reaches U when U's block under `## The units` names Rn, or
when the ruling's first line names no unit at all (`unit A`, `units B, C`
or `units: all` in its parenthetical). Everything else is copied as is.
The verifier reads the whole brief.md, never a slice.
"""
import os, re, sys

RULING = re.compile(r'^- \*\*(R\d+)\.')
ITEM = re.compile(r'^  - \**([A-Z]+\d+)\b')
UNITS_IN = re.compile(r'\bunits?:?\s+([A-Z]\d?(?:\s*(?:,|and|\s)\s*[A-Z]\d?)*)')


def named_in_block(brief, u):
    m = re.search(r'^## The units\n(.*?)(?=^## |\Z)', brief, re.S | re.M)
    if not m: raise SystemExit("no '## The units' section")
    blocks = re.split(r'\n(?=\*\*[A-Z]\d?:)', m.group(1))
    mine = [b for b in blocks if b.startswith(f"**{u}:")]
    if not mine: raise SystemExit(f"no block for unit {u} under '## The units'")
    return set(re.findall(r'\bR\d+\b', mine[0]))


def header_units(head):
    """The units a ruling's or correction's opening parenthetical names:
    None when it names none, "all" for every unit, else a set."""
    par = re.search(r'\(([^)]*)\)', " ".join(l.strip() for l in head))
    if not par: return None
    if re.search(r'\bunits?:?\s+(all|every)\b', par.group(1)): return "all"
    found = set()
    for m in UNITS_IN.finditer(par.group(1)): found |= set(re.findall(r'[A-Z]\d?', m.group(1)))
    return found or None


def slice_items(block, u):
    """Inside a kept ruling, drop the `  - Fn (unit X ...)` items for other units."""
    out, i, dropped = [], 0, []
    while i < len(block):
        m = ITEM.match(block[i])
        if not m:
            out.append(block[i]); i += 1; continue
        j = i + 1
        while j < len(block) and not ITEM.match(block[j]) and block[j].startswith("    "): j += 1
        units = header_units(block[i:j][:3])
        if units is None or units == "all" or u in units:
            out += block[i:j]
        else:
            out.append(f"  - {m.group(1)} (units {', '.join(sorted(units))}; see brief.md)"); dropped.append(m.group(1))
        i = j
    return out, dropped


def slice(brief, u):
    named = named_in_block(brief, u)
    out, lines, i, in_rulings, stubbed = [], brief.split("\n"), 0, False, []
    while i < len(lines):
        line = lines[i]
        if line.startswith("## "): in_rulings = line.lower().startswith("## rulings")
        m = RULING.match(line) if in_rulings else None
        if not m:
            out.append(line); i += 1; continue
        j = i + 1
        while j < len(lines) and not (RULING.match(lines[j]) or lines[j].startswith("## ")): j += 1
        while j > i + 1 and not lines[j - 1].strip(): j -= 1
        r, units = m.group(1), header_units(lines[i:j][:3])
        if r in named or units is None or units == "all" or u in units:
            kept, dropped = slice_items(lines[i:j], u)
            out += kept; stubbed += [f"{r}'s {d}" for d in dropped]
        else:
            out.append(f"- {r} reaches units {', '.join(sorted(units))}, not this one; see brief.md.")
            stubbed.append(r)
        i = j
    head = (f"<!-- Sliced for unit {u} by checks/slice_brief.py. Rulings for other units are "
            f"stubs; the full text is brief.md. -->\n")
    return head + "\n".join(out), stubbed


if __name__ == "__main__":
    root, u = os.path.abspath(sys.argv[1]), sys.argv[2]
    brief = open(os.path.join(root, "brief.md")).read()
    text, stubbed = slice(brief, u)
    out = os.path.join(root, "units", u, "brief.md")
    open(out, "w").write(text)
    print(f"wrote {out}: {len(text.split(chr(10)))} lines of {len(brief.split(chr(10)))}; stubbed {', '.join(stubbed) or 'nothing'}")
