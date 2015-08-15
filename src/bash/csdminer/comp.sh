#!/bin/bash

rm c.out

for i in `ls b150*`; do

	echo $i

	vim -s ex.script $i > /dev/null 2> /dev/null

	cat a.out >> c.out

done
