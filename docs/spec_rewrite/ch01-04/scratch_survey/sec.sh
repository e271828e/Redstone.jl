#!/bin/zsh
# sec.sh LINE... — print the section heading each spec line sits in
for n in "$@"; do awk -F'\t' -v n=$n '$1<=n{h=$2} END{print n": "substr(h,1,70)}' ${0:A:h}/headings.tsv; done
