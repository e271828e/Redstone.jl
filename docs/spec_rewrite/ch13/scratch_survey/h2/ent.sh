#!/bin/zsh
# print decisions.md entries with log line numbers: ent.sh 012 060 ...
D=${0:a:h}/decisions.md
for n in "$@"; do
  awk -v id="### D-$n" 'BEGIN{p=0} /^### D-[0-9]+/{ if(index($0,id)==1 && (substr($0,length(id)+1,1)!~/[0-9]/)) p=1; else p=0 } /^## /{p=0} p{print NR": "$0}' $D
  echo
done
