#!/bin/ksh

in_file="sfsites.txt"
lu_file="sfcats.txt"

rm out/*

for i in $(< $in_file ); do
	j=$( echo $i | sed "s/^\(.*\),.*/\1/" )
	k=$( echo $i | sed "s/^.*,\(.*\)$/\1/" )
	l=$( grep "^$k" $lu_file | sed "s/^.*,\(.*\)\r$/\1/" )
	echo $j >> out/${l}.txt
	echo "$l,$j"
done | grep -v "^," | sort > out.txt
