#!/bin/sh
# usage: entry.sh NNN  -> prints D-NNN from parent decisions with line numbers
f=$(dirname "$0")/parent_decisions.md
awk -v id="### D-$1 " 'index($0,id)==1{p=1; print NR": "$0; next} p&&/^### D-|^<!-- citation/{exit} p{print NR": "$0}' "$f"
