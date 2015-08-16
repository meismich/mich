:1,/^ *Balance/d
:/^ *Total/,$d
:%s/,//g
:%s/   */,/g
:%s/,[^,]*$//
:wq
