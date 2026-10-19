#!/bin/zsh
# for a pattern, list the entries whose text matches, with matching log lines
D=${0:a:h}/decisions.md
awk -v pat="$1" '/^### D-[0-9]+/{id=substr($2,1)} $0 ~ pat {print id": "NR}' $D | awk -F': ' '{a[$1]=a[$1]" "$2} END{for(k in a) print k":"a[k]}' | sort
