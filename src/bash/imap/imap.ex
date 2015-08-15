:1,$j
:%s/<host /\r<host /g
:%s/<runstat/\r<runstat/g
:%s/<taskprog/\r<taskprog/g
:%s/<!-- /\r<!-- /g
:%g/^<[^h]/d
:%s/hostname/borkname/g
:%s/<\/*host *[^>]*>//g
:%s/<\/*borknames>//g
:%s/<borknames *\/>/<borkname name="NO NAME"\/>/
:%s/<ports.*\/ports>//g
:%s/<distance[^>]*>//g
:%s/<portused[^>]*>//g
:%s/$/<osclass osfamily="BORKED OS"\/>/
:%s/osclass/OSCLASS/
:%s/<os> <\/os>/<os> <OSCLASS osfamily="UNKNOWN OS"\/> <\/os>/
:%s/<\/*os>//g
:%s/<osclass[^>]*>//g
:%s/<osmatch[^>]*>//g
:%s/<times[^>]*>//g
:%s/> *</></g
:%s/<status state="\([^"]*\)"[^>]*>/###\1\t###/
:%s/<address addr="\([^"]*\)"[^>]*>/###\1\t###/
:%s/<borkname name="\([^"]*\)"[^>]*>/###\1\t###/
:%s/<OSCLASS .*osfamily="\([^"]*\)"[^>]*>/###\1\t###/
:%s/###//g
:wq

