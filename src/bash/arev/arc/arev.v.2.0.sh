#!/bin/bash
#
# FILE:		arev.sh
# DATE:		2013-02-11
# AUTHOR:	Michael Spence
#
# VERSION:	2.0
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

if [ -e $TEMP_DIR/arev.lock ]; then exit 1; fi
touch $TEMP_DIR/arev.lock

echo "0: Creating list of valid Interog8 files"
for i in $( ls -rt --indicator-style=none $ING8_DIR/*csv ); do
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

echo "3: Processing Interog8 Files"

echo "use assets;" > $TEMP_DIR/asset.mysql

if [ -e $TEMP_DIR/i8s.done ]; then rm $TEMP_DIR/i8s.done; fi
if [ -e $TEMP_DIR/i8s.null ]; then rm $TEMP_DIR/i8s.null; fi
if [ -e $TEMP_DIR/i8s.error ]; then rm $TEMP_DIR/i8s.error; fi
if [ -e $TEMP_DIR/i8s.vmware ]; then rm $TEMP_DIR/i8s.vmware; fi

for i in $(< $TEMP_DIR/i8s.txt ); do
	j=$( grep "^SNO" $i | sed "s/^.*,\([^,]*\)$/\1/" | sed "s/ /###/g" | sed "s/^....-B/B/" | fromdos )
	k=$( grep $j $TEMP_DIR/assets.txt | sed "s/,[^,]*$//" | tail -1 )

	echo -n "$i"

	if [ "x$k" != "x" ]; then
		echo -n "."
		echo "delete from interog8s where i_asset=$k;" >> $TEMP_DIR/asset.mysql

		for l in $( sed "s/ /###/g" $i ); do
			m=$( echo $l | sed "s/^\(...\).*$/\1/" )
			n=$( echo $l | sed "s/^.*,\([^,]*\)$/\1/" | fromdos )
			case $m in
				IPA)
					o=1
					;;
				SNO)
					n=$( echo $l | sed "s/^.*,\([^,]*\),[^,]*$/\1/" | fromdos )
					o=2
					;;
				USR)
					o=3
					;;
				WIN)
					o=4
					;;
				DRV)
					o=7
					;;
				PAG)
					o=5
					;;
				"###")
					o=6
					;;
				*)
					o=7
					;;
			esac

			if [ $o -gt 0 ]; then
				echo "insert into interog8s (s_interog8, i_i8type, i_asset) values (\"$n\", $o, $k);" >> $TEMP_DIR/asset.mysql
			fi
		done
		m=$( grep "^SNO" $i | tail -1 | sed "s/^....\(....\)\(..\)\(..\).*$/\1-\2-\3/" )
		echo "insert into interog8s (s_interog8, i_i8type, i_asset) values ('$m', 8, $k);" >> $TEMP_DIR/asset.mysql

		echo $i >> $TEMP_DIR/i8s.done
	else
		m=$( echo $j | sed "s/^\(......\).*$/\1/" )

		if [ "x$m" = "xVMware" ]; then 
			echo $i >> $TEMP_DIR/i8s.vmware; 
		elif [ "x$m" = "x######" ]; then 
			echo $i >> $TEMP_DIR/i8s.null; 
		else
			echo $i >> $TEMP_DIR/i8s.error;
		fi

	fi

	echo "> Serial $j = Asset $k "

done > $TEMP_DIR/file.proc

echo "4: Processing Updates"

mysql -umspence -ppassword \
	< $TEMP_DIR/asset.mysql

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
grep -c "^" $TEMP_DIR/asset.delete
echo -n "Number of Inserts: "
grep -c "^" $TEMP_DIR/asset.insert
echo "--------------------------------------------------"

sed 's/^[^,]*,\(.*\)$/\1/' $TEMP_DIR/assets.txt > $TEMP_DIR/snos.found
for i in $( grep -xvF -f $TEMP_DIR/snos.found $TEMP_DIR/snos.only ); do
	j=$( echo $i | sed 's/###/ /g' )
	echo $j
	grep ",$i" $TEMP_DIR/snos.raw | sed 's/###/ /g' | sed 's/^/>/'
done > $TEMP_DIR/snos.faulty

# cat $TEMP_DIR/snos.faulty

grep "^>" $TEMP_DIR/snos.faulty | sed 's/^[^,]*,\([^,]*\),.*$/\1/' > $TEMP_DIR/i8s.bad

for i in $(< $TEMP_DIR/i8s.done ); do
	if [ -e "$i" ]; then
		mv "$i" $ING8_DIR/done/.
	fi
done

for i in $(< $TEMP_DIR/i8s.null ); do
	if [ -e "$i" ]; then
		mv "$i" $ING8_DIR/null/.
	fi
done

for i in $(< $TEMP_DIR/i8s.error ); do
	if [ -e "$i" ]; then
		mv "$i" $ING8_DIR/error/.
	fi
done

for i in $(< $TEMP_DIR/i8s.vmware ); do
	if [ -e "$i" ]; then
		mv "$i" $ING8_DIR/vmware/.
	fi
done

rm $TEMP_DIR/arev.lock
