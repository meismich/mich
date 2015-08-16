#!/bin/ksh

ETCDIR=/home/mspence/dev/Tipt/etc
OUTDIR=/home/mspence/dev/Tipt/out
DATDIR=/home/mspence/dev/Tipt/dat
TMPDIR=/home/mspence/dev/Tipt/tmp

UPSFILE='index.html?buttonClicked=search&rowNum=0&findKey0=UserLastName&findOp0=STARTS_WITH&findValue0=&search=Search&buttonClicked='


cat $ETCDIR/login.rq | sed "s/###UN###/$1/g" | sed "s/###PW###/$2/g" > $TMPDIR/gup.rq
cat $ETCDIR/get_user_pages.rq >> $TMPDIR/gup.rq

#rm $OUTDIR/*
wget -P $OUTDIR --no-check-certificate -i $TMPDIR/gup.rq > /dev/null 2> /dev/null

grep "\[ Page [0-9]* of [0-9]* \]" $OUTDIR/$UPSFILE | sed "s/^.*\[ Page [0-9]* of \([0-9]*\) \].*$/\1/"

