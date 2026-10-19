#!/bin/sh
# usage: entry.sh file D-nnn
awk -v id="$2" 'BEGIN{p=0} /^### D-[0-9]+ — /{p=($2==id)} /^<!-- citation link/{p=0} p' "$1"
