' File:		interog8.vbs
' Date:		2011-09-13
' Author:	Michael Spence
' Version:	2.0
' 
' Purpose:
' To discover meaningful data from a computer at user login.  
' This script currently captures Username, ComputerName, the Drives mapped and Serial Number
' Results can be found at \\bne-issadm\tmp\drives
'
' Notes:
' This script originated from the drives_connected VBS

Option Explicit

dim o_net
dim s_machine, s_user
dim u_drives, i
dim s_text

' Connect to network object
set o_net = CreateObject("WScript.Network")

' Fetch computer name and user name
s_machine = o_net.ComputerName
s_user = o_net.UserName

' Fetch the set of Mapped Drives and capture info
set u_drives = o_net.EnumNetworkDrives()

for i = 0 to u_drives.count - 1 step 2
	if u_drives.item(i) <> "" then
		s_text = s_text & s_machine & "," & s_user & "," & u_drives.item(i) & "," & u_drives.item(i+1) & vbcrlf
	end if
next

dim o_wmi
dim o_bioses
dim o_bios

' Connect to Windows Management object and fetch the set of bios values
set o_wmi = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & s_machine & "\root\cimv2")
set o_bioses = o_wmi.ExecQuery("select * from Win32_BIOS")

' Fetch the serial number for each known bios
for each o_bios in o_bioses
	s_text = s_text & "serial number for [" & s_machine & "] = " & o_bios.SerialNumber & vbcrlf
next

const s_dir = "\\bne-issadm\tmp\drives\"

dim s_file
dim o_fso
dim o_file

' Calculate the output file name
s_file = s_machine & "-" & s_user & "-DRIVES.csv"

' Connect to file system object and open file for writing
set o_fso = CreateObject("Scripting.FileSystemObject")
set o_file = o_fso.OpenTextFile(s_dir & s_file, 2, True)

o_file.Write(s_text)
o_file.Close
