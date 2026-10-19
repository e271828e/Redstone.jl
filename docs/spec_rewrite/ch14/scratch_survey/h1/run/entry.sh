#!/bin/zsh
# print decision entries by number with line numbers
f=${0:a:h}/../decisions.md
for n in "$@"; do
  awk -v n="### D-$n " 'index($0,n)==1{p=1; print NR": "$0; next} p && /^### D-[0-9]+ /{p=0} p && /^## /{p=0} p && /^<!--/{p=0} p{print NR": "$0}' $f
done
