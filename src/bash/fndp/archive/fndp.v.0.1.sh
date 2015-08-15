#
# FILE:		fndp.sh
# DATE:		2013-08-03
# AUTHOR:	Michael Spence
#
# PURPOSE:
#	Find Peripherals that respond to SNMP within APEagers network
#	Printer assumed to be within net.150 and net.199 
#		and Network devices between net.220 and net.253
#

XTRA_DIR=/home/mspence/src/fndp/etc
TEMP_DIR=/home/mspence/src/fndp/tmp

for i in $(< $XTRA_DIR/$1 ); do

	a=$( echo $i | sed "s/^[^,]*,//" )
	s=$( echo $i | sed "s/,[^,]*$//" )

	time for j in $( < $XTRA_DIR/subs.txt ); do
		b=$( echo $j | sed "s/^[^,]*,//" )
		t=$( echo $j | sed "s/,[^,]*$//" )

		echo -n "$a.$b/24 ... Printers"
		c=150
		while [ $c -lt 200 ]; do
			n="$a.$b.$c"
			echo -n "($n)" >&2
			snmpwalk -On -r0 -t1 -c public -v 2c $n .1.3.6.1.2.1.4.20.1.1 2> /dev/null 

			c=$(( $c + 1 ))
		done > $TEMP_DIR/snmp.lpt
		grep -v "127.0.0.1" $TEMP_DIR/snmp.lpt > $TEMP_DIR/${s}_${t}.printer

		echo -n " ... NetDevs"
		c=220
		while [ $c -lt 254 ]; do
			n="$a.$b.$c"
			snmpwalk -On -r0 -t1 -c apsnmpro -v 2c $n .1.3.6.1.2.1.4.20.1.1 2> /dev/null 

			c=$(( $c + 1 ))
		done > $TEMP_DIR/snmp.swz

		echo " ... Done"
		grep -v "127.0.0.1" $TEMP_DIR/snmp.swz > $TEMP_DIR/${s}_${t}.netdev
	done

done
