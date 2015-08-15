#!/bin/bash

rm a.out
touch a.out
for i in $( < inusedomains.txt ); do
j=$( nslookup -q=mx $i 139.130.4.4 | grep "mail exchanger" | head -1 | sed 's/^.*mail exchanger = [0-9]*//' )
echo "$i,$j"
echo "$i,$j" >> a.out
done
