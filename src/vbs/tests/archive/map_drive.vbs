'
' File:		map_drive.vbs
' Author:	Michael Spence
' Date:		2009-06-12
' Version:	0.2
'
' Purpose:
' Map Network drives based on group membership
'
' Future:
' Create File with an array of the groups, drives and paths

Option Explicit

'Const as_groups(3,2) =  ( ("group name", "T"), ("group 2 name", "R"))

dim o_net, o_adinfo, o_ldap, o_sh
dim c_grps
dim s_drive, s_path

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

' For each group in the collection....
for each s in c_grps
	' ... Fetch the CN name
	t = LCase(s)
	i = instr(t, "cn=")
	if i <= 0 then exit for
	j = instr(i, t, ",")
	r = mid(t, i, j-i)
	'msgbox LCase(r)

	' ... and based on CN, where do we map to
	select case r
		case "cn=southside ford folder redirection group"
			s_drive = "T:"
			s_path = "\\gabbafs\ssf.data"
		case "cn=frg.sst.service"
			s_drive = "T:"
			s_path = "\\gabbafs\sst.data"
		case "cn=frg.sst.sales"
			s_drive = "T:"
			s_path = "\\sstfs\sst.data"
	end select
next

msgbox s_drive & vbcrlf & s_path

' Do the actual map
set o_net = CreateObject("WScript.Network")
o_net.MapNetworkDrive s_drive, s_path
