#!/bin/bash

clear

echo "PRINTER REPLACMENT MAIL OUT"
echo "==============================================================================="
echo
echo "1- Hacking Primter Monitor CSV File"
tail +6 pmon.csv > prmo.1st

echo "2- Reducing List to Selected Printer Types"
grep "FS-3800" prmo.1st  > prmo.2nd
grep "FS-3830" prmo.1st >> prmo.2nd
grep "FS-1800" prmo.1st >> prmo.2nd
grep "FS-1900" prmo.1st >> prmo.2nd
grep "FS-1920" prmo.1st >> prmo.2nd

echo "3- Finalising input file"
sed 's/ /_/g' prmo.2nd > prmo.csv

echo "-------------------------------------------------------------------------------"

rm prmo.out
touch prmo.out

for i in `cat prmo.csv`; do

	j=`echo $i | sed 's/^\([^,]*\),.*$/\1/'`
	echo $i | sed 's/_/ /g' | sed 's/,/\n/g' > prmo.tmp
	
	mailx -s "Replace Printer - Asset $j" \
		-r issadmin@apeagers.com.au \
		servicedesk@apeagers.com.au < prmo.tmp

done >> prmo.out

echo "-------------------------------------------------------------------------------"

echo "4- Sending Report"

mailx -s "Printer Monitoring" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./prmo.csv \
	mspence@apeagers.com.au < ../bulkassetreps/mar.body

echo
echo "==============================================================================="
echo "DONE"
echo
