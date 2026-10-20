"""Agent 1, step 3: annotations and Spec fields in decisions.md.
Every edit is matched by old text that must occur exactly once; all are
asserted before the file is written. Writes the edit log too.
usage: apply.py [--write]"""
import re, sys, textwrap

LOG = "/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md"
OUT = "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/track2_log_1.md"
DATE = "2026-10-20"
LINK = re.compile(r"\[([^\]]+)\]\[[^\]]+\]")
src = open(LOG).read()
lines = src.split("\n")

def rendered(s):
    return len(LINK.sub(r"\1", s).replace("**", ""))

def wrap(words, width=80):
    out, cur = [], ""
    for w in words:
        t = w if not cur else cur + " " + w
        if cur and rendered(t) > width:
            out.append(cur); cur = w
        else:
            cur = t
    out.append(cur)
    return "\n".join(out)

def unique_block(end_idx, lo=1):
    """Smallest block of lines ending at end_idx (0-based) that occurs once."""
    for k in range(lo, 40):
        blk = "\n".join(lines[end_idx - k + 1:end_idx + 1])
        if src.count(blk) == 1:
            return blk
    raise SystemExit("no unique block ending at line %d" % (end_idx + 1))

def entry_range(d):
    s = next(i for i, l in enumerate(lines) if l.startswith("### %s — " % d))
    e = next(i for i in range(s + 1, len(lines)) if lines[i].startswith("### ") or lines[i].startswith("<!-- citation"))
    return s, e

edits = []  # (label, old, new)

# ---- annotations ----
ANN = [
 ("B33a", "D-108", "the precondition the Position gives `capture` is `checkpoint`'s since D-273 and D-274. `checkpoint(sim)` is legal in `initialized` and `stopped`, and `linearize`'s default operating point is the checkpoint of the simulation as it stands (D-274)."),
 ("B34d", "D-139", "the by-name rejection of init as a third scheduled sweep is D-064's; §14.2 never stated it."),
 ("B36a", "D-065", "the earlier annotation's machine-checked concrete half predates D-414. `:past_generic` retired from `PathResolution`, so a deep path resolves wherever the structure has it, and the locality law for shipped fragments and problems is authoring guidance, not a framework check (D-414)."),
 ("B41a", "D-095", "the family §14.4 states has five members, `get_state`, `get_deriv`, `get_output`, `get_input` and `get_face`. `get_local` retired from it with `local_types` (D-165), and `get_slot` is spelled `get_input` since D-206."),
 ("B42", "D-098", "`capture` reads `checkpoint` here. A checkpoint is a distinct value with no condition algebra (D-273, D-274). Of the holders of live stores, only the services' readers take a store selector (§14.4). No client policy applies on top of the source rule, which is the resolver's, not a client's (D-406)."),
 ("B43", "D-063", "the warm-restart clause is retired. The cycle capture → tweak → apply retires with `capture`'s condition form, and a resume is a checkpoint and a restore (D-273). The overlay clauses stand."),
 ("B47", "D-409", "the service half bears on the reads a run acts on, as §13.5 frames the rejection. Since D-414 the locality law is authoring guidance, not a framework check, and `get_face` remains the read for a consumer meant to outlive the build."),
 ("B50a", "D-149", "the list lags the governing principle. Linearization's operating condition under `about`, applied to its own fresh scratch, is a fourth such application, and §14.6 and §14.10 name it."),
 ("B51", "D-122", "only `trim!` takes the `baseline` keyword now. The clause held when written, the spec at `8e2505c` reading \"the `baseline` keyword `init!`/`trim!` take\", and `init!` lost the keyword later."),
 ("B53a", "D-118", "the field set closes at nine since D-262, which adds `checks` and `check_tolerances`."),
 ("B59b", "D-070", "the audit bullet's \"reported\" overstates the report. Its `saturated` list names a decision only at its own bound, the first bullet's saturated-at-solution flag. An in-model saturation is LM-tolerated and shows in zero Jacobian columns, not in the report (§14.8)."),
 ("B60", "D-069", "the reads are declared with the full read-selector family since D-124, which calls the two-selector alternation a pre-D-095 straggler. The selectors carry D-095's `get_` prefix."),
 ("B61a, R26", "D-071", "two bullets read stale. The build raises nothing for an internally wired face; resolution refuses it with the producer named, as D-277 states for a face fed by a component. And no source ships a `design_world`; it is the rig this design records for design-time work (§14.9)."),
 ("B62", "D-072", "the default operating point is the checkpoint of the simulation as it stands (D-274), and `capture` no longer produces a condition (D-273)."),
 ("B63a", "D-272", "the default operating point is the checkpoint of the simulation as it stands (D-274), which carries its own time. `capture` no longer produces a condition (D-273)."),
 ("B70", "D-068", "the commit is spelled `override(baseline, condition(d*))`, the problem's condition at the solution, as D-149's Rationale and the code spell it."),
]

for label, d, body in ANN:
    s, e = entry_range(d)
    text = re.sub(r"`[^`]*`", lambda m: m.group(0).replace(" ", "\x00"), "Annotation (%s): %s" % (DATE, body))
    para = wrap(text.split(" ")).replace("\x00", " ")
    rej = [i for i in range(s, e) if lines[i].startswith("**Rejected.**")]
    anns = [i for i in range(s, e) if lines[i].startswith("Annotation (")]
    if rej and not (anns and anns[-1] > rej[0]):
        i = rej[0]  # insert before **Rejected.**
        old = next(b for b in ("\n".join(lines[i:i + k]) for k in range(2, 40))
                   if src.count(b) == 1)  # grows forward from **Rejected.**
        new = para + "\n\n" + old
    else:
        i = e - 1  # after the entry's last line of text
        while not lines[i].strip():
            i -= 1
        old = unique_block(i)
        new = old + "\n\n" + para
    edits.append((label + " " + d + " annotation", old, new))

# ---- Spec fields ----
SPEC = [
 ("B36b", "D-065", ["§14.3"], []), ("B37", "D-064", ["§14.1"], []),
 ("B52", "D-253", ["§14.3"], ["§14.1"]),
 ("audit", "D-066", ["§14.4"], []), ("audit", "D-069", ["§14.8"], []),
 ("audit", "D-223", ["§14.8"], []), ("audit", "D-232", ["§14"], []),
 ("audit", "D-273", ["§14", "§14.8"], []), ("audit", "D-277", ["§14.7"], []),
 ("audit", "D-286", ["§14.10"], []), ("audit", "D-292", ["§14.5"], []),
 ("audit", "D-297", ["§14.10"], []), ("audit", "D-306", ["§14.1"], []),
 ("audit", "D-317", ["§14.8"], []), ("audit", "D-318", ["§14", "§14.8"], []),
 ("audit", "D-364", ["§14.1"], []), ("audit", "D-376", ["§14.6"], []),
 ("audit", "D-406", ["§14.8", "§14.10"], []), ("audit", "D-407", ["§14.4"], []),
 ("audit", "D-409", ["§14.1"], []), ("audit", "D-413", ["§14.5"], []),
]

def key(item):
    m = re.match(r"(?:\[)?§(\d+(?:\.\d+)?)", item)
    if not m:
        return None
    return [int(p) for p in m.group(1).split(".")]

for label, d, add, drop in SPEC:
    s, e = entry_range(d)
    i0 = next(i for i in range(s, e) if lines[i].startswith("**Spec.**"))
    i1 = i0
    while lines[i1 + 1].strip():
        i1 += 1
    field = " ".join(lines[i0:i1 + 1])[len("**Spec.** "):]
    items = [x.strip() for x in field.split(",")]
    for x in drop:
        hits = [j for j, it in enumerate(items) if LINK.sub(r"\1", it) == x]
        assert len(hits) == 1, (d, x)
        items.pop(hits[0])
    for x in add:
        assert all(LINK.sub(r"\1", it) != x for it in items), (d, x)
        k = key(x)
        pos = next((j for j, it in enumerate(items) if key(it) is None or key(it) > k), len(items))
        items.insert(pos, x)
    words = ("**Spec.** " + ", ".join(items)).split(" ")
    newfield = wrap(words)
    oldfield = "\n".join(lines[i0:i1 + 1])
    old = unique_block(i1, i1 - i0 + 1)
    if old.count(oldfield) != 1:
        raise SystemExit("field not in block " + d)
    new = old.replace(oldfield, newfield)
    edits.append((label + " " + d + " Spec field", old, new))

# ---- assert all, then apply ----
txt = src
for label, old, new in edits:
    n = txt.count(old)
    if n != 1:
        raise SystemExit("%s: old text matches %d times" % (label, n))
for label, old, new in edits:
    txt = txt.replace(old, new, 1)

if "--write" in sys.argv:
    open(LOG, "w").write(txt)
    with open(OUT, "w") as f:
        f.write("# Chapter 14, track 2 log, agent 1\n\n")
        f.write("Edits in order, each matched by its old text. Commit 1 is the glossary\n"
                "edit in `docs/design/spec.md`; the rest are in `docs/design/decisions.md`,\n"
                "applied by `scratch_track2/1/apply.py` and then linkified, so a bare\n"
                "citation below reads linked in the file.\n\n")
        f.write(open("/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_track2/1/glossary_edit.md").read())
        for n, (label, old, new) in enumerate(edits, 2):
            f.write("## %d. %s\n\nOld:\n\n```markdown\n%s\n```\n\nNew:\n\n```markdown\n%s\n```\n\n" % (n, label, old, new))
    print("written: %d edits" % len(edits))
else:
    for label, old, new in edits:
        print("=" * 70, "\n" + label)
        print(new if label.endswith("annotation") else old + "\n  ->\n" + new)
