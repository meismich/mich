#!/bin/bash

#Arguments
#
# $1 is Start Number
# $2 is Car Make
# $3 is quantity to Return

a="http://www.carsales.com.au/all-cars/results.aspx?No=$1&N=1216+1247+1282+1252+$2&Nne=$3"
echo $a

#/usr/bin/wget -odminer.log -Oa.out http://www.carsales.com.au/all-cars/results.aspx?No=$1&N=1216+1247+1282+1252+$2&Nne=$3
/usr/bin/wget -odminer.log -Oa.out "$a"

wait

cat a.out | sed 's/<[^>]*>//g' > data/b$3-$1.out
