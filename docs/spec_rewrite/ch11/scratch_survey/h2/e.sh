#!/bin/zsh
# print log entries by number, with log line numbers
for n in "$@"; do
awk -v id="### D-$n " 'index($0,id)==1{p=1} p&&/^### D-/&&index($0,id)!=1{p=0} p&&/^## /{p=0} p{print NR": "$0}' decisions.md
echo
done
