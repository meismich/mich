#!/bin/ksh

head -1 z.csv > bbusers.out

for i in $( sed 's/ /_/' < bbusers.txt  ); do
	#echo $i
	j=$( echo $i | sed 's/_/ /g' )
	echo -n "(${j}),"
	grep "$j" z.csv
done >> bbusers.out
