#!/bin/zsh
# print log entry D-$1 with line numbers
f=${0:A:h}/decisions.md
s=$(rg -n "^### D-$1\b" $f | cut -d: -f1)
e=$(awk -v s=$s 'NR>s && /^### D-|^## /{print NR-1; exit}' $f)
sed -n "${s},${e}p" $f | nl -ba -v $s
