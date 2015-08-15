#!/bin/bash

echo "Michael Mail Server email address tester"
echo "========================================"
echo "Testing $1@$2"
echo

# Query the net for the mail server
m=`nslookup -q=mx $2 | grep "$2" | head -1 | sed 's/.* \([^ ]*\)\.$/\1/g'`

# Telnet to the mail server (port 25) and run command file
echo 
echo "Mail server found as $m"
echo

# Create Telnet command file
#echo "OPEN $m 25" > ehlo.mic
echo "EHLO test.com" > ehlo.mic
echo "MAIL FROM:admin@test.com" >> ehlo.mic
echo "RCPT TO:$1@$2" >> ehlo.mic
echo "CLOSE"
echo "QUIT" >> ehlo.mic

telnet $m 25 < wait | cat ehlo.mic > ehlo.out

more ehlo.out
