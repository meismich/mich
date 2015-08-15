#!/bin/bash
#
# FILE:		arev.sh
# DATE:		2013-01-04
# AUTHOR:	Michael Spence
#
# VERSION:	1.0
#
# PURPOSE:
#	To make note in the asset database of the most recent time a computer was seen by INTEROG8
#
# NOTES:
# 	Interog8 is a GPO for APEAGERS which at user logon writes a file containing the serial 
#	number and other details for a computer to \\bne-issadm\tmp\drives.
#	This is mapped to /issadm/drives on this machine.

echo "AREV: Asset Review via Interog8"
echo "==============================="

ING8_DIR=/issadm/drives
WORK_DIR=/home/mspence/src/arev/out
TEMP_DIR=/home/mspence/src/arev/tmp

echo "0: Creating list of valid Interog8 files"
head -1 $ING8_DIR/*INTEROG8.csv | grep -v "^$" | sed 'N;s/\n/###/' | grep "Interog8,v2.1" | sed 's/^==> \(.*\) <==.*$/\1/' > $TEMP_DIR/i8s.txt

echo "1: Creating list of unique serial numbers"
for i in $(< $TEMP_DIR/i8s.txt ); do
	grep "^SNO" $i | sed 's/^SNO,//' 
done | fromdos > $TEMP_DIR/snos.raw

sed 's/^.*,\([^,]*\)$/\1/' $TEMP_DIR/snos.raw | sort | uniq > $TEMP_DIR/snos.uniq

for i in $(< $TEMP_DIR/snos.uniq ); do
	grep ",$i" $TEMP_DIR/snos.raw | sort | tail -1
done > $TEMP_DIR/snos.final

sed 's/^.*,\([^,]*\)$/\1/' $TEMP_DIR/snos.final | sed 's/ /###/g' > $TEMP_DIR/snos.only

echo "2: Correlating Serial numbers with Asset IDs"
echo "use assets;" > $TEMP_DIR/asset.select
echo -n "select id, s_serialno from assets where s_serialno in (" >> $TEMP_DIR/asset.select

for i in $(< $TEMP_DIR/snos.only ); do
	echo -n "'$i'," | sed 's/###/ /g'
done >> $TEMP_DIR/asset.select

echo "'bork');" >> $TEMP_DIR/asset.select

mysql -umspence -ppassword < $TEMP_DIR/asset.select | sed 's/\t/,/g' | sed 's/ /###/' | tail +2 > $TEMP_DIR/assets.txt

echo "3: Finding Pre-existing Ingerog8 entries"
echo "use assets;" > $TEMP_DIR/descs.search
echo -n "select i_asset from descriptions where i_desctype = 13 and i_asset in (" >> $TEMP_DIR/descs.search

for i in $(< $TEMP_DIR/assets.txt ); do
	a=$( echo $i | sed 's/^\([^,]*\),.*$/\1/' )
	echo -n "$a,"
done >> $TEMP_DIR/descs.search
echo "9999999999999);" >> $TEMP_DIR/descs.search

mysql -umspence -ppassword < $TEMP_DIR/descs.search > $TEMP_DIR/update.list

sed 's/^\([^,]*\),.*$/\1/' $TEMP_DIR/assets.txt > $TEMP_DIR/assets.uniq

grep -xvF -f $TEMP_DIR/update.list $TEMP_DIR/assets.uniq > $TEMP_DIR/insert.list

echo "4: Updating Existing entries"
echo "use assets;" > $TEMP_DIR/descs.update

for i in $( cat $TEMP_DIR/update.list ); do
	s=$( grep $i $TEMP_DIR/assets.txt | sed 's/^.*,\([^,]*\)$/\1/' | sed 's/###/ /' )
	d=$( grep -i "$s" $TEMP_DIR/snos.final | sed 's/^\([^,]*\),.*$/\1/' | sed 's/^\(....\)\(..\)\(..\).*$/\1-\2-\3/' )
	if [[ "x$i" != "x" && "x$d" != "x" ]]; then
		echo "update descriptions set s_description = '$d' where i_asset = $i and i_desctype = 13;"
	fi
done >> $TEMP_DIR/descs.update

mysql -umspence -ppassword < $TEMP_DIR/descs.update

echo "4: Inserting New entries"
echo "use assets;" > $TEMP_DIR/descs.insert

for i in $(< $TEMP_DIR/insert.list ); do
	s=$( grep $i $TEMP_DIR/assets.txt | sed 's/^.*,\([^,]*\)$/\1/' | sed 's/###/ /' )
	d=$( grep -i "$s" $TEMP_DIR/snos.final | sed 's/^\([^,]*\),.*$/\1/' | sed 's/^\(....\)\(..\)\(..\).*$/\1-\2-\3/' )
	if [[ "x$i" != "x" && "x$d" != "x" ]]; then
		echo "insert into descriptions set s_description = '$d', i_asset = $i, i_desctype = 13;"
	fi
done >> $TEMP_DIR/descs.insert

mysql -umspence -ppassword < $TEMP_DIR/descs.insert

echo "5: Done!"

echo "==============================================="
echo "[REPORT]"

echo -n "Total Unique Machines Interog8d: "
ls $ING8_DIR | sed 's/^\(.....[^-]*\)-.*$/\1/' | sort | uniq | grep -c "^"
echo -n "Total Unique Serial#s Interog8d: "
grep -c "^" $TEMP_DIR/snos.uniq
echo "--------------------------------------------------"
echo -n "Number of Updates: "
grep -c "^" $TEMP_DIR/update.list
echo -n "Number of Inserts: "
grep -c "^" $TEMP_DIR/insert.list

