#!/usr/bin/tclsh
#
#

global forever
global msg_count
set msg_count 0

proc test_server {port} {
	global conn
	set conn(server) [socket -server init_connect $port]
	puts "Main socket $conn(server)"
}

proc init_connect {sock addr port} {
	global conn
	puts "Accept $sock from $addr port $port"
	set conn(client,$sock) [list $addr $port]
	fconfigure $sock -buffering line
	fileevent $sock readable [list client_input $sock]
}

proc client_input {sock} {
	global conn
	global msg_count
	global forever
	if {[eof $sock] || [catch {gets $sock line}]} {
		close $sock
		puts "Close $conn(client,$sock)"
		unset conn(client,$sock)
	} else {
		if {[string compare $line "quit"] == 0} {
			close $conn(server)
			set forever 1
		}
		incr msg_count
		puts $line
		puts $sock $msg_count
	}
}

test_server 2999
vwait forever
