' File:		interog8.vbs
' Date:		2013-01-04
' Author:	Michael Spence
' Version:	2.1
' 
' Purpose:
' To discover meaningful data from a computer at user login.  
' This script currently captures 
'	Username
'	Computer Name
'	Operating System Version and Install Date
'	Mapped Drives
'	IP Addresses
'	Serial Number
'
' Results can be found at \\bne-issadm\tmp\drives
'
' Notes:
' This script originated from the drives_connected VBS

Option Explicit

dim o_net
dim s_date
dim s_machine, s_user
dim u_drives, i
dim s_text

dim o_wmi
dim o_qry
dim o_row
dim s_val

' Connect to Windows Management object
set o_wmi = GetObject("winmgmts:\\.\root\cimv2")


' Connect to network object
set o_net = CreateObject("WScript.Network")

' Fetch computer name and user name
s_machine = o_net.ComputerName
s_user = o_net.UserName

' Fetch the OS information
set o_qry = o_wmi.ExecQuery("select * from Win32_OperatingSystem")
for each o_row in o_qry
	s_date = o_row.LocalDateTime
	s_text = s_text & "WIN," & s_date & "," & s_machine & "," & o_row.Version & "," & o_row.InstallDate & vbcrlf
next

s_text = "###,Interog8,v2.1" & vbcrlf & "USR," & s_date & "," & s_machine & "," & s_user & vbcrlf & s_text

' Fetch the set of Mapped Drives and capture info
set u_drives = o_net.EnumNetworkDrives()

for i = 0 to u_drives.count - 1 step 2
	if u_drives.item(i) <> "" then
		s_text = s_text & "DRV," & s_date & "," & s_machine & "," & s_user & "," & u_drives.item(i) & "," & u_drives.item(i+1) & vbcrlf
	end if
next

' Fetch the serial number for each known bios
set o_qry = o_wmi.ExecQuery("select * from Win32_BIOS")
for each o_row in o_qry
	s_text = s_text & "SNO," & s_date & "," & s_machine & "," & o_row.SerialNumber & vbcrlf
next

' Fetch the IP address for each active Network card
set o_qry = o_wmi.ExecQuery("select * from Win32_NetworkAdapterConfiguration where IPEnabled = True")
for each o_row in o_qry
	for each s_val in o_row.IPAddress
		s_text = s_text & "IPA," & s_date & "," & s_machine & "," & s_val & vbcrlf
	next
next



const s_dir = "\\bne-issadm\tmp\drives\"

dim s_file
dim o_fso
dim o_file

' Calculate the output file name
s_file = s_machine & "-" & s_user & "-INTEROG8.csv"

' Connect to file system object and open file for writing
set o_fso = CreateObject("Scripting.FileSystemObject")
set o_file = o_fso.OpenTextFile(s_dir & s_file, 2, True)

o_file.Write(s_text)
o_file.Close
