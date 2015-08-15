#!/bin/bash

carmake=$1

j=0
k=150

for (( i=0; i < 300; i=`expr $i + 1`)) ; do
	echo $i $j

	csdminer2.sh $j $carmake $k
	
	wait

	j=`expr $j + $k`
done
