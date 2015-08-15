Option Explicit

dim o_net, o_adinfo, o_sh

' Register necessary DLL
set o_sh = CreateObject("WScript.Shell")
o_sh.Run "regsvr32.exe c:\windows\system32\activeds.dll /s"

' Get User Details
set o_net = CreateObject("WScript.Network")
set o_adinfo = CreateObject("ADSystemInfo")

ObjectDetails o_adinfo.UserName, 0

' Recursive function to fetch objects' group details
Sub ObjectDetails (s_obj, i_lvl)

	dim o_ldap
	dim c_grps

	dim i, j
	dim s, t, r

	' Display Group Details
	t = LCase(s_obj)
	i = instr(t, "cn=")
	if i <= 0 then exit sub
	j = instr(i, t, ",")
	r = mid(t, i, j-i)
	msgbox "Level " & i_lvl & vbcrlf & vbcrlf& t & vbcrlf & LCase(r)

	set o_ldap = GetObject("LDAP://" & s_obj)

	' Get the Collection of MemberOf
	if TypeName(o_ldap.MemberOf) = "Variant()" then
		c_grps = o_ldap.MemberOf
	else
		c_grps = array(o_ldap.MemberOf, "")
	end if

	for each s in c_grps

		ObjectDetails s, i_lvl + 1

	next

End Sub