:g/^ *Rental/s/^ */###/
:g/Services & equipment/s/^ */##@/
:v/^##/d
:g/^ *$/d
:%s/,//g
:%s/^##@....... *S/S/
:%s/   */,/g
:%s/^Rental,[^,]*,/Rental,/
:%s/^###//
:%s/,\([0-9][0-9]*\.[0-9][0-9]\)cr/,-\1/g
:wq
