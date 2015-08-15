#!/bin/bash

clear

echo "PRINTER MONITOR SCRIPT (via IP list)"
echo "==============================================================================="
echo "1- Querying devices for information"

echo "-------------------------------------------------------------------------------"
rm pmon2.out
touch pmon2.out

for i in `cat pmon2.inp`; do

	echo $i >> pmon2.tmp

	#k=`echo $i | sed 's/^[^_]*_\([^_]*\).*$/\1/'`

	m=`snmpget -v 1 -c public $i 1.3.6.1.2.1.43.10.2.1.4.1.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	if [[ -n $m ]]; then
		n=`snmpget -v 1 -c public $i hrDeviceDescr.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
		o=`snmpget -v 1 -c public $i 1.3.6.1.2.1.43.5.1.1.17.1 | sed 's/.*:\([^:]*\)$/\1/g' 2> /dev/null `
	else
		n=''
		o=''
	fi

	if [[ -n $o ]]; then
		echo "use assets; select id from assets where s_serialno = $o limit 1;" > pmon2.mysql
		j=`mysql --skip-column-names -umspence -ppassword < pmon2.mysql`
	else
		j=''
	fi

	echo "$i, $j, $m, $n, $o"
done >> pmon2.out

echo "-------------------------------------------------------------------------------"

echo "4- Reconfiguring output to report layout"
d=`date`
echo "Printer Report [$d]" > pmon2.csv
echo "(~/src/pmon/pmon2.sh)" >> pmon2.csv
echo "c/- Michael Spence" >> pmon2.csv
echo >> pmon2.csv
echo "IP Address, Reported Pages, Reported Model" >> pmon2.csv

sort pmon2.out >> pmon2.csv

echo "FINAL- Emailing list to Michael"
mailx -s "Printer Monitoring" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./pmon.csv \
	mspence@apeagers.com.au < ../bulkassetreps/mar.body

echo
echo "==============================================================================="
echo "DONE"
echo
