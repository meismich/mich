$s_file = "C:\tmp\user_logintime.csv"

if (Test-Path $s_file) 
	{
	Remove-Item $s_file
	}

Write-Host "Fetching Mailbox Names..." -foregroundcolor Green
$o_mbxs = get-mailbox -resultsize unlimited | select UserPrincipalName

$n = $o_mbxs.count
$i = 0
Write-Host "Processing $n Mailboxes..." -foregroundcolor Green
foreach ($o_mbx in $o_mbxs) 
	{
	$i = $i + 1
	$j = 100 * $i / $n
	write-progress -activity "Processing..." -status "Progress->" -percentcomplete $j -currentoperation "Processing..."

	$s_user = $o_mbx.UserPrincipalName
	$o_mbxstats = get-mailboxstatistics -Identity $s_user 

	$s_date = $o_mbxstats.LastLogonTime

	"$s_user,$s_date" | Out-File $s_file -append -encoding utf8
	} 



