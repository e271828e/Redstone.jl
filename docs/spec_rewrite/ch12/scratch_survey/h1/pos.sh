#!/bin/zsh
# print D-$1 title, status, position, spec (numbered)
f=${0:A:h}/decisions.md
for id in "$@"; do
s=$(rg -n "^### D-$id\b" $f | cut -d: -f1)
e=$(awk -v s=$s 'NR>s && /^### D-|^## /{print NR-1; exit}' $f)
sed -n "${s},${e}p" $f | nl -ba -v $s | awk '/\*\*Rationale\.\*\*/{p=0} /### D-|\*\*Status|\*\*Position|\*\*Spec/{p=1} /Annotation \(/{p=2} p' | cut -c1-400
echo
done
