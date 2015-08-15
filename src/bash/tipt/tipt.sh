#!/bin/bash

lftp -f tipt.ftp

k=0
# Process IAD Files (aka SPA)
echo "APEagers 8-port IAD devices" > out/allspa.out
for i in `ls out/spa/spa*.xml`; do
	k=`expr $k + 1`
	l=`echo 00$k | sed 's/.*\(..\)$/\1/'`
	j=`echo $i | sed 's/^.*spa\(....\)\(....\)\(....\)\.xml/\1-\2-\3/'`
	echo 
	echo "$l Device with MAC = $j"
	grep "<Auth_ID_[1-8]_ " $i | sed "s/<Auth_ID_\([1-8]\)_.*>\(.*\)<\/.*$/$l Port \1 = \2/"
done >> out/allspa.out

echo >> out/allspa.out
echo "APEagers 2-port IAD devices" >> out/allspa.out
#for i in `ls out/spa/spa*.cfg`; do
	#j=`echo $i | sed 's/^.*spa\(....\)\(....\)\(....\)\.xml/\1-\2-\3/'`
	#echo 
	#echo "Device with MAC = $j"
	#grep "<Auth_ID_[1-8]_ " $i | sed 's/<Auth_ID_\([1-8]\)_.*>\(.*\)<\/.*$/Port \1 = \2/'
#done >> out/allspa.out
