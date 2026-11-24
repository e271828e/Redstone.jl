"""Merge one audit workflow run's journal into ledgers.

usage: python3 merge_run.py <journal.jsonl> <out_dir>

Reads each agent's return value from the journal (labels inv:<key>, inv2:<key>
for a density re-run, ver:<key>), keeps the later inventory when a slice was
re-run, and re-derives what the workflow derived: the rows a verifier confirmed
or overturned, and the sampled ok rows it found false. Writes the raw returns,
findings.tsv, overturned.tsv and measurements.tsv to <out_dir>, and prints the
measurements.
"""
import csv, json, os, sys

journal, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
labels, raw = {}, {}
for line in open(journal):
    d = json.loads(line)
    if d["type"] == "started":
        labels[d["agentId"]] = d["label"]
    elif d["type"] == "result" and d["agentId"] in labels:
        raw[labels[d["agentId"]]] = d["result"]
for lab, r in raw.items():
    json.dump(r, open(f"{out}/{lab.replace(':', '_')}.json", "w"), ensure_ascii=False, indent=1)

keys = sorted({lab.split(":", 1)[1] for lab in raw})
meas, finds, overs = [], [], []
for k in keys:
    inv = raw.get(f"inv2:{k}") or raw.get(f"inv:{k}")
    ver = raw.get(f"ver:{k}")
    if not inv:
        continue
    judged = {j["id"]: j for j in (ver or {}).get("judgments", [])}
    rows = {r["id"]: r for r in inv["rows"]}
    oks = {r["id"]: r for r in inv["ok"]}
    conf = over = miss = sampled = 0
    for i, j in judged.items():
        if i in rows:
            r = rows[i]
            if j["conforms"]:
                over += 1
                overs.append([i, f"{r['file']}:{r['line']}", r["verdict"], r["claim"], j["evidence"] + (" | " + j["note"] if j.get("note") else "")])
                continue
            conf += 1
            src = "flagged"
        elif i in oks:
            sampled += 1
            r = oks[i]
            if j["conforms"]:
                continue
            miss += 1
            src = "missed"
        else:
            continue
        finds.append([i, src, f"{r['file']}:{r['line']}", r["kind"], j.get("class", ""), j.get("clear", ""),
                      j.get("backing_entry", ""), r["claim"], j.get("fix", ""), j["evidence"], j.get("note", "")])
    counted = sum(v for v in inv["counts"].values() if isinstance(v, int))
    meas.append([k, counted, len(inv["rows"]) + len(inv["ok"]), len(inv["rows"]), len(inv["ok"]), sampled,
                 conf, over, miss, "inv2" if f"inv2:{k}" in raw else "", len(inv["rows"]) - conf - over])

def write(name, head, rows):
    with open(f"{out}/{name}", "w") as f:
        w = csv.writer(f, delimiter="\t")
        w.writerow(head)
        w.writerows(rows)

write("findings.tsv", ["id", "source", "at", "kind", "class", "clear", "backing", "claim", "fix", "ver_evidence", "ver_note"], finds)
write("overturned.tsv", ["id", "at", "inv_verdict", "claim", "why"], overs)
mh = ["slice", "counted", "listed", "flagged", "ok", "sampled", "confirmed", "overturned", "missed", "rerun", "unjudged"]
write("measurements.tsv", mh, meas)
print("\t".join(mh))
for m in meas:
    print("\t".join(map(str, m)))
print(f"findings {len(finds)}, overturned {len(overs)}")
