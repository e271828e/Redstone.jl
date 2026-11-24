# usage: triage.py <journal> <group>...: merge each run and print its findings compactly.
import csv, subprocess, sys
R = "/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance"
j, g = sys.argv[1], sys.argv[2]
out = subprocess.run(["python3", f"{R}/probes/merge_run.py", j, f"{R}/ledgers/{g}"], capture_output=True, text=True).stdout
print(out)
for r in csv.DictReader(open(f"{R}/ledgers/{g}/findings.tsv"), delimiter='\t'):
    print(f"{r['id']} {r['source'][:4]} {r['at'].replace('design/','')} {r['kind']} {r['class']} c={r['clear'][:1]} b={r['backing'][:20]}\n  {r['claim'][:150]}\n  FIX: {r['fix'][:150]}")
