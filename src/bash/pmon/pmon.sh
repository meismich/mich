#
# FILE:		pmon.sh
# DATE:		2013-08-04
# AUTHOR:	Michael Spence
#
# PURPOSE:
#	Monitor Peripherals and report in Interog8 format for auditing purposes.
#

LPTS_DIR=/home/mspence/src/fndp/out
SWZS_DIR=/home/mspence/src/fndp/out

TEMP_DIR=/home/mspence/src/pmon/tmp
XTRA_DIR=/home/mspence/src/pmon/etc
WORK_DIR=/home/mspence/src/pmon/out
INT8_DIR=/issadm/drives

echo "1. Concatenating Found Lists"
cat $LPTS_DIR/*.printers > $TEMP_DIR/found.printer
cat $SWZS_DIR/*.switches > $TEMP_DIR/found.netdev

echo "2. Processing Found Printers"
if [ -e $TEMP_DIR/failed.printer ]; then rm $TEMP_DIR/failed.printer; fi
for i in $(< $TEMP_DIR/found.printer ); do
	j=$( snmpget -r 2 -On -c public -v 1 $i .1.3.6.1.2.1.1.1.0 | 
			grep "\.1\.3\.6\.1\.2\.1\.1\.1\.0" |
			sed 's/^.*STRING: \([^ ]*\) .*$/\1/' | 
			head -1 
			)
	echo -n $j
	k=""
	if [ "x$j" == "xKYOCERA" ]; then
		k=$( snmpget -On -c public -v 1 $i .1.3.6.1.2.1.43.5.1.1.17.1 | 
				grep "\.1\.3\.6\.1\.2\.1\.43\.5\.1\.1\.17\.1" |
				grep -v "No Such" | 
				sed 's/^.*STRING: "\([^"]*\)".*$/\1/' | 
				sed 's/ //g' 
				)
		l=$( snmpget -On -c public -v 1 $i .1.3.6.1.2.1.43.10.2.1.4.1.1 | 
				grep "\.1\.3\.6\.1\.2\.1\.43\.10\.2\.1\.4\.1\.1" |
				grep -v "No Such" | 
				sed 's/^.*Counter32: \([0-9]*\)[^0-9]*$/\1/' | 
				sed 's/^.*INTEGER: \([0-9]*\)[^0-9]*$/\1/' | 
				sed 's/ //g' 
				)
		m=$( snmpget -On -c public -v 1 $i .1.3.6.1.2.1.43.5.1.1.16.1 | 
				grep "\.1\.3\.6\.1\.2\.1\.43\.5\.1\.1\.16\.1" |
				grep -v "No Such" | 
				sed 's/^.*STRING: "\([^"]*\)".*$/\1/' | 
				sed 's/ //g' 
				)
		echo -n " ... $k ... $l"
		f="$i-printer-INTEROG8.csv"
		d=$( date +%Y%m%d%H%M%S%z )
		echo "###,Interog8,v2.1" > $WORK_DIR/$f
		echo "USR,$d,$i,pmon.printer" >> $WORK_DIR/$f
		echo "SNO,$d,$i,$k" >> $WORK_DIR/$f
		echo "PAG,$d,$i,$l" >> $WORK_DIR/$f
		echo "IPA,$d,$i,$i" >> $WORK_DIR/$f
		echo "MOD,$d,$i,$m" >> $WORK_DIR/$f
	fi
	if [ "x$k" == "x" ]; then
		echo $i >> $TEMP_DIR/failed.printer
	fi
	echo
done

echo "3. Processing Found Network Devices"
if [ -e $TEMP_DIR/failed.netdev ]; then rm $TEMP_DIR/failed.netdev; fi
for i in $(< $TEMP_DIR/found.netdev ); do
	j=$( snmpget -r 2 -On -c apsnmpro -v 2c $i .1.3.6.1.2.1.1.1.0 | 
			sed 's/^.*STRING: \([^ ]*\) .*$/\1/' | 
			head -1 )
	echo -n "($j)"
	k=""
	case "x$j" in 
		xHP|xProCurve|xCisco)
			k=$( snmpwalk -On -c apsnmpro -v 2c $i .1.3.6.1.2.1.47.1.1.1.1.11 | 
					grep "\.1\.3\.6\.1\.2\.1\.47\.1\.1\.1\.1\.11" |
					head -1 | 
					grep -v "No Such" | 
					sed 's/^.*STRING: "\([^"]*\)".*$/\1/' | 
					sed 's/ //g' 
					)
			n=$( snmpget -On -c apsnmpro -v 2c $i .1.3.6.1.2.1.1.5.0 | 
					grep "\.1\.3\.6\.1\.2\.1\.1\.5\.0" |
					sed "s/^.*: //" | 
					sed "s/-/_/g" | 
					sed "s/ //g" 
					)
			m=$( snmpwalk -On -c apsnmpro -v 2c $i .1.3.6.1.2.1.47.1.1.1.1.2 | 
					grep "\.1\.3\.6\.1\.2\.1\.47\.1\.1\.1\.1\.2" |
					head -1 | 
					grep -v "No Such" | 
					sed 's/^.*STRING: "\([^"]*\)".*$/\1/' | 
					sed 's/ //g' 
					)
			
			if [ "x$n" == "x" ]; then
				n=$i
			fi
			;;
		*)
			k=""
			;;
	esac
	echo -n " ... [$k] "

	if [ "x$k" != "x" ]; then
		f="$n-netdev-INTEROG8.csv"
		d=$( date +%Y%m%d%H%M%S%z )
		echo "###,Interog8,v2.1" > $WORK_DIR/$f
		echo "USR,$d,$n,pmon.netdev" >> $WORK_DIR/$f
		echo "SNO,$d,$n,$k" >> $WORK_DIR/$f
		echo "IPA,$d,$n,$i" >> $WORK_DIR/$f
		echo "MOD,$d,$n,$m" >> $WORK_DIR/$f
	else
		echo $i >> $TEMP_DIR/failed.netdev
	fi
	echo
done

mv $WORK_DIR/*.csv $INT8_DIR/*.csv

echo "================================"
echo " PERIPHERAL MONITORING REPORT "
echo "================================"
echo
echo -n " Total Printers: "
grep -c "^" $TEMP_DIR/found.printer
echo
echo -n " Failed Printers: "
grep -c "^" $TEMP_DIR/failed.printer
echo
echo "--------------------------------"
cat $TEMP_DIR/failed.printer
echo "--------------------------------"
echo
echo -n " Total Switches: "
grep -c "^" $TEMP_DIR/found.netdev
echo
echo -n " Failed Switches: "
grep -c "^" $TEMP_DIR/failed.netdev
echo
echo "--------------------------------"
cat $TEMP_DIR/failed.netdev
echo "--------------------------------"

