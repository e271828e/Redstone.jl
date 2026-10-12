#!/bin/zsh
# usage: kw.sh 'regex' -> entry ids (with log lines) whose text matches, at b08afca
git -C ${0:A:h} show b08afca:docs/design/decisions.md | awk -v re="$1" '/^### D-[0-9]+ — /{id=$2} /^<!-- citation link definitions/{id=""} id!="" && $0 ~ re {print id": "NR}' | awk -F': ' '{a[$1]=a[$1]" "$2} END{for(k in a) print k":"a[k]}' | sort
