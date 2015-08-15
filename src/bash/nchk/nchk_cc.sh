#!/bin/bash
#
# File:		nchk.sh
# Date:		2010-07-xx
# Author:	Michael Spence
#
# Purpose:
# To record the entire used IP addresses at the datacentre.  
#

nmap -sP 10.23.1.0/24   > out/out_cca.02.txt

