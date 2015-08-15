#!/bin/bash

carmake=$1
carmodl=$2

#/usr/bin/wget -odminer.log -Oa.out http://www.carsales.com.au/all-cars/results.aspx?N=1216+1247+1282+1252+$carmake+$carmodl&Nne=1500
/usr/bin/wget -odminer.log -Oa.out http://www.carsales.com.au/all-cars/results.aspx?N=1216+1247+1282+1252+$carmake&Nne=15
#/usr/bin/wget -odminer.log -Oa.out http://www.carsales.com.au/all-cars/results.aspx?N=1216+1247+1282+1252&Nne=150000

wait

cat a.out | sed 's/<[^>]*>//g' > b.out
