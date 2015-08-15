function Login_365() 
	{
	Clear-Host
	
	Write-Host "Welcome to the APEagers Office 365 Helper PowerShell App"
	Write-Host "========================================================"
	Write-Host
	Write-Host "Please enter your Administrator Details:"
	write-Host
	$un = Read-Host  -prompt "UserName"
	$pw = Read-Host  -prompt "PassWord" -assecurestring
	
	if ( ($un -eq "") -or ($pw -eq "")) 
		{
		Write-Host "Please supply NON-BLANK entries"
		read-host
		exit
		}
	
	Write-Host "Importing Required Modules" -foregroundcolor green
	import-module msonline
	
	Write-Host "Connecting Microsoft Online Services" -foregroundcolor green
	# connect to MSOL
	$c = New-Object System.Management.Automation.PSCredential $un,$pw
	
	Connect-MsolService -Credential $c
	
	Write-Host "Creating a new Session" -foregroundcolor green
	$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $c -Authentication Basic -AllowRedirect
	Write-Host "And finally Importing the Session" -foregroundcolor green
	Import-PSSession $s
	}
    
login_365

