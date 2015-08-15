#!/bin/bash

clear

echo "AGED ASSET REPORT SCRIPT"
echo "==============================================================================="
echo
echo "1- Build Database Query Script"
echo "use assets;" > aged.mysql
c=`date +%Y`
d=$(( $c - 3 ))
e=`date +%m`
f=`date +%d`
echo "select * from xassets where t_date < '$d-$e-$f' and t_date > '1970-01-01' and s_status = 'Active' order by t_date;" >> aged.mysql

echo "2- Fetching Asset List from Database"
mysql -umspence -ppassword < aged.mysql > aged.1st

echo "3- Reconfiguring Output to Report Layout"
d=`date`
echo "Aged Asset Report [$d]" > aged.csv
echo "(~/src/aged/aged.sh)" >> aged.csv
echo "c/- Michael Spence" >> aged.csv
echo >> aged.csv
echo "Asset No, Serial No, Status, Model, Device, Date, Location, Group, Department, Description" >> aged.csv
sed 's/\t/,/g' < aged.1st | tail +2 | sort >> aged.csv


echo "FINAL- Emailing Report to Michael"
mailx -s "Outdated/Aged Assets" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./aged.csv \
	mspence@apeagers.com.au < ../gen.body

echo
echo "==============================================================================="
echo "DONE"
echo
