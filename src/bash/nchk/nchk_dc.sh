#!/bin/bash
#
# File:		nchk.sh
# Date:		2010-07-xx
# Author:	Michael Spence
#
# Purpose:
# To record the entire used IP addresses at the datacentre.  
#

nmap -sP 10.1.1.0/24   > out/out.01.txt
nmap -sP 10.1.11.0/24  > out/out.11.txt
nmap -sP 10.1.0.0/24   > out/out.00.txt
nmap -sP 10.1.254.0/24 > out/out.254.txt

