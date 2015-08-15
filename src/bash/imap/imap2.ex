:1,$j
:%s/<host /\r<host/g
:%s/<\/host>/<\/host>\r/g
:%s/^ *//
:%g/^<[^h][^o]/d
:%g/^ *$/d
:%s/<ports>.*<\/ports>//
:%s/<script id="nbstat" output=".*NetBIOS MAC: \([0-9a-e:]*\)[^>]*>/<MAC mac="\1"\/>/
:%s/<script id="smb-os-discovery" output="\([^&]*\)&[^>]**>/<OS os="\1"\/>/
:%s/hostnames/borknames/g
:%s/hostname/HOSTNAME/
:%s/<borknames \/>/<HOSTNAME name="UNKNOWN">/
:%s/<\/*borknames>//g
:%s/<\/*hostscript>//g
:%s/<times [^>]*>//g
:%s/<\/host>//
