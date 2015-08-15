#!/usr/bin/bash
#
# FILE:		imap.sh
# DATE:		2011-03-28
# AUTHOR:	Michael Spence
#
# PURPOSE:
# Map a given network range
#
# USAGE:
#	imap.sh <network range>
# e.g.
#	imap.sh 10.1.1.0/24
#

nmap -sN -O -oX imap.1st $1 > imap.junk
cp imap.1st imap.copy
vim -s imap.ex imap.1st
