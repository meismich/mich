# This is a PowerShell script to connect user to MS365 system
$c = Get-Credential

Connect-MsolService -Credential $c

$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $c -Authentication Basic -AllowRedirect

Import-PSSession $s
