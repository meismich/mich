Clear-Host

Write-Host "Welcome to the APEagers Office 365 Helper PowerShell App"
Write-Host "========================================================"
Write-Host
Write-Host "Please enter your Administrator Details:"
write-Host
$un = Read-Host  -prompt "UserName"
$pw = Read-Host  -prompt "PassWord" -assecurestring

if ( ($un -eq "") or ($pw -eq "")) then
	{
	Write-Host "Please supply NON-BLANK entries"
	read-host
	exit
	}

# connect to MSOL
$c = New-Object System.Management.Automation.PSCredential $un,$pw

Connect-MsolService -Credential $c

$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $c -Authentication Basic -AllowRedirect
Import-PSSession $s

# Start Menu Section

$exit = "False"
DoMenu

# while menu doesn't return not exit
while ($exit -eq "True") 
	{
	Clear-Host
	DoMenu
	}

# Unconnect from MSOL

Remove-PSSession $s




Function DoMenu ()
	{
	# Display the Menu Items
	Write-Host "          APEagers 365 Menu"
	Write-Host "          ====================="
	Write-Host
	Write-Host "          [1] Reset Password"
	Write-Host "          [2] Forward Email To"
	Write-Host "          [3] Set Primary Addr"
	Write-Host "          [4] Set Send As"
	Write-Host "          [5] Set Mailbox Perms"
	Write-Host "          [6] Unset Permissions"
	Write-Host "          [X] Exit"
	Write-Host
	$sel = Read-Host -prompt "Enter Selection"

	switch ($sel) 
		{
		1 { ResetPassword }
		2 { ForwardEmail }
		3 { SetPrimary }
		4 { SetSendAs }
		5 { SetMboxPerms }
		6 { UsetMboxPerms }
		X { 
			Write-Host "Thanks for using the APEagers Office 365 Helper Powershell App"
			$exit = "True"
			}
		}

	}

function RestPassword ()
	{
	Clear-Host
	Write-Host "Reset User's Password"
	Write-Host "========================"
	Write-Host
	$ac = Read-Host "Please enter account descriptor (such as email address)"
	set-msoluserpassword -UserPrincipalName $ac -NewPassword "pa$$w0rd" -ForceChangePassword "no"
	}


function ForwardEmail ()
	{
	Clear-Host
	Write-Host "Forward User's Email"
	Write-Host "======================="
	Write-Host
	$ac = Read-Host "Please enter the account descriptor (such as email address)"
	$to = Read-Host "Enter the destination be forwarded to"

	if (( $ac -ne "") -and ( $to -ne "")) {
		set-mailbox -identity $ac -forwardingsmtpaddress $to -DeliverToMailboxAndForward "yes"
		Write-Host 
		Write-Host ".... account configured as follows"
		write-host
		get-mailbox -identity $ac | select-object identity, forwardingsmtpaddress, delivertomailboxandforward
		}
	else {
		write-host "Please enter NON-BLANK fields"
		}

	read-host
	}

Function SetPrimary 
	{

	}

function SetSendAs 
	{
	Clear-Host
	Write-Host "Set SendAs Permission"
	Write-Host "========================"
	Write-Host
	$sa = Read-Host "Who is going to be sent as"

	$su = Read-Host "Enter to user who will send as"
	add-mailboxpermission -identity $to -user $fr -accessrights fullaccess -inheritance all

	while ($su -ne "Done") {
		$su = Read-Host "Enter to user who will send as [Done = end loop]"
		if ($su -ne "Done) {
			add-recipientpermission -identity $sa -trustee $su -accessrights SendAs
			}
		}

	Write-Host "The mailbox permissions for $to are"
	write-host
	get-mailboxpermission -identity $to
	read-host
	}

function SetMboxPerms
	{
	Clear-Host
	Write-Host "Set Mailbox Permission"
	Write-Host "========================="
	Write-Host
	$to = Read-Host "To which mailbox are permissions required "

	$fr = Read-Host "From which mailbox are permissions being granted "
	add-mailboxpermission -identity $to -user $fr -accessrights fullaccess -inheritance all

	while ($fr -ne "Done") {
		$fr = Read-Host "From which mailbox are permissions being granted [Done = end loop] "
		if  ($fr -ne "Done") {
			add-mailboxpermission -identity $to -user $fr -accessrights fullaccess -inheritance all
			}
		}

	Write-Host "The mailbox permissions for $to are"
	write-host
	get-mailboxpermission -identity $to
	read-host
	}

Function UsetMboxPerms 
	{

	}

