#!/bin/zsh
# print log entries by number, with log line numbers
D=${0:a:h}/decisions.md
for n in "$@"; do
  awk -v n="D-$n" 'BEGIN{p=0} /^### D-[0-9]+/{ if (index($0,"### " n " ")==1) p=1; else p=0 } /^## /{p=0} p{print NR": "$0}' $D
  echo
done
