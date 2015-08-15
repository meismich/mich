#!/bin/bash

#
# File:		cms.sh
# Date:		2009-05-12
# Author:	Michael Spence
#
# Purpose:
# Data mine the Carsales Site for stuff
#

#
# Arguments
#
carmake=$1
if [[ $carmake == "" ]]; then carmake="FORD"; fi
echo $carmake

rm -rf ./data/tmp/*

#
# Mine the makes of the cars
#
echo "STEP 1: Fetching the Makes of Cars"
/usr/bin/wget -ominer.log -O./data/tmp/makes.1st http://www.carsales.com.au/all-cars/search.aspx?

wait

# Post process mined make
echo "STEP 2: Filtering only the Makes of Cars"
grep -e "<[\/]*select" -e "<option" ./data/tmp/makes.1st | sed 's/<[\/]*div[^>]*>//g' | sed 's/ctl06\$.*\$//g' | fromdos > ./data/tmp/makes.2nd

echo "STEP 3: Reprocessing the Makes of Cars"
/usr/bin/vim +/cboModel -c ':.,$d' -c ':%g/select/d' -c ':%s/^.*option value=\"\([0-9]*\)\">\(.*\)[ \t](\([0-9]*\))<.*$/\2,\1,\3/g' -c ':wq! ./data/tmp/makes.3rd' ./data/tmp/makes.2nd > /dev/null 2> /dev/null

#
# Select the make of the cars
#
sline=`grep -e "^$carmake," ./data/tmp/makes.3rd`
imake=`echo $sline | sed 's/^.*,\(.*\),.*$/\1/'`
inum=`echo $sline | sed 's/^.*,.*,\(.*\)$/\1/'`

echo "   $carmake - identified by $imake - having $inum vehicles"

#
# Mine the make from Carsales
#
echo "STEP 4: Mine Data for Make of Cars"

idisp=150
ireps=`expr $inum / $idisp`
ireps=`expr $ireps + 1`
echo "   Requesting $ireps Pages...."

icurr=0

for (( i=0; i < $ireps; i=`expr $i + 1` )); do
	rm -rf ./data/tmp/wget*


	saddr="http://www.carsales.com.au/all-cars/results.aspx?No=$icurr&N=1216+1247+1282+1252+$imake&Nne=$idisp"
	echo "      Iteration $i - $saddr"

	/usr/bin/wget -ominer.log -O./data/tmp/wget.1st "$saddr"

	wait

	cat ./data/tmp/wget.1st | fromdos | vim - -c ':0,1063d' -c ':$-401,$d' -c ':%s/^[ \t]*//' -c ':%s/<[^>]*>//g' -c ':%g/^[ \t]*$/d' -c ':%g/&nbsp;/d' -c ":wq!./data/tmp/wg$idisp-$i.out" > /dev/null 2> /dev/null

	icurr=`expr $icurr + $idisp`
done

#
# Compile the mined data
#
echo "STEP 5: Compile Mined Data for Make of Cars"

for i in `ls ./data/tmp/wg$idisp*`; do
	cat $i
	wait
	rm $i
	wait
done | sed 's/ /_/g' | sed 's/,//g' > ./data/tmp/data.1st

vim -c ':%s/^.*QLD$/QLD\r#ENDRECORD\r/' -c ':%s/^.*VIC$/VIC\r#ENDRECORD\r/' -c ':%s/^.*NSW$/NSW\r#ENDRECORD\r/' -c ':%s/^.*TAS$/TAS\r#ENDRECORD\r/' -c ':%s/^.*ACT$/ACT\r#ENDRECORD\r/' -c ':%s/^.*WA$/WA\r#ENDRECORD\r/' -c ':%s/^.*SA$/SA\r#ENDRECORD\r/' -c ':%s/^.*NT$/NT\r#ENDRECORD\r/' -c ':wq!./data/tmp/data.2nd' ./data/tmp/data.1st > /dev/null 2> /dev/null

#
# Post process the mined data
# (ie convert to .csv)
#
echo "STEP 6: Finish Mined Data for Make of Cars"
j=""

for i in `cat ./data/tmp/data.2nd`; do
	if [[ "$i" == '#ENDRECORD' ]]; then
		echo $j >> ./data/tmp/data.3rd
		j=""
	else
		j="$j,$i"
	fi
done

echo $j >> ./data/tmp/data.3rd

sed 's/_/ /g' ./data/tmp/data.3rd | sed 's/^,\$/,,\$/' > ./data/data.csv
