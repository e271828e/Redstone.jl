#!/bin/sh
# usage: c_entry.sh file NNN
awk -v id="### D-$2 —" 'index($0,id)==1{p=1;print;next} p&&/^### D-[0-9]+ —/{exit} p&&/^<!-- citation link/{exit} p{print}' "$1"
