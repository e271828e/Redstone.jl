"""Inbound citations of chapter 13 at BASE: one row per §13 or §13.N occurrence
outside the chapter, the Contents block and link-definition lines."""
import re, subprocess, sys
BASE, LO, HI = "1fee0fc", 9909, 11141
FILES = ["spec.md", "decisions.md", "extensions.md", "implementation.md", "pending.md"]
ls = subprocess.run(["git", "ls-tree", "--name-only", BASE, "docs/design/companions/"],
                    capture_output=True, text=True, check=True).stdout.split()
FILES += [f.removeprefix("docs/design/") for f in ls]
PAT = re.compile(r"§13(?:\.(\d+))?(?![\d.]\d)")
LINKDEF = re.compile(r"^\[[^\]]+\]:\s")
FIELD = re.compile(r"^\*\*(Status|Position|Spec|Rationale|Rejected)\.\*\*|^(Annotation)\b")
ENTRY = re.compile(r"^### (D-\d+)")
out = ["file\tline\tcited\tentry\tfield\tsentence"]
for f in FILES:
    text = subprocess.run(["git", "show", f"{BASE}:docs/design/{f}"],
                          capture_output=True, text=True, check=True).stdout.splitlines()
    entry = field = ""
    in_contents = False
    for i, line in enumerate(text, 1):
        if f == "spec.md":
            if line.startswith("## Contents"): in_contents = True
            elif in_contents and line.startswith("# Part I"): in_contents = False
            if in_contents or LO <= i <= HI: continue
        if f == "decisions.md":
            m = ENTRY.match(line)
            if m: entry, field = m.group(1), ""
            m = FIELD.match(line)
            if m: field = m.group(1) or m.group(2)
        if LINKDEF.match(line): continue
        for m in PAT.finditer(line):
            cited = "§13" + (f".{m.group(1)}" if m.group(1) else "")
            out.append("\t".join([f, str(i), cited, entry if f == "decisions.md" else "",
                                  field if f == "decisions.md" else "", line.strip()]))
sys.stdout.write("\n".join(out) + "\n")
