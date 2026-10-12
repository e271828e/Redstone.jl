#!/bin/zsh
# Print a decision entry with its log line numbers at the frozen base b08afca.
# usage: entry.sh 252 [save]   (save writes entries/D-252.md)
D=${0:A:h}
n=$(printf "%03d" $1)
out=$(git -C $D show b08afca:docs/design/decisions.md | awk -v id="D-$n" '
  /^### D-[0-9]+ — / { inside = (index($0, "### " id " ") == 1) }
  /^<!-- citation link definitions/ { inside = 0 }
  /^## / { inside = 0 }
  inside { printf "%d\t%s\n", NR, $0 }')
if [[ "$2" == save ]]; then mkdir -p $D/entries; print -r -- "$out" > $D/entries/D-$n.md; fi
print -r -- "$out"
