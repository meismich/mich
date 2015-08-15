#!/bin/bash
#
# File:		nchk.sh
# Date:		2010-07-xx
# Author:	Michael Spence
#
# Purpose:
# To record the entire used IP addresses at the datacentre.  
#

nmap -sP -O 172.17.104.0/22   > out/out_klo.01.txt

