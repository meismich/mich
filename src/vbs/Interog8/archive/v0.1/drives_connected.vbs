' Version 1.0 (by MS)
' ------------------------------------
Option Explicit

dim o_net
dim o_sh
dim u_drives, i
dim s_text

set o_sh = CreateObject("WScript.Shell")
set o_net = CreateObject("WScript.Network")

dim s_machine, s_user

s_machine = o_net.ComputerName
s_user = o_net.UserName

set u_drives = o_net.EnumNetworkDrives()

for i = 0 to u_drives.count - 1 step 2
	if u_drives.item(i) <> "" then
		s_text = s_text & s_machine & "," & s_user & "," & u_drives.item(i) & "," & u_drives.item(i+1) & vbcrlf
	end if
next

const s_dir = "\\bne-issadm\tmp\drives\"

dim s_file
dim o_fso
dim o_file

'msgbox s_machine & vbcrlf & s_user
s_file = s_machine & "-" & s_user & "-DRIVES.csv"
's_file = "DRIVES.csv"

set o_fso = CreateObject("Scripting.FileSystemObject")
set o_file = o_fso.OpenTextFile(s_dir & s_file, 2, True)

o_file.Write(s_text)
o_file.Close

'msgbox s_drives
