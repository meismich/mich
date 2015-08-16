#!/bin/ksh

ETCDIR=/home/mspence/dev/Tipt/etc
OUTDIR=/home/mspence/dev/Tipt/out
DATDIR=/home/mspence/dev/Tipt/dat
TMPDIR=/home/mspence/dev/Tipt/tmp

UISFILE='index.html?repage=true*'


cat $ETCDIR/login.rq | sed "s/###UN###/$1/g" | sed "s/###PW###/$2/g" > $TMPDIR/gui.rq

#cat $ETCDIR/get_user_pages.rq >> $TMPDIR/gus.rq

#i=$( head -1 $DATDIR/users.dat | sed 's/%3A/:/g' | sed 's/%40/@/' )
for i in $(< $DATDIR/users.dat ); do
	cat $ETCDIR/get_user_info.rq | sed "s/###ID###/$i/" >> $TMPDIR/gui.rq
done

cat $TMPDIR/gui.rq

rm $OUTDIR/*
wget -P $OUTDIR --no-check-certificate -i $TMPDIR/gui.rq > /dev/null 2> $TMPDIR/log.txt

for i in $( sed "s/^.*%3A//" < $DATDIR/users.dat | sed "s/%40/@/" ); do
	echo $i
	echo $i > $DATDIR/$i.dat
	for j in $( grep -H $i $OUTDIR/index.html* | sed "s/:.*$//" | sort | uniq ); do
		echo $j
		k=$( grep -n -h "MAIN BODY" $j | sed "s/:.*$//" )
		tail +$k $j >> $OUTDIR/$i.dat
	done
done


