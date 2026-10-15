#!/bin/bash
# usage: ctx.sh FROM TO  -> prints context for rows FROM..TO (row numbers excluding header), skipping Spec-field rows
R=/Users/miguel/.julia/dev/Redstone.jl
D=$R/docs/spec_rewrite/ch12
awk -F'\t' -v a=$1 -v b=$2 'NR>1 && NR-1>=a && NR-1<=b {print NR-1"\t"$1"\t"$2"\t"$3"\t"$5}' $D/scratch_step5/inbound1/rows.tsv | while IFS=$'\t' read n f l c fld; do
  [ "$fld" = "Spec" ] && continue
  case $f in
    spec.md|decisions.md) p=$D/scratch_survey/h1/$f;;
    implementation.md) p=$R/docs/design/implementation.md;;
    *) p=$R/docs/design/$f;;
  esac
  echo "=== $n $f:$l $c $fld"
  s=$((l-3)); [ $s -lt 1 ] && s=1
  sed -n "${s},$((l+3))p" $p
done
