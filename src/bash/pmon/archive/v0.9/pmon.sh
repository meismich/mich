#!/bin/bash

clear

echo "PRINTER MONITOR SCRIPT"
echo "==============================================================================="
echo
echo "1- Fetching Printer List from Database"
mysql -umspence -ppassword < pmon.mysql > pmon.1st

echo "2- Reconfiguring Printer List for use"
sed 's/\t/_/g' < pmon.1st | sed 's/ /#/g' | tail +2 > pmon.2nd

echo "3- Querying devices for information"

echo "-------------------------------------------------------------------------------"
rm pmon.out
touch pmon.out

for i in `cat pmon.2nd`; do


	j=`echo $i | sed 's/^\([^_]*\).*$/\1/'`
	k=`echo $i | sed 's/^[^_]*_\([^_]*\).*$/\1/'`
	l=`echo $i | sed 's/^[^_]*_[^_]*_\(.*\)$/\1/'`

	m=`snmpget -v 1 -c public $k 1.3.6.1.2.1.43.10.2.1.4.1.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	if [[ -n $m ]]; then
		n=`snmpget -v 1 -c public $k hrDeviceDescr.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
		o=`snmpget -v 1 -c public $k 1.3.6.1.4.1.1347.43.5.1.1.28.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	else
		n=''
		o=''
	fi

	# if m is null then write an error message

	#echo "Asset $j is a $l [IP: $k] $m [Rep= $n]"
	echo "$j, $l, $k, $m, $n, $o"
done >> pmon.out

echo "-------------------------------------------------------------------------------"

echo "4- Reconfiguring output to report layout"
d=`date`
echo "Printer Report [$d]" > pmon.csv
echo "(~/src/pmon/pmon.sh)" >> pmon.csv
echo "c/- Michael Spence" >> pmon.csv
echo >> pmon.csv
echo "Asset No, Assumed Model, IP Address, Reported Pages, Reported Model, Serial No." >> pmon.csv

sort pmon.out >> pmon.csv

echo "FINAL- Emailing list to Michael"
mailx -s "Printer Monitoring" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./pmon.csv \
	mspence@apeagers.com.au < ../bulkassetreps/mar.body

echo
echo "==============================================================================="
echo "DONE"
echo
