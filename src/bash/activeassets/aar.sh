#!/usr/bin/bash

did=`date +%Y-%m-%d`

mysql -umspence -ppassword < aar.mysql | sed 's/\t/,/g' > Active_Assets-${did}.csv

mailx -s "Active Assets - ${did}" \
	-r asset.list@ittools.apeagers.com.au \
	-a Active_Assets-${did}.csv \
	spearce@apeagers.com.au < aar.body

