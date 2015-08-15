:%s/^  *$//
:g/^$/d
:1,/Usage Charges/d
:/Service Summary/,$d
:1,3d
:$,$d
:%s/,//g
:%s/   */,/g
:g/^,[^,]*$/d
:wq
