#!/bin/zsh
awk -v a=$2 -v b=$3 'NR>=a && NR<=b {print NR": "$0}' $1
