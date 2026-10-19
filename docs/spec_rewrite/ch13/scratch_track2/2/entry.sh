#!/bin/sh
# Print log entries by id, with line numbers: entry.sh 030 058 ...
f=/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md
for id in "$@"; do
  awk -v id="### D-$id " 'index($0,id)==1{p=1} p&&/^### D-/&&index($0,id)!=1{p=0} p&&/^<!-- citation link/{p=0} p{printf "%d\t%s\n", NR, $0}' "$f"
done
