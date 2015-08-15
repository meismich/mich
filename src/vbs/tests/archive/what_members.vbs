Option Explicit

dim o_sh
dim o_rdse, o_grp, o_obj
dim s_cont, s_dom
dim a_membs, s_memb
dim s_result
dim o_fso, o_file

' Register necessary DLL
set o_sh = CreateObject("WScript.Shell")
o_sh.Run "regsvr32.exe c:\windows\system32\activeds.dll /s"

s_cont = InputBox("Which OU?")
s_cont = "ou=" & s_cont & ","
set o_rdse = GetObject("LDAP://RootDSE")
s_dom = o_rdse.Get("DefaultNamingContext")

set o_grp = GetObject("LDAP://" & s_cont & s_dom)

s_result = "[" & mid(o_grp.Name, 4) & "]" & vbcrlf & vbcrlf

s_result = s_result &  GroupUsers(o_grp, "")


set o_fso = CreateObject("Scripting.FileSystemObject")

set o_file = o_fso.OpenTextFile ("c:\tmp\" & s_cont & ".txt"  , 2, True)
o_file.WriteLine(s_result)
o_file.Close

Function GroupUsers(og, pad)
	Dim sr
	Dim oo
	dim s, i

	sr = ""
	for each oo in og
		select case oo.class 
			case "user"
				s = lcase(oo.Name)
				i = instr(s, "cn=")
				if i > 0 then
					sr = sr & pad & mid(oo.Name, i+3) & vbcrlf
				end if
			case "organizationalUnit"
				sr = sr & pad & "-->" & "[" & mid(oo.Name, 4) & "]" & vbcrlf & GroupUsers(oo, pad & "   ") & pad & "<--" & vbcrlf
			case else
				'msgbox oo.class
		end select
	next
	if sr = "" then
		GroupUsers = ""
	else 
		GroupUsers = sr
	end if
end function
