#!/bin/bash

INTR_DIR=/issadm/drives
XTRA_DIR=/home/mspence/src/wver/etc
WORK_DIR=/home/mspence/src/wver/out
TEMP_DIR=/home/mspence/src/wver/tmp

echo "1. Collating Raw integro8 Win Version data"
# Get all the Machine names and their OS versions from i8 raw data
for i in "done" "error" "null" "vmware"; do
	grep "WIN" $INTR_DIR/$i/*csv | sed 's/^[^:]*://' | sed 's/^WIN,[^,]*,//' | sed 's/,[^,]*$//'
done | sort | 
	uniq > $TEMP_DIR/i8_data.tmp

echo "2. Finding Active Windows devices from ittools"
# Get the list of machiness from SQL
mysql -umspence -ppassword < $XTRA_DIR/act_i8names.mysql | sed 's/\t/,/g' | sed 's/ /###/g' | tail +2 > $TEMP_DIR/i8_name.tmp

echo "3. Correlating ..."
# Correlate by machine name the version of assets
for i in $(< $TEMP_DIR/i8_name.tmp ); do
	j=$( echo $i | sed 's/.*,\([^,]*\)$/\1/' )
	k=$( grep $j $TEMP_DIR/i8_data.tmp | grep -c "^" )
	if [ $k -gt 0 ]; then
		l=$( grep $j $TEMP_DIR/i8_data.tmp | head -1 | sed 's/^[^,]*,//' )
	else
		l="(No Version Info)"
	fi
	echo "$i,$l"
done | sed 's/###/ /g' > $WORK_DIR/asset_winver.csv



