#!/bin/sh
# Print decisions.md entries by number: entry.sh 012 030
f=/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md
for n in "$@"; do
  awk -v id="### D-$n " 'index($0,id)==1{p=1; print NR": "$0; next} p && /^### D-/{p=0} p && /^<!-- citation link/{p=0} p{print NR": "$0}' "$f"
  echo
done
