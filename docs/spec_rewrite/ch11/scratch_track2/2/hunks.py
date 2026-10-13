import re, subprocess
d = subprocess.run(["git", "diff", "-U0", "407a222~1", "407a222", "--", "docs/design/spec.md"],
                   capture_output=True, text=True).stdout
hunks, cur = [], None
for l in d.split("\n"):
    m = re.match(r"@@ -(\d+)(?:,\d+)? \+(\d+)", l)
    if m: cur = [int(m.group(1)), int(m.group(2)), [], []]; hunks.append(cur); continue
    if cur is None or l.startswith(("---", "+++")): continue
    if l.startswith("-"): cur[2].append(l[1:])
    elif l.startswith("+"): cur[3].append(l[1:])
SEC = [(6796, "§11.1"), (6894, "§11.2"), (7130, "§11.3"), (7378, "§11.4"), (7646, "§11.5"),
       (7794, "§11.6"), (8188, "§11.7"), (8381, "§11.8")]
out, n = [], 0
for old, new, o, nw in hunks:
    if not o:  # link definitions linkify added
        continue
    n += 1
    sec = [s for a, s in SEC if a <= old][-1]
    added = sorted(set(re.findall(r"\[(D-\d{3})\]", "\n".join(nw))) - set(re.findall(r"\[(D-\d{3})\]", "\n".join(o))))
    out.append(f"### 3.{n}. {sec}, old line {old}: {', '.join(added)}\n")
    out.append("Old:\n\n````text\n" + "\n".join(o) + "\n````\n")
    out.append("New:\n\n````text\n" + "\n".join(nw) + "\n````\n")
open("docs/spec_rewrite/ch11/scratch_track2/2/log_part3.md", "w").write("\n".join(out))
print(n, "hunks")
