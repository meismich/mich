#!/bin/bash

mysql -umspence -ppassword < arev.mysql | sed 's/\t/,/' > arev.1st

sed 's/^\([^,]*\),.*$/\1/' asset_review_2012.csv > arev.2nd

for i in $(< arev.2nd ); do
	j=$(grep $i arev.1st)
	k=$(grep $i asset_review_2012.csv )
	echo $j,$k
done > arev.out

