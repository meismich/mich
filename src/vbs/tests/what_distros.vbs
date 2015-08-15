Option Explicit

const K_indent = 0
const K_columns = 1
const k_headings = 0

const K_notes = 1
const K_wmail = 1
const K_hmail = 1
const K_wphone = 1
const K_wfax = 1
const K_hphone = 1
const K_hfax = 1
const K_mobile = 1
const K_ophone = 1
const K_waddr = 1
const K_haddr = 1
const K_org = 1
const K_pos = 1
const K_gmail = 1

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
set o_rdse = GetObject("LDAP://RootDSE")
s_dom = o_rdse.Get("DefaultNamingContext")

if s_cont = "" then
	set o_grp = GetObject("LDAP://" & s_dom)
	s_cont = "ROOT," & s_dom
	
else 
	s_cont = "ou=" & s_cont & ","
	set o_grp = GetObject("LDAP://" & s_cont & s_dom)
end if

s_result = "[[ Output Generated from %desktop%\dev\scripts\tests\what_distros.vbs ]]" & vbcrlf & _
		"[" & mid(o_grp.Name, 4) & "]" & vbcrlf & vbcrlf & _
		GroupUsers(o_grp, "")
		'"name,notes,workEmail,homeEmail,workPhone,workFax,homePhone,homeFax,mobile,otherPhone,workPostalAddress,homePostalAddress,organisationName,organisationTitle,googleTalkEmail" & vbcrlf & _

set o_fso = CreateObject("Scripting.FileSystemObject")

set o_file = o_fso.OpenTextFile ("c:\tmp\DISTRO_" & s_cont & ".txt"  , 2, True)
o_file.WriteLine(s_result)
o_file.Close

msgbox "DONE!"

Function GroupUsers(og, pad)
	Dim sr
	Dim oo
	dim s, i, e, a

	s = lcase(og.Name)
	if instr(s, "old accounts") > 0 or instr(s, "high security") > 0 then 
		msgbox "Exiting from " & og.Name
		exit function
	end if

	sr = ""
	for each oo in og
		select case oo.class 
			case "group"
				if oo.mail <> "" then
					'msgbox oo.Name
					sr = sr & mid(oo.Name, 4) & "," & oo.mail & vbcrlf
				end if
			case "user"
				's = lcase(oo.Name)
				'i = instr(s, "cn=")
				'if i > 0 then
					'if K_indent = 1 then sr = sr & pad
'
					'sr = sr & mid(oo.Name, i+3) 
'
					'if K_notes = 1 then sr = sr & ","
					'if K_wmail = 1 then sr = sr & "," & oo.Mail
					'if K_hmail = 1 then sr = sr & "," 
					'if K_wphone = 1 then sr = sr & "," & oo.telephoneNumber
					'if K_wfax = 1 then sr = sr & ",!!!" & oo.company
					'if K_hphone = 1 then sr = sr & ","
					'if K_hfax = 1 then sr = sr & ","
					'if K_mobile = 1 then sr = sr & "," & oo.mobile
					'if K_ophone = 1 then sr = sr & ","
					'if K_waddr = 1 then sr = sr & ",###" & oo.company
					'if K_haddr = 1 then sr = sr & ","
					'if K_org = 1 then sr = sr & ",@@@" & oo.company
					'if K_pos = 1 then sr = sr & "," & oo.title
					'if K_gmail = 1 then sr = sr & ","
'
					'sr = sr & vbcrlf
				'end if
'
			case "organizationalUnit"
				if K_indent = 1 then sr = sr & pad & "-->" 
				if K_headings = 1 then sr = sr & "[" & mid(oo.Name, 4) & "]" & vbcrlf

				sr = sr & GroupUsers(oo, pad & "   ")

				if K_indent = 1 then sr = sr & pad & "<--" & vbcrlf
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
