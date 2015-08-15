#!/usr/bin/bash


for i in $(< ftp.in ); do
	j=$( echo $i | sed 's/^\([^,]*\),.*$/\1/' )
	k=$( echo $i | sed 's/^[^,]*,\([^,]*\),.*$/\1/' )
	l=$( echo $i | sed 's/^.*,\([^,]*\)$/\1/' )

	echo $i
	echo "J = $j"
	echo "K = $k"
	echo "L = $l"

done
