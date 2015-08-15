#!/bin/bash
#
# FILE:		oass.sh
# DATE:		2013-01-06
# AUTHOR:	Michael Spence
#
# VERSION:	0.1
#
# PURPOSE:
# To load the Ocean Asset List in the Asset Database automatically
#
# NOTES:
# 2013-04-12 - 	Have verified that this code looks valid
# 		Noted that this WILL overwrite all serial numbers
#		... means CSVs are GOD for the Asset to Serial relationship
#
#		Input directory (UNC) \\bne-issadm\tmp\ocean
#

OASS_DIR=/issadm/ocean
XTRA_DIR=/home/mspence/src/oass/etc
WORK_DIR=/home/mspence/src/oass/out
TEMP_DIR=/home/mspence/src/oass/tmp
BKUP_DIR=/home/mspence/src/oass/bup

echo "OASS: Ocean Asset Spreadsheet loader"
echo "===================================="

echo "0: Perform Cleardown and Backup"
rm $TEMP_DIR/* 2> /dev/null

# Create backup of Database tables Purchases and Models
mysql -umspence -ppassword < $XTRA_DIR/bkuppurch.mysql
mysql -umspence -ppassword < $XTRA_DIR/bkupmodel.mysql

# Create backup of Database tables Assets and Descriptions
mysql -umspence -ppassword < $XTRA_DIR/bkupasset.mysql
mysql -umspence -ppassword < $XTRA_DIR/bkupdescr.mysql

d=$( date +%y-%m-%d )
tar -czf $BKUP_DIR/bup-$d.tgz $BKUP_DIR/*data
rm $BKUP_DIR/*data

#echo "Press [Enter] to continue:" 1>&2
#read ink

echo "1: Proccessing CSV files"
for i in $( ls $OASS_DIR/*.csv | sed 's/ /###/g' ); do

	echo $i

	j=$( echo $i | sed 's/###/ /g' )

	echo "1.a: FILE= [$j]"

	echo "1.b: Cleardown and Prep"
	rm $WORK_DIR/asset.new
	rm $TEMP_DIR/model.1st
	rm $TEMP_DIR/purch.1st
	rm $TEMP_DIR/model.1st
	echo "i_asset,i_desctype,s_description" > $WORK_DIR/descr.new

	# For each Asset ...
	echo "1.c: Process each Asset"
	sed 's/^\([^,]*\),.*$/\1/' "$j" | tail +4 > $TEMP_DIR/pur.1st
	for x in $( < $TEMP_DIR/pur.1st ); do
		y=`grep $x "$j" | head -1 | sed 's/ /_/g' | sed 's/,/ |/g'`

		echo $y
		
		# Build Array of Fields from Input File
		n=0 
		for z in $y; do 
			a[$n]=`echo $z | sed -e 's/^|//' -e 's/_/ /g'`; 
			(( n += 1 )); 
			if [[ $n -eq 30 ]]; then break; fi
		done
		# (Echo Fields to screen for debug)
		m=0; while [[ $m -lt $n ]]; do echo "[$m] = ${a[$m]}" 1>&2; (( m++ )); done

		# Fetch Model id for Model String and Purchase id for Purchase String
		b=`mysql -umspence -ppassword -N -e "use assets; select id from models where s_model='${a[7]}';" | tail -1`
		c=`mysql -umspence -ppassword -N -e "use assets; select id from purchases where s_invoiceno='${a[20]}';" | tail -1`
		echo "[Model = $b][Invoice = $c]"

		# If NO Model ID then ...
		if [[ "x$b" == "x" ]]; then
			echo "Need a Model created for this asset "
			d=`mysql -umspence -ppassword -N -e "use assets; select id from devicetypes where s_devicetype='${a[5]}';"`
			echo "${a[7]},${a[6]},$d"

			# ... record Details as additional
			echo "${a[7]},${a[6]},$d" >> $TEMP_DIR/model.1st
		fi

		# If NO Purchase ID then ...
		if [[ "x$c" == "x" ]]; then
			echo "Need a purchase built for this asset "
			e=`mysql -umspence -ppassword -N -e "use assets; select id from suppliers where s_supplier='${a[19]}';"`
			echo "${a[20]},$e,${a[18]}"
			nd=`echo ${a[18]} | sed 's/\([0-9]*\)\/\([0-9]*\)\/\([0-9]*\)/\3-\2-\1/'`
			# ... record Details as additional
			echo "${a[20]},$e,$nd" >> $TEMP_DIR/purch.1st
		fi

		# Record Asset details for Update
		echo "${a[0]},${a[7]},${a[20]},${a[8]}" >> $WORK_DIR/asset.new
		#echo "${a[0]},$b,$c,${a[8]}" >> $WORK_DIR/asset.new

		# Fetch Existing Descriptions (if any) for Asset's OS and Office
		f=`mysql -umspence -ppassword -N -e "use assets; select id from descriptions where i_asset=${a[0]} and i_desctype=8;"`
		g=`mysql -umspence -ppassword -N -e "use assets; select id from descriptions where i_asset=${a[0]} and i_desctype=9;"`

		# If NO OS Description then ...
		if [[ "x$f" == "x" ]]; then
			# ... and if OS Description TO add then ...
			if [[ "x${a[12]}" != "x" ]]; then
				# ... record details for addition
				echo "${a[0]},8,${a[11]} ${a[12]}" >> $WORK_DIR/descr.new
			fi
		fi

		# If NO Office Description then ...
		if [[ "x$g" == "x" ]]; then
			# ... and if Office Description TO add then ...
			if [[ "x${a[13]}" != "x" ]]; then
				# ... record details for addition
				echo "${a[0]},9,${a[14]} ${a[13]}" >> $WORK_DIR/descr.new
			fi
		fi
#		read ink

	done

	echo "1.d: Ensure unique Models and Assets"
	sort $TEMP_DIR/model.1st | uniq > $WORK_DIR/model.new
	sort $TEMP_DIR/purch.1st | uniq > $WORK_DIR/purch.new

	echo "1.e: Load Models, Assets and Descriptions"
	# Load Additional Purchases and Models into Database
	mysql -umspence -ppassword < $XTRA_DIR/loadpurch.mysql
	mysql -umspence -ppassword < $XTRA_DIR/loadmodel.mysql

	# Load Additional Descriptions into Database
	mysql -umspence -ppassword < $XTRA_DIR/loaddescr.mysql

	echo "1.f: Update Asset fields"
	# Update Differences from Assets Table in Database
	mysql -umspence -ppassword < $XTRA_DIR/updtasset.mysql

	mv "$j" "$j.done"
	echo "1.g: Report"
	echo "-----------------------------------------"
	echo -n "Records in file: "; grep -c "^" "$j.done"
	echo -n "Assets updated: "; grep -c "^" $WORK_DIR/asset.new
	echo -n "New Models: "; grep -c "^" $WORK_DIR/model.new
	echo -n "New Purchases: "; grep -c "^" $WORK_DIR/purch.new
	echo -n "New Descriptions: "; grep -c "^" $WORK_DIR/descr.new
	echo "-----------------------------------------"

done
