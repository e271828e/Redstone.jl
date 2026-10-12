# Inbound citations of spec chapters 1 to 4 at the frozen base d3af35a.
import re, subprocess
BASE = "d3af35a"
D = "docs/design/"
R = "/Users/miguel/.julia/dev/Redstone.jl"
def show(f):
    return subprocess.run(["git", "show", f"{BASE}:{D}{f}"], capture_output=True, text=True,
                          check=True, cwd=R).stdout
comps = subprocess.run(["git", "ls-tree", "--name-only", BASE, D + "companions/"], capture_output=True,
                       text=True, cwd=R).stdout.split()
files = ["spec.md", "decisions.md", "extensions.md", "implementation.md", "pending.md"] + \
        sorted(c[len(D):] for c in comps)
PAT = re.compile(r"§([1-4])(?:\.([0-9]+))?(?![0-9])")
# spec heading anchors of chapters 1-4, by slug prefix
ANCH = re.compile(r"spec\.md#(1-introduction|2-formalism|21-events|22-exclusions|3-component-taxonomy|3[1-4]-[a-z]|4-ports|4[1-4]-[a-z])[a-z0-9-]*")
FIELD = re.compile(r"^\*\*(Status|Position|Spec|Rationale|Rejected|Divergence)\.\*\*")

def para_bounds(lines, i):
    def is_start(l):
        s = l.lstrip()
        return s.startswith(("- ", "* ", "|", "#", "```", ">")) or re.match(r"^\d+\. ", s)
    a = i
    while a > 0 and lines[a-1].strip() and not is_start(lines[a]):
        a -= 1
    b = i
    while b + 1 < len(lines) and lines[b+1].strip() and not is_start(lines[b+1]):
        b += 1
    return a, b

def sentence(lines, i, col):
    a, b = para_bounds(lines, i)
    text, off = "", 0
    for j in range(a, b + 1):
        if j == i: off = len(text) + col
        text += lines[j].strip() + " "
    starts = [0] + [m.end() for m in re.finditer(r"(?<!e\.g)(?<!i\.e)(?<!vs)\.\s+(?=[A-Z`*\[(])", text)]
    s = max(x for x in starts if x <= off)
    ends = [m.end() for m in re.finditer(r"\.\s+(?=[A-Z`*\[(])|\.\s*$", text) if m.end() > off]
    e = min(ends) if ends else len(text)
    return re.sub(r"\s+", " ", text[s:e]).strip().replace("\t", " ")

def anchor_cite(slug):
    m = re.match(r"(\d)(\d)?-", slug)
    return "§" + m.group(1) + ("." + m.group(2) if m.group(2) else "")

rows = []
for f in files:
    lines = show(f).split("\n")
    entry, field = "", ""
    indef = False
    for i, l in enumerate(lines):
        n = i + 1
        if l.startswith("<!-- citation link definitions"):
            indef = True
        if indef:
            continue
        if f == "decisions.md":
            m = re.match(r"^### (D-\d{3})", l)
            if m: entry, field = m.group(1), "heading"
            m2 = FIELD.match(l)
            if m2: field = m2.group(1)
            if l.startswith("Annotation"): field = "Annotation"
            elif field == "Annotation" and l.strip() == "": field = "Rationale"
        if f == "spec.md" and (139 <= n <= 671 or 5 <= n <= 117):
            continue
        hits = [(m.start(), m.group(0)) for m in PAT.finditer(l)] + \
               [(m.start(), anchor_cite(m.group(1))) for m in ANCH.finditer(l)]
        for col, cited in hits:
            e, fl = "", ""
            if f == "decisions.md":
                if n < 349:
                    mm = re.search(r"\[(D-\d{3})\]", l); e, fl = (mm.group(1) if mm else ""), "index"
                else:
                    e, fl = entry, field
            rows.append((f, n, cited, e, fl, sentence(lines, i, col)))
with open(R + "/docs/spec_rewrite/ch01-04/scratch_survey/inbound_raw.tsv", "w") as out:
    out.write("file\tline\tcited\tentry\tfield\tsentence\n")
    for r in rows:
        out.write("\t".join(str(x) for x in r) + "\n")
print(len(rows))
