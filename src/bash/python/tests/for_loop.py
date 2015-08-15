#!/usr/bin/python

import math

print("Start\n\n")
for i in range(0,10):
	j = i * i
	k = math.sqrt(j)
	print "%3d\t%5d\t%3d <---" % (i, j, k)

print("\nEnd\n")
