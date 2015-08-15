#!/bin/bash

# Move fetched emails to HERE
#mv /var/spool/mail/mspence tmp/new.mail

# Separate emails into individual files
grep -n "^From " tmp/new.mail | sed "s/:.*$//" > tmp/start.tmp

d=$( date +%Y%m$d%H%M )
k=0

for i in $( cat tmp/start.tmp ); do
	if [[ $i -gt 1 ]]; then
		tail +$j tmp/new.mail | head -$(( $i - $j )) > tmp/mail_${d}_${k}.tmp
		
		k=$(( $k + 1 ))
	fi
	j=$i
done

tail +$j tmp/new.mail > tmp/mail_${d}_${k}.tmp

rm out/faults.txt
rm out/checked.txt

# Process Each Email
for i in $( ls tmp/mail_${d}* ); do
	# Verify Subject is "vRanger Backup"
	s=$( grep "^Subject" $i | tail -1 )
	v=$( echo $s | sed "s/^Subject: \(vRanger Backup\).*$/\1/" )

	if [ "x$v" == "xvRanger Backup" ]; then
		j=$( tail +$(( 2 + $( grep -n "X-MS-Exchange-Organization-AuthAs:" $i | sed "s/^\([0-9]*\):.*$/\1/" ) )) $i | base64 --decode )
		# Get ServerName, JobName, JobStatus
		sn=$( echo $j | sed "s/^.*<strong>Host Name<\/strong>: \([^<]*\)<br>.*$/\1/" )
		jn=$( echo $j | sed "s/^.*<strong>Job Name<\/strong>: \([^<]*\)<br>.*$/\1/" )
		echo $j | sed "s/<strong>Result<\/strong>: \([^<]*\)<br>/\n\1/g" | tail +2 | sed "s/<.*$//" > tmp/a.tmp

		echo "====================================================="
		echo $s
		#echo "--> $j <--"
		echo "----- $sn"
		echo "----- $jn"
		cat tmp/a.tmp | sed "s/^/-------/"

		if [ "x$( cat tmp/a.tmp | head -1 )" == "xCompleted" ]; then
			echo "JOB successfully completed"
			n=$( tail +2 tmp/a.tmp | grep -c "Successful" )
			echo "--- $n TASKS completed successfully"
			n=$( tail +2 tmp/a.tmp | grep -c "Failed" )
			echo "--- $n TASKS failed"
			if [[ $n -gt 0 ]]; then
				echo "I'm going to flag \"$sn|$jn\" server-job as a fault"
				echo "$sn|$jn" >> out/faults.txt 
			fi
		else
			echo "*** ERROR *** JOB failed"
			echo "I'm going to flag \"$sn|$jn\" server-job as a fault"
			echo "$sn|$jn" >> out/faults.txt 
		fi

		echo "$sn|$jn" | sed "s/ /###/g" >> out/checked.txt
	fi

	#mv $i $i.done
done

echo "### SERVER-JOB CHECK ###"

for i in $( cat etc/server_jobs.txt | sed "s/ /###/g" ); do
	j=$( grep -c $i out/checked.txt )

	if [[ $j -lt 1 ]]; then
		echo "I'm flagging \"$i\" server-job as a fault"
		echo $i >> out/faults.txt
	fi
done

echo "### FAULTS REPORT ###"
i=$( grep -c "^" out/faults.txt )

if [[ $i -gt 0 ]]; then
	echo "I'm going to email the faults to ServiceDesk"
fi
