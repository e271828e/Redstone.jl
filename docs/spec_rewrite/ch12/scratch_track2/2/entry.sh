#!/bin/sh
# print decisions.md entry D-$1 with line numbers
f=/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md
awk -v id="### D-$1 " 'index($0,id)==1{p=1} p&&/^### D-/&&index($0,id)!=1{p=0} p{print NR": "$0}' $f
