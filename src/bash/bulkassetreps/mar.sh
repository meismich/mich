#!/bin/bash
#
# File:		mar.sh
# Author:	Michael Spence
# Date:		2009-05-20
# Version:	1.0
#
# Purpose:
# Mail Asset report of a specific cost centre to a specified accountant.
#
# Usage:
# mar.sh <user id> <report id> <date id>
#

uid=$1
rid=$2
did=$3

mailx -s "Cost Centre Charges - ${did}" \
	-r asset.list@ittools.apeagers.com.au \
	-a /var/www/htdocs/asset/data/output/${did}/${did}-${rid}-*RENTAL.csv \
	-a /var/www/htdocs/asset/data/output/${did}/${did}-${rid}-*SERVICE.csv \
	${uid} < mar.body
