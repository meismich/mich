#!/bin/bash

for (( i = 1; $i < 10; i = $i + 1 )); do
	for (( j = 1; $j < 10; j = $j + 1 )); do
		for (( k = 1; $k < 149; k = $k + 1 )); do
			l="10.$i.$j.$k"
			m=$( nslookup $l | grep -v "can't" | grep "name =" | sed 's/^.*name =//' )
			echo "$l = $m"
		done
	done
done
