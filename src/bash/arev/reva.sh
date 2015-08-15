#!/bin/ksh


mysql -umspence -ppassword < etc/active_assets_with_i8.sql | sed 's/\t/,/g' > out/with_i8.csv
mysql -umspence -ppassword < etc/active_assets_wout_i8.sql | sed 's/\t/,/g' | sed 's/$/,NA,NA,13,NA/' > out/wout_i8.csv
mysql -umspence -ppassword < etc/notact_assets_with_i8.sql | sed 's/\t/,/g' > out/nawi_i8.csv

cp out/with_i8.csv out/reva.csv
tail +2 out/wout_i8.csv >> out/reva.csv
tail +2 out/nawi_i8.csv >> out/reva.csv

mailx -s "Asset Review - using Interog8" \
        -r asset.review@ittools.apeagers.com.au \
        -a out/reva.csv \
        mspence@apeagers.com.au < etc/mail.body

mailx -s "Asset Review - using Interog8" \
        -r asset.review@ittools.apeagers.com.au \
        -a out/reva.csv \
        mspence@apeagers.com.au < etc/mail.body

