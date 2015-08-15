#!/usr/bin/bash

function testip () {
	echo " ---> $1"
	ping $1 &
	sleep 2
	#read -s -n 1
	j=`jobs | sed 's/^\[\([^]]*\)\].*$/\1/'`
	echo "[$j]"
	kill %$j 2> /dev/null
	}

i=0

for (( i = 0; $i < 256; i++ )); do

	echo -n $1.$i

	testip "$1.$i"
done
