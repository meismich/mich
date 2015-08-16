#!/bin/bash

n=$( grep -c "^" dump.csv )

s="Name"
for j in $(< inusedomains.txt ); do
	s="$s,$j"
done

echo $s > z.out

for (( i=1; $i < $n; i++ )); do
#i=1
	k=$(( $i + 1 ))
	a=$( sed -n ${k}p dump.csv )
	b=$( echo $a | sed 's/^\([^,]*\),.*$/\1/' )
	s="$b"
	for j in $(< inusedomains.txt ); do

		c=$( echo $a | grep "@$j" )

		if [ "x$c" == "x" ]; then
			s="$s,0"
		else
			s="$s,1"
		fi

	done

	echo $s >> z.out
done
