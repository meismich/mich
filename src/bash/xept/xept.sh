

# Get a list of the NAMES of active assets with no Interog8 data

# Get a list of the NAMES of Interog8ed machines 

ls /issadm/drives/error/*.csv | sed "s/-[^-]*-INTEROG8.csv//" | sed "s/^.*\/\([^\/]*\)$/\1/" | sort | uniq > interog8_error.txt
ls /issadm/drives/null/*.csv | sed "s/-[^-]*-INTEROG8.csv//" | sed "s/^.*\/\([^\/]*\)$/\1/" | sort | uniq > interog8_null.txt

# Report on these findings

echo "Number of Named Active Assets with no Interog8 data (PC's/Printers only):"
echo -n "                                   "
grep -c "^" act_noi8_names.txt
echo
echo "Number of Interog8ed Machines with Non-Correlated Serial Numbers:"
echo -n "                                   "
grep -c "^" interog8_error.txt
echo

# Attempt to correlate names
for i in $(< interog8_error.txt ); do
	j=$(grep ",$i$" act_noi8_names.txt)
	if [ "x$j" != "x" ]; then
		k=$(grep "^SNO" /issadm/drives/error/$i* | head -1 | sed "s/^.*\.csv://" )
		echo "$j,$k"
	fi
done > correlated_error.txt
echo -n "Possible number of correlations:   "
grep -c "^" correlated_error.txt
echo

echo "Number of Interog8ed Machines with No Serial Numbers:"
echo -n "                                   "
grep -c "^" interog8_null.txt
echo
for i in $(< interog8_null.txt ); do
	j=$(grep ",$i$" act_noi8_names.txt)
	if [ "x$j" != "x" ]; then
		k=$(grep "^IPA" /issadm/drives/null/$i* | head -1 | sed "s/^.*\.csv://" )
		echo "$j,$k"
	fi
done > correlated_null.txt
echo -n "Possible number of correlations:   "
grep -c "^" correlated_null.txt


