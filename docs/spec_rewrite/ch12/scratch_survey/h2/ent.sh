#!/bin/zsh
# print entry D-nnn with log line numbers
f=${0:a:h}/decisions.md
for id in "$@"; do
awk -v id="### $id" 'index($0,id)==1 && (length($0)==length(id) || substr($0,length(id)+1,1) ~ /[ :.—-]/){f=1; print NR": "$0; next} f && /^### D-/{f=0} f && /^## /{f=0} f{print NR": "$0}' $f
done
