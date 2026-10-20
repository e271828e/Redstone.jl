"""Changed lines over 80 rendered columns in FILE's working diff (link definitions skipped)."""
import subprocess, re, sys
sys.path.insert(0, "/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch14/scratch_track2/2")
from cols import rendered, width
f = sys.argv[1]
d = subprocess.run(["git","diff","-U0",f],capture_output=True,text=True,cwd="/Users/miguel/.julia/dev/Redstone.jl").stdout
ln = 0
for l in d.split("\n"):
    m = re.match(r"@@ -\S+ \+(\d+)", l)
    if m: ln = int(m.group(1)); continue
    if l.startswith("+") and not l.startswith("+++"):
        if not re.match(r"\+(\[d-\d+\]:|\| |###)", l) and width(rendered(l[1:])) > 80: print(ln)
        ln += 1
