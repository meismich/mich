#!/bin/bash

sfile=$1
wfile='./data/tmp/cleaning.wrk'
tfile='./data/tmp/cleaning.tmp'

cp $sfile $wfile
echo $sfile, $wfile, $tfile


i=`grep -n "<script" $wfile | head -1 | sed 's/:.*$//'`
j=`grep -n "<\/script" $wfile | head -1 | sed 's/:.*$//'`

echo "$i, $j"

while [[ $i > 0 ]]; do
	mv $wfile $tfile
	scmd=":${i},${j}s/^.*$/#REMOVED/"
	echo $scmd
	vim -c $scmd -c ":wq!$wfile" $tfile > /dev/null 2> /dev/null

	i=`grep -n "<script" $wfile | head -1 | sed 's/:.*$//'`
	j=`grep -n "<\/script" $wfile | head -1 | sed 's/:.*$//'`
	echo "$i, $j"
done
