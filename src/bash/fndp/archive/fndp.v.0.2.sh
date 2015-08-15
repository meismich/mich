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

for i in $(< $XTRA_DIR/nets.txt ); do

	a=$( echo $i | sed "s/^[^,]*,//" )
	s=$( echo $i | sed "s/,[^,]*$//" )

	time for j in $( < $XTRA_DIR/subs.txt ); do

		b=$( echo $j | sed "s/^[^,]*,//" )
		t=$( echo $j | sed "s/,[^,]*$//" )

		f="${s}_${t}"

		echo -n "$a.$b/24 ... NMap HTTP"

		nmap --min-hostgroup 256 --max-rtt-timeout 100 --max-retries 1 -T5 -n -PS -p 80 ${a}.${b}.0/24
		#nmap --host-timeout 3001 --max-retries 1 -n -PN -p80 -oG $TEMP_DIR/${f}.nmap ${a}.${b}.0/24

		grep "Ports: 80\/open" $TEMP_DIR/${f}.nmap | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $TEMP_DIR/${f}.hosts

		echo -n " ... Splitting Hosts"

		nmap -n -PN -p9100,23 -oG $TEMP_DIR/${f}.nmap2 -iL $TEMP_DIR/${f}.hosts

		grep "Ports: .*9100\/open" $TEMP_DIR/${f}.nmap2 | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $TEMP_DIR/${f}.printers
		grep -v -f $TEMP_DIR/${f}.printers $TEMP_DIR/${f}.nmap2 | grep "Ports: 23\/open" $TEMP_DIR/${f}.nmap2 | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $TEMP_DIR/${f}.netdev

	done

done
