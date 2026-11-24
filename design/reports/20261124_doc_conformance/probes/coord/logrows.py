# usage: logrows.py <group> [id=entries ...]: append the group's log-slice rows and the named backed rows to log_findings.tsv.
import csv, sys
R = "/Users/miguel/.julia/dev/Redstone.jl/design/reports/20261124_doc_conformance/ledgers"
g = sys.argv[1]; extra = [a.split('=', 1) for a in sys.argv[2:]]
n = 0
with open(f"{R}/log_findings.tsv", "a") as f:
    w = csv.writer(f, delimiter='\t', lineterminator='\n')
    for r in csv.DictReader(open(f"{R}/{g}/findings.tsv"), delimiter='\t'):
        if r['id'].startswith('L'):
            w.writerow([r['id'], r['at'], r['kind'], r['class'], r['claim'], r['fix'], r['ver_evidence'], r['ver_note'], f"log slice ({r['source']})"]); n += 1
    for i, e in extra: w.writerow([i, e]); n += 1
print(g, n, "rows")
