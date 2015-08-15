#!/bin/bash

clear

echo "PRINTER QUERY SCRIPT"
echo "==============================================================================="
echo
echo "1- Querying devices for information"

echo "-------------------------------------------------------------------------------"
rm pQry.out
touch pQry.out

if [ "x$1" == "x" ]; then

	echo "usage: pqry <filename>"

else

for i in `cat $1`; do

	m=`snmpget -v 1 -c public $i 1.3.6.1.2.1.43.10.2.1.4.1.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	if [[ -n $m ]]; then
		n=`snmpget -v 1 -c public $i hrDeviceDescr.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
		o=`snmpget -v 1 -c public $i 1.3.6.1.4.1.1347.43.5.1.1.28.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	else
		n=''
		o=''
	fi

	# if m is null then write an error message

	echo "$i, $m, $n, $o"
done >> pQry.out

echo "-------------------------------------------------------------------------------"

echo "2- Reconfiguring output to report layout"
d=`date`
echo "Printer Report [$d]" > pQry.csv
echo "(~/src/pqry/pQry.sh)" >> pQry.csv
echo "c/- Michael Spence" >> pQry.csv
echo >> pQry.csv
echo "IP Address, Reported Pages, Reported Model, Serial No." >> pQry.csv

sort pQry.out >> pQry.csv

echo "FINAL- Emailing list to Michael"
mailx -s "Printer Monitoring" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./pQry.csv \
	mspence@apeagers.com.au < pQry.body

echo
echo "==============================================================================="
echo "DONE"
echo

fi
