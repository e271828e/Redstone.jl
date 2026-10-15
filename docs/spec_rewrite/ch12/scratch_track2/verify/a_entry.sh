#!/bin/sh
# print entry D-$1 from parent decisions
awk -v id="### D-$1 " 'index($0,id)==1{p=1;print NR": "$0;next} /^### D-/{p=0} p' /Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch12/scratch_track2/verify/a_parent_dec.md
