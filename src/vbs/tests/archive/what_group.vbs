Option Explicit

'Const as_groups(3,2) =  ( ("group name", "T"), ("group 2 name", "R"))

dim o_net, o_adinfo, o_ldap, o_sh
dim c_grps

dim i, j
dim s, t, r

' Register necessary DLL
set o_sh = CreateObject("WScript.Shell")
o_sh.Run "regsvr32.exe c:\windows\system32\activeds.dll /s"

' Get User Details
set o_net = CreateObject("WScript.Network")
set o_adinfo = CreateObject("ADSystemInfo")
set o_ldap = GetObject("LDAP://" & o_adinfo.UserName)

' Get the Collection of MemberOf
if TypeName(o_ldap.MemberOf) = "String" then
	c_grps = array(o_ldap.MemberOf, "")
else
	c_grps = o_ldap.MemberOf
end if

for each s in c_grps
	t = LCase(s)
	i = instr(t, "cn=")
	'if i <= 0 then exit for
	j = instr(i, t, ",")
	r = mid(t, i, j-i)
	msgbox LCase(r)
next
