"""B78: list every D-nnn the landed chapter 13 cites, per section, against
each entry's Spec field. Prints the (entry, section) pairs the field omits.

Usage: python3 -I spec_fields.py <repo root>
"""
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
spec = (root / "docs/design/spec.md").read_text().splitlines()
log = (root / "docs/design/decisions.md").read_text()

# Chapter 13 runs from its heading to chapter 14's.
start = next(i for i, l in enumerate(spec) if l.startswith("## 13. "))
end = next(i for i, l in enumerate(spec) if l.startswith("## 14. "))

cites = {}  # entry -> {section: [spec line numbers]}
section = "§13"
for i in range(start, end):
    line = spec[i]
    m = re.match(r"### (13\.\d+) ", line)
    if m:
        section = "§" + m.group(1)
    for d in re.findall(r"\[(D-\d{3})\]\[d-\d{3}\]", line):
        cites.setdefault(d, {}).setdefault(section, []).append(i + 1)

# Each entry's Spec field, which may wrap over several lines.
fields = {}
for m in re.finditer(r"^### (D-\d{3}) — .*?(?=^### D-|\Z)", log, re.M | re.S):
    body = m.group(0)
    s = re.search(r"^\*\*Spec\.\*\* (.*?)(?:\n\n|\Z)", body, re.M | re.S)
    status = re.search(r"^\*\*Status\.\*\* (.*)$", body, re.M).group(1)
    secs = re.findall(r"\[(§[\dA-D.]+|Appendix [A-D])\]", s.group(1)) if s else []
    fields[m.group(1)] = (secs, s is not None, status)

missing = []
for d in sorted(cites):
    secs, has, status = fields[d]
    for sec, lines in sorted(cites[d].items()):
        # The bare §13 is the chapter: any §13.x in the field covers it.
        covered = sec in secs or (sec == "§13" and any(x.startswith("§13") for x in secs))
        if not covered:
            missing.append((d, sec, lines, secs, status))

print(f"{len(cites)} entries cited in chapter 13; {len(missing)} (entry, section) pairs absent from the Spec field\n")
for d, sec, lines, secs, status in missing:
    field = ", ".join(secs) if secs else "(no Spec field)"
    sup = "" if status == "ratified" else f"  [{status}]"
    print(f"{d} {sec} at spec {','.join(map(str, lines))}; field: {field}{sup}")
