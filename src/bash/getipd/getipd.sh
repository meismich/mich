#!/bin/bash
#
# FILE:		getipd.sh
# DATE:		2010-08-20
# AUTHOR:	Michael Spence
#
# PURPOSE:
# Get Assets Per Dealership
#

mysql -umspence -ppassword < sql/get_counts.mysql > out/counts.tab

mysql -umspence -ppassword < sql/get_assets.mysql | sed 's/\// /g' > out/assets.tab

sed 's/^\([^\t]*\)\t.*$/\1/' out/assets.tab | sed 's/ /_/g' | uniq > out/locs.txt

for i in `cat out/locs.txt`; do
	j=`echo $i | sed 's/_/ /g'`
	grep "$j" out/assets.tab > out/loc_$i.tab
done 

#mailx -s "Asset Counts and List" \
#	-r asset.list@ittools.apeagers.com.au \
#	-a out/counts.tab \
#	-a out/assets.tab \
#	mspence@apeagers.com.au < etc/mail.body

scp out/* mspence@10.32.100.71:~/incoming/ipds/.

