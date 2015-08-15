'
' File:		tipt_tb_install.vbs
' Author:	Michael Spence
' Date:		2009-04-22
' Version:	1.1.brisbane
'
' Purpose:
' Install Tipt Toolbar .msi from "\\bne-issadm\fileshare" using GP
'---------------------------------------
Option Explicit

const S_SVRDIR = "\\bne-issadm\fileshare\gps.results\tipt_tb"
const S_MSISRC = "\source\Telstra_Telephony_Toolbar_14_10_108_12.msi"
const S_LCLDIR = "C:\Program Files\TIPT\Telstra Telephony Toolbar"

dim o_net, o_fso, o_wsh
Dim s_machine, s_exist, s_line
Dim s_cmd, i_done, i_err, o_file

' Do some WSH/VBS stuff
set o_net = CreateObject("WScript.Network")
s_machine = o_net.ComputerName

set o_fso = CreateObject("Scripting.FileSystemObject")
i_done = 0
' Check if install directory exists....
if o_fso.FolderExists(S_LCLDIR) then
	' ... and if so....
	if o_fso.FileExists(S_LCLDIR & "\APE_version.txt") then
		' ... check version installed ...
		set o_file = o_fso.OpenTextFile (S_LCLDIR & "\APE_version.txt")
		if not o_file.atendofstream then	
			s_line = o_file.readline
			o_file.Close
			if s_line = S_MSISRC then
				i_done = 1
			end if
		end if
	end if
end if

if not i_done = 1 then
	s_cmd = S_SVRDIR & S_MSISRC & " /q"

	set o_wsh = CreateObject("WScript.Shell")
	i_err = o_wsh.run(s_cmd, 0, True)

	if i_err then
		set o_file = o_fso.OpenTextFile (S_SVRDIR & "\ERROR-tipt_tb-" & s_machine & ".txt"  , 2, True)
		o_file.WriteLine("Error during installation on '" & s_machine & "' today (" & now & ")" )
		o_file.Close
	else
		' Record machine name and installation time
		set o_file = o_fso.OpenTextFile (S_SVRDIR & "\tipt_tb-" & s_machine & ".txt"  , 2, True)
		o_file.WriteLine("Updated machine '" & s_machine & "' today (" & now & ")" )
		o_file.Close

		' Record Version
		set o_file = o_fso.OpenTextFile (S_LCLDIR & "\APE_version.txt", 2, True)
		o_file.WriteLine(S_MSISRC)
		o_file.WriteLine("Installed at: " & now)
		o_file.close
	end if
end if


