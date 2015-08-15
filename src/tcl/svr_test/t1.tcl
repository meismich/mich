#!/usr/bin/tclsh
#
#

set listensock [socket -server Accept 2999]
proc Accept {newsock ipaddr inport} {

	puts "Accepted $newsock from $ipaddr on port $inport"

}
vwait forever
