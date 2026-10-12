#!/bin/zsh
# usage: entry.sh 001 [save]  — print D-nnn with log line numbers (frozen base)
D=${0:A:h}/decisions.md
for n in "$@"; do
  [[ $n == save ]] && continue
  awk -v id="### D-$n " 'index($0,id)==1{p=1} p && /^### D-/ && index($0,id)!=1{exit} p && /^<!-- citation link/{exit} p{printf "%d\t%s\n", NR, $0}' $D > ${0:A:h}/entries/D-$n.md
  cat ${0:A:h}/entries/D-$n.md
done
