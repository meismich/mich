#!/bin/ksh

r="tammy@carzoos.com.au"
s="timmy@carzoos.com.au"
t="tommy@carzoos.com.au"

for (( i=0; $i < 50; i++)) ; do
	fortune > body.txt

	mailx -s "Fortune $i" \
		-r mspence@apeagers.com.au \
		$r < body.txt
	mailx -s "Fortune $i" \
		-r mspence@apeagers.com.au \
		$s < body.txt
	mailx -s "Fortune $i" \
		-r mspence@apeagers.com.au \
		$t < body.txt

done
