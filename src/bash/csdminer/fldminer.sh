#!/bin/bash

# Fetch the search page source
/usr/bin/wget -odminer.log -Ofld.1st http://www.carsales.com.au/all-cars/search.aspx?

wait

# Filter the source for the options (keep the selects) ... and get rid of any div data.... and remove crappy var names
grep -e "<\/*select" -e "<option" fld.1st | sed 's/<div[^>]*>//g' | sed 's/<\/div>//g' | sed 's/ctl06\$.*\$//g' > fld.2nd

echo "<html><body><form action=''>" > fld.html
cat fld.2nd >> fld.html
echo "</form></body></html>" >> fld.html

