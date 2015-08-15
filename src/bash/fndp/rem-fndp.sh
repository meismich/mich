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
DATA_DIR=/home/mspence/src/fndp/rem

clear

for i in $(< $XTRA_DIR/rem-nets.txt ); do

	a=$( echo $i | sed "s/^[^,]*,[^,]*,//" )
	r=$( echo $i | sed "s/^[^,]*,\([^,]*\),[^,]*$/\1/" )
	s=$( echo $i | sed "s/,[^,]*,[^,]*$//" )

	if [ "x$r" == "xI" ]; then

		h="${a}.0/24"

	else

		h=""
		for j in $( < $XTRA_DIR/subs.txt ); do
	
			b=$( echo $j | sed "s/^[^,]*,//" )
			t=$( echo $j | sed "s/,[^,]*$//" )
	
			h="$h ${a}.${b}.0/24"
	
		done

	fi
	
	echo -n "[$h] ... NMap HTTP"
	nmap --min-hostgroup 256 --max-rtt-timeout 500 --max-retries 2 -T5 -n -PS -p 80 -oG $TEMP_DIR/${s}_ALL_WEB.nmap ${h} 2> /dev/null > /dev/null
	echo -n " ... NMap JetD"
	nmap --min-hostgroup 256 --max-rtt-timeout 500 --max-retries 2 -T5 -n -PS -p 9100 -oG $TEMP_DIR/${s}_ALL_LPT.nmap ${h} 2> /dev/null > /dev/null
	echo -n " ... NMap SMBa"
	nmap --min-hostgroup 256 --max-rtt-timeout 500 --max-retries 2 -T5 -n -PS -p 445 -oG $TEMP_DIR/${s}_ALL_WIN.nmap ${h} 2> /dev/null > /dev/null

	touch $TEMP_DIR/${s}.webhosts
	grep "Ports: 80\/open" $TEMP_DIR/${s}_ALL_WEB.nmap | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $DATA_DIR/${s}.webhosts

	echo -n " ... NMap TTYs"
	nmap -n -PN -p23 -oG $TEMP_DIR/${s}_ALL_TTY.nmap -iL $DATA_DIR/${s}.webhosts 2> /dev/null > /dev/null

	grep "Ports: .*9100\/open" $TEMP_DIR/${s}_ALL_LPT.nmap | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $DATA_DIR/${s}.printers
	grep "Ports: .*23\/open" $TEMP_DIR/${s}_ALL_TTY.nmap | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $DATA_DIR/${s}.switches
	grep "Ports: .*445\/open" $TEMP_DIR/${s}_ALL_WIN.nmap | grep "^Host" | sed "s/^Host: \([^ ]*\) .*$/\1/" > $DATA_DIR/${s}.computers

	echo 
	echo -n "    Webhosts: "; grep -c "^" $DATA_DIR/${s}.webhosts
	echo -n "    Printers: "; grep -c "^" $DATA_DIR/${s}.printers
	echo -n "    Switches: "; grep -c "^" $DATA_DIR/${s}.switches
	echo -n "    Computrs: "; grep -c "^" $DATA_DIR/${s}.computers

done
