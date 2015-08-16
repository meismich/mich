#!/bin/ksh

for i in $(< primary.txt ); do

	echo -n "#---->  @$i  ("
	j=$( grep -c "@$i" primaryemailaddresses2.csv )
	echo "$j)  <----#"
	grep "@$i" primaryemailaddresses2.csv

done
