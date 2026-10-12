#!/bin/bash
# print entry D-$1 from decisions.md
f=/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch06/scratch_inbound/decisions.md
s=$(rg -n "^### D-$1\b" $f | head -1 | cut -d: -f1)
e=$(awk -v s=$s 'NR>s && /^### D-/{print NR; exit}' $f)
sed -n "${s},$((e-1))p" $f
