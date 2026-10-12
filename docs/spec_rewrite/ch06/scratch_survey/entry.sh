#!/bin/zsh
# usage: entry.sh D-nnn  -> writes scratch_survey/entries/D-nnn.md with log line numbers
LOG=/Users/miguel/.julia/dev/Redstone.jl/docs/design/decisions.md
OUT=/Users/miguel/.julia/dev/Redstone.jl/docs/spec_rewrite/ch06/scratch_survey/entries
for id in "$@"; do
  awk -v id="$id" 'BEGIN{p=0} /^### D-[0-9]+/{p=($2==id)} /^<!-- citation link definitions/{p=0} p{printf "%d\t%s\n", NR, $0}' $LOG > $OUT/$id.md
done
