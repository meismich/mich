#!/bin/ksh

ETCDIR=/home/mspence/dev/Tipt/etc
OUTDIR=/home/mspence/dev/Tipt/out
DATDIR=/home/mspence/dev/Tipt/dat
TMPDIR=/home/mspence/dev/Tipt/tmp

USSFILE='index.html?repage=true*'


cat $ETCDIR/login.rq | sed "s/###UN###/$1/g" | sed "s/###PW###/$2/g" > $TMPDIR/gus.rq

cat $ETCDIR/get_user_pages.rq >> $TMPDIR/gus.rq

for (( i=0; i < $3; i++ )); do
	cat $ETCDIR/get_users.rq | sed "s/###PG###/$i/g" >> $TMPDIR/gus.rq
done

cat $TMPDIR/gus.rq

rm $OUTDIR/*
wget -P $OUTDIR --no-check-certificate -i $TMPDIR/gus.rq > /dev/null 2> /dev/null

grep "Row[0-9]*Col0" $OUTDIR/$USSFILE | sed "s/^.*key=//" | sed 's/".*$//' | sort > $DATDIR/users.dat

