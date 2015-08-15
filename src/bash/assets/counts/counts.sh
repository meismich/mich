#!/bin/bash

clear

echo "PRINTER MONITOR SCRIPT"
echo "==============================================================================="
echo
echo "1- Fetching Device Type Counts from Database"
mysql -umspence -ppassword < counts.mysql > counts.tab

echo "FINAL- Emailing list to Michael"
mailx -s "Device Type Counts" \
	-r asset.list@ittools.apeagers.com.au \
	-a ./counts.tab \
	mspence@apeagers.com.au < counts.body

echo
echo "==============================================================================="
echo "DONE"
echo
