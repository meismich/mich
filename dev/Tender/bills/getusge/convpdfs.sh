#!/bin/bash

for i in $( ls ../data/000/*pdf ); do 
	#echo $i
	j=$( echo $i | sed 's/^.*\/\([^\/]*\).pdf/\1/' )
	echo $j
	pdftotext -f 3 -l 3 -layout $i ./out/$j.txt
done

for i in $( ls ./out/*txt ); do
	echo $i
	vim -s getusge.vim $i
done

cat ./out/*txt > all_usage.csv

