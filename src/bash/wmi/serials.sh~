#!/bin/bash

WMIC_DIR=/home/mspence/tmp/wmi/wmi-1.3.14/Samba/source/bin


for i in $(< computers.txt ); do
	serial=$( wmic -U apeagers/msadmin%b0kirk07 //${i} "select SerialNumber from Win32_BIOS" | tail -1 | sed 's/^[^|]*|\([^|]*\)|.*$/\1/' | sed 's/.*ERROR.*$/ERROR/' )
	if [ "x$serial" == "xERROR" ]; then
		echo "IPAddress ${i} cannot be WMId"
	else
		csname=$( wmic -U apeagers/msadmin%b0kirk07 //${i} "select CSName from Win32_OperatingSystem" | tail -1 | sed 's/|.*$//' )

		echo "IPAddress ${i} is Machine ${csname} has Serial ${serial}"
	fi

done > report.txt

