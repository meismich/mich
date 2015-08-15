#!/bin/bash

cat c.out | sed 's/ /_/g' > c.tmp

echo "Compiled Data" > d.out

j=""

for i in `cat c.tmp`; do
	echo $i
	if [[ "$i" == '#ENDRECORD' ]]; then
		echo $j >> d.out
		j=""
	else
		j="$j,$i"
	fi
done

echo $j >> d.out

sed 's/_/ /g' d.out > d.final
