#!/bin/ksh

# Process User Data File

ETCDIR=/home/mspence/dev/Tipt/etc
OUTDIR=/home/mspence/dev/Tipt/out
DATDIR=/home/mspence/dev/Tipt/dat
TMPDIR=/home/mspence/dev/Tipt/tmp

# Read in Lines from Pattern Match file
# Each line has 0-9 options
# Each line referenced as line number * 10
# ... so option is line number * 10 + option number
n=0
while read s; do
	i=0
	b=$s
	while [[ "x$b" != "x" ]]; do
		a[$(( $n * 10 + $i))]=$( echo $b | sed 's/!!!.*$//' )
		b=$( echo $b | sed 's/^[^!]*!!!//' )	
		i=$(( $i + 1 ))
	done
	n=$(( $n + 1 ))
done < $ETCDIR/proc_user_info.etc

# For debug print the first 6 options from Pattern Match file
for (( j=0; j<$n; j++)); do
	for (( i=0; i<6; i++)); do
		echo -n "${a[$(($j*10+$i))]},"
	done	
	echo
done

# For the time being set a constant file to look at
file=Jake.dat

# Preproces file
ppf=$OUTDIR/ppf.tmp
pps=$OUTDIR/pps.tmp

# First pass.... 
# ... remove all but <input ..> <select ..> <option ..> tags

grep -i "<\(input\|select\|option\|\/select\)" Jake.dat \
	| sed   -e "s/</\n</g" \
		-e "s/ *>/>/g" \
	| sed   -e "s/SELECTED/selected/" \
		-e "s/SELECT/select/" \
		-e "s/OPTION/option/" \
		-e "s/NAME/name/" \
		-e "s/VALUE/value/" \
		-e "s/INPUT/input/" \
	| sed   -e "s/&nbsp;/ /g" \
		-e "s/<\/td>//g" \
		-e "s/<\/TD>//g" \
		-e "s/<td[^>*]>//g" \
		-e "s/<TD[^>]*>//g" \
		-e "s/^ *//g" \
	| grep "^<" > Jake.ppf

# Second pass.... 
# ... prepend all <option ..> tags with id of containing <select ..>

i=$( grep -n -h "<select" Jake.ppf | sed "s/:.*$//" )

rm Jake.pps
j=1
for k in $i; do
	head -$k Jake.ppf | tail +$j >> Jake.pps
	s=$( tail -1 Jake.pps \
			| grep "<select" \
			| grep "name=" \
			| sed "s/^.*name=[\'\"]\([^\'\"]*\)[\'\"].*$/\1/" )
	l=$( tail +$k Jake.ppf \
			| grep -n -h "</select" \
			| head -1 \
			| sed "s/:.*$//" )
	tail +$k Jake.ppf \
			| head -$l \
			| grep "<option" \
			| sed "s/<option/<option of=\"$s\"/" >> Jake.pps
	echo "</select>" >> Jake.pps
	j=$(( $k + $l ))
done
tail +$j Jake.ppf >> Jake.pps
diff Jake.ppf Jake.pps


echo
echo "FILE: <$file> ============================"

for (( i=0; i<$n; i++ )); do
	if [[ "x${a[$(( $i * 10 + 4 ))]}" != "x0" ]]; then
		d=$( grep "${a[$(( $i * 10 + 1))]}" $DATDIR/$file | head -${a[$(( $i * 10 + 4))]} | sed "s/${a[$(( $i * 10 + 2))]}/${a[$(( $i * 10 + 3))]}/" )
		c=""
		for e in $d; do
			if [[ "x$c" == "x" ]]; then c=$e; else c="$c, $e"; fi
		done
	else
		d=$( grep "${a[$(( $i * 10 + 1))]}" $DATDIR/$file | sed "s/${a[$(( $i * 10 + 2))]}/${a[$(( $i * 10 + 3))]}/" )
		c=""
		for e in $d; do
			if [[ "x$c" == "x" ]]; then c=$e; else c="$c, $e"; fi
		done
	fi

	echo "${a[$(( $i * 10 ))]}$c"
	if [[ "${a[$(( $i * 10 + 5))]}" != "0" ]]; then
		i=${a[$(( $i * 10 + 5))]}
	fi
done
