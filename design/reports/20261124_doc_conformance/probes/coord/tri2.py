# usage: tri2.py <journal> <group>: merge, then one line per non-log finding and a count of log rows.
import csv, subprocess, sys
R = "/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance"
j, g = sys.argv[1], sys.argv[2]
out = subprocess.run(["python3", f"{R}/probes/merge_run.py", j, f"{R}/ledgers/{g}"], capture_output=True, text=True).stdout
print("\n".join(l for l in out.split("\n") if l and not l.startswith("slice")))
nl = 0
for r in csv.DictReader(open(f"{R}/ledgers/{g}/findings.tsv"), delimiter='\t'):
    if r['id'].startswith('L'): nl += 1; continue
    print(f"{r['id']} {r['class'][:5]} {r['clear'][:1]} {r['backing'][:6]:6} | {r['claim'][:105]}")
print("log rows:", nl)
