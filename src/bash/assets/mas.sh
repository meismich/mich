#!/bin/bash
#
# File:		mas.sh
# Author:	Michael Spence
# Date:		2009-08-03
# Version:	1.0
#
# Purpose:
# Mail Asset Summary to Recipient
#
# Usage:
# mas.sh <user id> <date id>
#

uid=$1
did=$2

mailx -s "Cost Centre Charges (SUMMARY) - ${did}" \
	-r asset.list@ittools.apeagers.com.au \
	-a /var/www/htdocs/asset/data/output/${did}/${did}-SUMMARY.csv \
	${uid} < mar.body
