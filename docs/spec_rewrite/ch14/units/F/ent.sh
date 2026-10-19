#!/bin/zsh
# print entries in full: ent.sh 069 070 ...
F=${0:A:h}/../../scratch_survey/h1/decisions.md
for n in "$@"; do
  s=$(rg -n "^### D-$n " $F | cut -d: -f1)
  e=$(awk -v s=$s 'NR>s && /^(### |## |<!-- citation)/{print NR-1; exit}' $F)
  echo "=== D-$n ($s-$e)"; sed -n "${s},${e}p" $F
done
