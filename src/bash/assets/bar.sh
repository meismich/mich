#!/bin/bash
#
# File:		bar.sh
# Author:	Michael Spence
# Date:		2009-08-03
# Version:	0.2
#
# Purpose:
# To Bulk create the reports for the Asset List and mail to defined recipients
#
# Resources:
# bar.log - log file for wget to log functional results to
# bar.out - output file for wget to write HTML results to
# bar.wps - defines http requests to cause bulk creation
# bar.usr - defines recipients of the reports
# (format per line: <user email address>,<report number> NO SPACES! 
#   eg. mspence@apeagers.com.au,209B)
#
# mar.sh - script for mailing reports, requires user, report number and date
# mas.sh - script for mailing summary, requires user and date
#

cd /home/mspence/src/bulkassetreps

# Force LAMP to "Generate Bulk Reports"
/usr/bin/wget -obar.log -Obar.out -ibar.wps

wait

# Generate Date String
d=`date +%Y-%m-%d`

# Process the users and send files to them
for i in `cat bar.usr`; do
	j=`echo $i | sed 's/^\([^,]*\),.*$/\1/'`
	k=`echo $i | sed 's/^[^,]*,\(.*\)$/\1/'`

	mar.sh $j $k $d
done

mas.sh mspence@apeagers.com.au $d
mas.sh drowbotham@apeagers.com.au $d
mas.sh adauramanzi@apeagers.com.au $d
