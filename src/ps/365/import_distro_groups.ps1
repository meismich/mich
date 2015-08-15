#
# FILE:		import_distro_groups.ps1
# AUTHOR:	Michael Spence 
# DATE:		2013-06-18
#
# PURPOSE:	Bulk create distribution groups and add members in 365 from file
#
# USAGE:
#	1. configure distro group csv file:
#
#		First Row:
#			SMTPAddress,DisplayName,Members
#		Following Rows:
#			group@domain.com,Group Name,member1@domain.com;member2@domain.com;member3@domain.blah
#
#		SMTPAddress is a field with one element, the group's email address
#		DisplayName is a field with one element, the Group's Display Name (no comma's allowed)
#		Members is a field with multiple elements separated by ";", each sub element a members' email address
#
#	2. Copy the alias file to C:\tmp\distros.csv
#	3. Start Powershell and log into 365 with admin creds
#	4. Copy and Run the following code into Powershell
#	5. Note down failures and find reason for failure
#

write-host " ###  #  # #  #     ##### #   # ###  ##  #### # # # "
write-host " #  # #  # ## #       #   #   #  #  #  # #    # # # "
write-host " ###  #  # ## #       #   # # #  #  #    ###  # # # "
write-host " #  # #  # # ##       #   # # #  #  #  # #          "
write-host " #  #  ##  #  #       #    # #  ###  ##  #### # # # "

import-csv "c:\tmp\distro.csv" | foreach { 

	$dn=$_.displayname
	$gn=$_.smtpaddress

	$err=0
	try { 
		new-distributiongroup -name $dn -primarysmtpaddress $gn -Type "distribution" -erroraction stop
		}
	catch { 
		write-host "FAILED to Create Distro Group > " $dn " <" -foregroundcolor red 
		$err=1
		}
	finally {
		if ( $err -eq 0 ) { write-host "Created Distro Group > " $dn " < with smtp = " $gn }
		}
			
	if ($err -eq 1) {

		$mem=$_.members

		$i=$mem.indexof(";")

		write-host $i

		while ( $i -gt -1 ) {
			$a = $mem.substring(0, $i)
			$mem = $mem.substring($i+1)

			try { 
				add-distributiongroupmember -identity $gn -member $a.trimstart(" ") -erroraction stop
				}
			catch { 
				write-host "... FAILED to add > " $a " <" -foregroundcolor red 
				$err=1
				}
			finally {
				if ( $err -eq 0 ) { write-host "... added > " $a " <" }
				}
			$i=$mem.indexof(";")
			}

		try {
			add-distributiongroupmember -identity $gn -member $mem.trimstart(" ") -erroraction stop
			}
		catch { 
			write-host "... FAILED to add > " $mem " <" -foregroundcolor red 
			$err=1
			}
		finally {
			if ( $err -eq 0 ) { write-host "... added > " $mem " <" }
			}	
		}

	Write-host "."
	}
