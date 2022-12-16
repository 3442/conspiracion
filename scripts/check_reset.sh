#!/bin/sh

git grep -Po '(?<!\.)\b\w+\b(?= <=)' rtl | tr ':' ' ' | while read X; do
	A=$(echo "$X" | awk '{ print $1; }')
	B=$(echo "$X" | awk '{ print $2; }')
	RST="$(grep 'if(!rst_n)' $A)"
	OK=

	if echo "$RST" | grep -q begin; then
		N=1
		while true; do
			R="$(grep -A$N "$RST" "$A")";
			if echo "$R" | grep -q '\<end\>'; then
				break
			elif echo "$R" | grep -q "$B"; then
				OK=1
				break
			fi

			N=$((N+1))
		done
	else
		(grep -A1 "$RST" "$A" | grep -q "$B") && OK=1
	fi

	[ -z "$OK" ] && echo "$A: $B"
done
