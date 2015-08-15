#
# FILE:		import_user_alias.ps1
# AUTHOR:	Michael Spence 
# DATE:		2013-06-18
#
# PURPOSE:	Bulk add additional aliases to users in 365 from file
#
# USAGE:
#	1. configure alias csv file:
#
#		First Row:
#			SMTPAddress,AliasAddresses
#		Following Rows:
#			user@domain.com,alias@domain.com;alias2@domain.com;alias3@domain.blah
#
#		SMTPAddress is a field with one element, the users email address
#		AliasAddresses is a field with multiple elements separated by ";", each sub element an email address
#
#	2. Copy the alias file to C:\tmp\alias.csv
#	3. Start Powershell and log into 365 with admin creds
#	4. Copy and Run the following code into Powershell
#	5. Note down failures and find reason for failure


import-csv "c:\tmp\alias.csv" | foreach { 

	$sa=$_.smtpaddress
	$aa=$_.aliasaddresses

	write-host "Mailbox > " $sa " <"

	$err=0
	try {
		$temp = get-mailbox -identity $sa -erroraction stop
		}
	catch {
		$err=1
		write-host "... Not Found > " $sa " <" -foregroundcolor red
		}

	if ($err -eq 0) {
		$aaa=@()

		$i=$aa.indexof(";")
		while ( $i -gt -1 ) {
			$an = $aa.substring(0,$i)
			$aa = $aa.substring($i+1)
			$aaa += $an.trimstart(" ")
			
			$i=$aa.indexof(";")
			}
		$aaa += $aa.trimstart(" ")

		$nea = @()
		$tea = $temp.emailaddresses
	
		foreach ($c in $tea) {
			$err=0
			if ($c.substring(0,5) -eq "STMP:") { $err=1 }
			if ($c.substring(0,5) -eq "stmp:") { $err=1 }
	
			
			if ($err -eq 0) { $nea += $c }
			}
	
	
		foreach ($ea in $aaa) {
			$e = "smtp:" + $ea

			$err=1
			try { get-mailcontact -identity $e -erroraction stop }
			catch { $err=0 }
			if ($err -eq 1) { Write-Host "... alias is Contact-Card: " $e -foregroundcolor red }

			foreach ($c in $nea) {
				if ($c -ne $null) {
					if ($e.substring(5) -eq $c.substring(5)) { 
						$err=1 
						write-host "... alias already present: " $e -foregroundcolor red
						}
					}
				}

			if ($err -eq 0) { $nea += $e }
			}
	
		write-host "Aliases ARE:"
		foreach ($c in $nea) { $c }
		write-host "."	
	
		set-mailbox -identity $sa -emailaddresses $nea
		}
	}

