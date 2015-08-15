#!/bin/bash

XTRA_DIR=/home/mspence/src/acln/etc
TEMP_DIR=/home/mspence/src/acln/tmp
DATA_DIR=/home/mspence/src/acln/out

echo "1. Exporting List of Active Assets w/ Invalid Interog8 and their locations"
mysql -umspence -ppassword < $XTRA_DIR/act_noi8_loc.mysql | sed 's/\t/,/g' > $TEMP_DIR/act_noi8_loc.txt

echo "2. Finding Unique Locations"
tail +2 $TEMP_DIR/act_noi8_loc.txt |
		sed 's/^.*,\([^,]*\)$/\1/' |
		sort | uniq | sed 's/ /###/g' > $TEMP_DIR/locations.txt

echo "3. Listing Assets per Location"
d=$( date '+%Y-%m-%d' )
for i in $(< $TEMP_DIR/locations.txt ); do

	j=$( echo $i | sed 's/###/ /g' | sed 's/\//\\\//g' )
	k=$( echo $i | sed 's/###/_/g' | sed 's/\//-/g' )
	grep ",${j}$" $TEMP_DIR/act_noi8_loc.txt | sed "s/,${j}$//" > $DATA_DIR/${k}.txt

#	cat $XTRA_DIR/mail_body.txt | 
#		sed "s/###LOC###/${j}/" | 
#		sed "s/###DAT###/${d}/" | 
#		mailx -s "Assets to Clean Report - ${j}" \
#			-r assets.to.clean@ittools.apeagers.com.au \
#			-a $DATA_DIR/${k}.txt \
#			mspence@apeagers.com.au

done
