dim o_wmiu

set o_wmiu = getobject("winmgmts:{impersonationlevel=impersonate}!" _
    & "/root/cimv2:Win32_UserAccount.Domain='apeagers'" _
    & ",Name='mspence'")

msgbox o_wmiu.sid


set o_wmiu = getobject("winmgmts:{impersonationlevel=impersonate}!" _
    & "/root/cimv2:Win32_UserAccount.Domain='chromo1'" _
    & ",Name='user'")

msgbox o_wmiu.sid
