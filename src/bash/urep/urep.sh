#!/bin/bash


INTR_DIR=/issadm/drives/done
FIND_DIR=/home/mspence/src/fndp/out
XTRA_DIR=/home/mspence/src/urep/etc
WORK_DIR=/home/mspence/src/urep/out
TEMP_DIR=/home/mspence/src/urep/tmp

# Generate list of serial numbers from "Done" interog8s

#echo "0: Creating list of valid Interog8 files"
#for i in $( ls --indicator-style=none -t $INTR_DIR/*csv ); do
        #if [ -e "$i" ]; then
                #echo -n  "$i"
                #head -q  -n 1 "$i"
                #echo
        #fi
#done    | grep "Interog8,v2.1" \
        #| sed 's/###,Interog8,v2.1.*$//' \
        #> $TEMP_DIR/i8s.txt
#
#echo "1: Creating list of unique serial numbers"
#for i in $(< $TEMP_DIR/i8s.txt ); do
        #grep "^SNO" "$i" | sed 's/^SNO,//' | sed 's/ /###/g'
#done    | fromdos \
        #> $TEMP_DIR/snos.raw
#
#sed 's/^.*,\([^,]*\)$/\1/' $TEMP_DIR/snos.raw \
        #| sort \
        #| uniq \
        #> $TEMP_DIR/snos.uniq
#
#for i in $(< $TEMP_DIR/snos.uniq ); do
        #grep ",$i" $TEMP_DIR/snos.raw \
                #| sort \
                #| tail -1
#done > $TEMP_DIR/snos.final

# Generate reports from DB
echo "1: Create DB Reports"
echo "1a: Active w/ Invalid Interog8 Data"
mysql -umspence -ppassword < $XTRA_DIR/act_noi8.mysql | sed 's/\t/,/g' | sed 's/ /###/g' | tail +2 > $TEMP_DIR/act_noi8.txt
echo "1b: Interog8 Data but Not Active"
mysql -umspence -ppassword < $XTRA_DIR/i8_noact.mysql | sed 's/\t/,/g' | sed 's/ /###/g' | tail +2 > $TEMP_DIR/i8_noact.txt
echo "1c: Interog8 Descriptions"
mysql -umspence -ppassword < $XTRA_DIR/i8_descs.mysql | sed 's/\t/,/g' | sed 's/ /###/g' | tail +2 > $TEMP_DIR/i8_descs.txt


echo "2: Report: Active but no i8"
echo "==========================================================================" > $WORK_DIR/act_noi8_report.txt
echo "Active But no INTEROG8 Data" >> $WORK_DIR/act_noi8_report.txt
echo  >> $WORK_DIR/act_noi8_report.txt
echo -n "Total Assets: " >> $WORK_DIR/act_noi8_report.txt
grep -c "^" $TEMP_DIR/act_noi8.txt >> $WORK_DIR/act_noi8_report.txt
# Find reported serials in list
for i in $(< $TEMP_DIR/act_noi8.txt ); do
	echo "--------------------------------------------------------------------------"
	echo "AssetDB (Asset		Serial		Interog8	Type) "
	echo "	$i" | sed 's/###/ /g' | sed 's/,/\t/g' | sed 's/NULL/NULL\t/'
	
	j=$( echo $i | sed 's/^\([0-9]*\),.*$/\1/' )
	
	k=$( grep -c "^$j" $TEMP_DIR/i8_descs.txt )

	if [ $k -gt 0 ]; then
		echo
		echo "Interog8 Data"

		grep "$j," $TEMP_DIR/i8_descs.txt | 
				sed 's/^[0-9]*,/\t/' | 
				sed 's/^\([^,]*\),/\1:\t/' | 
				sed 's/###/ /g'
	fi

done >> $WORK_DIR/act_noi8_report.txt


echo "3: Report: i8 but not Active"
echo "==========================================================================" > $WORK_DIR/i8_noact_report.txt
echo "INTEROG8 Data But NOT Active" >> $WORK_DIR/i8_noact_report.txt
echo  >> $WORK_DIR/i8_noact_report.txt
echo -n "Total Assets: " >> $WORK_DIR/i8_noact_report.txt
grep -c "^" $TEMP_DIR/i8_noact.txt >> $WORK_DIR/i8_noact_report.txt
# Find reported serials in list
for i in $(< $TEMP_DIR/i8_noact.txt ); do
	echo "--------------------------------------------------------------------------"
	echo "AssetDB (Asset		Serial		Interog8	Type) "
	echo "	$i" | sed 's/###/ /g' | sed 's/,/\t/g' | sed 's/NULL/NULL\t/'

	j=$( echo $i | sed 's/^\([0-9]*\),.*$/\1/' )
	
	k=$( grep -c "^$j" $TEMP_DIR/i8_descs.txt )

	if [ $k -gt 0 ]; then
		echo
		echo "Interog8 Data"

		grep "$j," $TEMP_DIR/i8_descs.txt | 
				sed 's/^[0-9]*,/\t/' | 
				sed 's/^\([^,]*\),/\1:\t/' | 
				sed 's/###/ /g'
	fi

done >> $WORK_DIR/i8_noact_report.txt

echo "4: Report: Exception Summary"
echo "==========================================================================" > $WORK_DIR/exception_report.txt
echo "USAGE REPORT: EXCEPTIONS SUMMARY" >> $WORK_DIR/exception_report.txt
echo  >> $WORK_DIR/exception_report.txt

echo "Number of Active w/ Invalid Interog8 Data:"  >> $WORK_DIR/exception_report.txt
grep -c "^" $TEMP_DIR/act_noi8.txt | sed 's/^/\tTOTAL:      /' >> $WORK_DIR/exception_report.txt
grep -c "PC$" $TEMP_DIR/act_noi8.txt | sed 's/^/\tPCs:        /' >> $WORK_DIR/exception_report.txt
grep -c "Thin###Client$" $TEMP_DIR/act_noi8.txt | sed 's/^/\tThinClient: /' >> $WORK_DIR/exception_report.txt
grep -c "Notebook$" $TEMP_DIR/act_noi8.txt | sed 's/^/\tNotebook:   /' >> $WORK_DIR/exception_report.txt
grep -c "Printer$" $TEMP_DIR/act_noi8.txt | sed 's/^/\tPrinter:    /' >> $WORK_DIR/exception_report.txt
grep -c "Zbox$" $TEMP_DIR/act_noi8.txt | sed 's/^/\tZbox:       /' >> $WORK_DIR/exception_report.txt
echo  >> $WORK_DIR/exception_report.txt

echo "Number of InActive w/ Valid Interog8 Data:"  >> $WORK_DIR/exception_report.txt
grep -c "^" $TEMP_DIR/i8_noact.txt | sed 's/^/\tTOTAL:      /'  >> $WORK_DIR/exception_report.txt
echo  >> $WORK_DIR/exception_report.txt

echo "Number of Interog8s this Month with Status:"  >> $WORK_DIR/exception_report.txt
d=$( date '+%Y-%m')
ls -la $INTR_DIR/../done/*csv | 
		grep -v "netdev" |
		grep " ${d}-[0-9][0-9] " | 
		sed "s/.* \([^ ]*\)$/\1/" | 
		sed "s/-[^-]*-INTEROG8.csv//" | 
		sort | 
		uniq | 
		grep -c "^" | 
		sed "s/^/\tDONE:       /"  >> $WORK_DIR/exception_report.txt
ls -la $INTR_DIR/../error/*csv | 
		grep -v "netdev" |
		grep " ${d}-[0-9][0-9] " | 
		sed "s/.* \([^ ]*\)$/\1/" | 
		sed "s/-[^-]*-INTEROG8.csv//" | 
		sort | 
		uniq | 
		grep -c "^" | 
		sed "s/^/\tERROR:      /"  >> $WORK_DIR/exception_report.txt
ls -la $INTR_DIR/../null/*csv | 
		grep -v "netdev" |
		grep " ${d}-[0-9][0-9] " | 
		sed "s/.* \([^ ]*\)$/\1/" | 
		sed "s/-[^-]*-INTEROG8.csv//" | 
		sort | 
		uniq | 
		grep -c "^" | 
		sed "s/^/\tNULL:       /"  >> $WORK_DIR/exception_report.txt
ls -la $INTR_DIR/../vmware/*csv | 
		grep -v "netdev" |
		grep " ${d}-[0-9][0-9] " | 
		sed "s/.* \([^ ]*\)$/\1/" | 
		sed "s/-[^-]*-INTEROG8.csv//" | 
		sort | 
		uniq | 
		grep -c "^" | 
		sed "s/^/\tVMWARE:     /"  >> $WORK_DIR/exception_report.txt

echo  >> $WORK_DIR/exception_report.txt
echo "Number of NMAP found devices:"  >> $WORK_DIR/exception_report.txt
cat $FIND_DIR/*computers | grep -c "^" | sed "s/^/\tComputers:  /"  >> $WORK_DIR/exception_report.txt
cat $FIND_DIR/*printers | grep -c "^" | sed "s/^/\tPrinters:   /"  >> $WORK_DIR/exception_report.txt



echo "5: Emailing reports to Field Support"
d=$( date +%Y-%m-%d )
mailx -s "Asset Usage Reports - $d" \
	-r usage.report@ittools.apeagers.com.au \
	-a $WORK_DIR/act_noi8_report.txt \
	-a $WORK_DIR/i8_noact_report.txt \
	isfieldteam@apeagers.com.au mspence@apeagers.com.au < $WORK_DIR/exception_report.txt

