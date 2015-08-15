option explicit

dim o_ldap
dim o_adinfo

dim c_members
dim o_member

set o_adinfo = CreateObject("ADSystemInfo")
'set o_ldap = GetObject("LDAP://" & o_adinfo.Username)
set o_ldap = GetObject("LDAP://OU=Austral VolksWagen,DC=apeagers,DC=com,DC=au")

if TypeName(o_ldap.Members) = "Variant()" then
	c_members = o_ldap.Members
else
	c_members = array(o_ldap.Members, "")
end if

msgbox "Borko"

for each o_member in c_members
	msgbox o_member
next

