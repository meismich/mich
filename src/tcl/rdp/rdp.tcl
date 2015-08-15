#!/usr/bin/wish

set dat ""

proc start_rdp {} {
	global dat
	global domain
	exec rdesktop -x l -n a.${domain} -g1024x768 -u${domain}\\msadmin "${dat}.${domain}" 2> ~/data/junk/rpd.err > ~/data/junk/rpd.err &
	}

set lab "RDP to "
frame .rdp
label .rdp.caption -textvariable lab -padx 2m -pady 1m
entry .rdp.ent -textvariable dat
grid .rdp.caption .rdp.ent 
grid .rdp

set domain "apeagers"
frame .dom
radiobutton .dom.def -value "apeagers.com.au" -text "QLD" -variable domain -width 4
radiobutton .dom.klo -value "ape.local" -text "KLO" -variable domain -width 4
radiobutton .dom.bbu -value "anbbdom1.com.au" -text "BBU" -variable domain -width 4
grid .dom.def .dom.klo .dom.bbu
grid .dom


bind . <KeyPress> {
	set key %k
	if { $key == 36 } { start_rdp }
	}

