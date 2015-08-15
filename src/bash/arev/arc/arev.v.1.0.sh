#!/bin/bash
#
# FILE:		arev.sh
# DATE:		2013-02-11
# AUTHOR:	Michael Spence
#
# VERSION:	1.3
#
# PURPOSE:
#	To make note in the asset database of the most recent time a computer was seen by INTEROG8
#
# NOTES:
# 	Interog8 is a GPO for APEAGERS which at user logon writes a file containing the serial 
#	number and other details for a computer to \\bne-issadm\tmp\drives.
#	This is mapped to /issadm/drives on this machine.

echo "==============================="
echo "AREV: Asset Review via Interog8"
echo "==============================="
echo "(Date: $(date +%Y-%m-%d:%H%M))"

ING8_DIR=/issadm/drives
WORK_DIR=/home/mspence/src/arev/out
TEMP_DIR=/home/mspence/src/arev/tmp

echo "0: Creating list of valid Interog8 files"
for i in $( ls --indicator-style=none /issadm/drives/*csv ); do
	if [ -e "$i" ]; then 
		echo -n  "$i"
		head -q  -n 1 "$i"
		echo
	fi
done 	| grep "Interog8,v2.1" \
	| sed 's/###,Interog8,v2.1.*$//' \
	> $TEMP_DIR/i8s.txt

echo "1: Creating list of unique serial numbers"
for i in $(< $TEMP_DIR/i8s.txt ); do
	grep "^SNO" "$i" | sed 's/^SNO,//' | sed 's/ /###/g'
done 	| fromdos \
	> $TEMP_DIR/snos.raw

sed 's/^.*,\([^,]*\)$/\1/' $TEMP_DIR/snos.raw \
	| sort \
	| uniq \
	> $TEMP_DIR/snos.uniq

for i in $(< $TEMP_DIR/snos.uniq ); do
	grep ",$i" $TEMP_DIR/snos.raw \
		| sort \
		| tail -1
done > $TEMP_DIR/snos.final

sed 's/^.*,\([^,]*\)$/\1/' $TEMP_DIR/snos.final \
	| sed 's/ /###/g' \
	| sed 's/^....-B/B/' \
	| grep -v "^##*$" \
	| sort \
	| uniq \
	> $TEMP_DIR/snos.only

echo "2: Correlating Serial numbers with Asset IDs"
echo "use assets;" > $TEMP_DIR/asset.select
echo -n "select id, s_serialno from assets where s_serialno in (" >> $TEMP_DIR/asset.select

for i in $(< $TEMP_DIR/snos.only ); do
	echo -n "'$i'," \
		| sed 's/###/ /g'
done >> $TEMP_DIR/asset.select

echo "'bork');" >> $TEMP_DIR/asset.select

mysql -umspence -ppassword \
	< $TEMP_DIR/asset.select \
	| sed 's/\t/,/g' \
	| sed 's/ /###/g' \
	| tail +2 \
	> $TEMP_DIR/assets.txt

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

for i in $( tail +2 $TEMP_DIR/update.list ); do
	s=$( grep $i $TEMP_DIR/assets.txt \
		| sed 's/^.*,\([^,]*\)$/\1/' \
		| sed 's/###/ /' \
		)
	d=$( grep -i "$s" $TEMP_DIR/snos.final \
		| sed 's/^\([^,]*\),.*$/\1/' \
		| sed 's/^\(....\)\(..\)\(..\).*$/\1-\2-\3/' \
		| tail -1 \
		)
	if [[ "x$i" != "x" && "x$d" != "x" ]]; then
		echo "update descriptions set s_description = '$d' where i_asset = $i and i_desctype = 13;"
	fi
done >> $TEMP_DIR/descs.update

mysql -umspence -ppassword < $TEMP_DIR/descs.update

echo "4: Inserting New entries"
echo "use assets;" > $TEMP_DIR/descs.insert

for i in $(< $TEMP_DIR/insert.list ); do
	s=$( grep $i $TEMP_DIR/assets.txt \
		| sed 's/^.*,\([^,]*\)$/\1/' \
		)
	d=$( grep -i "$s" $TEMP_DIR/snos.final \
		| sed 's/^\([^,]*\),.*$/\1/' \
		| sed 's/^\(....\)\(..\)\(..\).*$/\1-\2-\3/' \
		| tail -1 \
		)
	if [[ "x$i" != "x" && "x$d" != "x" ]]; then
		echo "insert into descriptions set s_description = '$d', i_asset = $i, i_desctype = 13;"
	fi
done >> $TEMP_DIR/descs.insert

mysql -umspence -ppassword < $TEMP_DIR/descs.insert

echo "5: Done!"

echo "==============================================="
echo "[REPORT]"

echo -n "Total Unique Machines Interog8d: "
ls $ING8_DIR \
	| sed 's/^\(.....[^-]*\)-.*$/\1/' \
	| sort \
	| uniq \
	| grep -c "^"

echo -n "Total Unique Serial#s Interog8d: "
grep -c "^" $TEMP_DIR/snos.only

echo "--------------------------------------------------"
echo -n "Number of Updates: "
grep -c "^" $TEMP_DIR/update.list
echo -n "Number of Inserts: "
grep -c "^" $TEMP_DIR/insert.list
echo "--------------------------------------------------"

sed 's/^[^,]*,\(.*\)$/\1/' $TEMP_DIR/assets.txt > $TEMP_DIR/snos.found
for i in $( grep -xvF -f $TEMP_DIR/snos.found $TEMP_DIR/snos.only ); do
	j=$( echo $i | sed 's/###/ /g' )
	echo $j
	grep ",$i" $TEMP_DIR/snos.raw | sed 's/###/ /g' | sed 's/^/>/'
done > $TEMP_DIR/snos.faulty

cat $TEMP_DIR/snos.faulty

grep "^>" $TEMP_DIR/snos.faulty | sed 's/^[^,]*,\([^,]*\),.*$/\1/' > $TEMP_DIR/i8s.bad

for i in $( grep -v -f $TEMP_DIR/i8s.bad $TEMP_DIR/i8s.txt ); do
	if [ -e "$i" ]; then
		mv "$i" $ING8_DIR/done/.
	fi
done
