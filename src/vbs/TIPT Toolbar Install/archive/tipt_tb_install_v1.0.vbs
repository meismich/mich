'
' File:		tipt_tb_install.vbs
' Author:	Michael Spence
' Date:		2009-04-22
' Version:	1.0.brisbane
'
' Purpose:
' Install Tipt Toolbar .msi from "\\bne-issadm\fileshare" using GP
'---------------------------------------
Option Explicit

const S_SVRDIR = "\\bne-issadm\fileshare\gps.results\tipt_tb"

dim o_net, o_fso, o_wsh
Dim s_machine, s_exist
Dim s_cmd, i_done, i_err, o_file

' Do some WSH/VBS stuff
set o_net = CreateObject("WScript.Network")
s_machine = o_net.ComputerName

s_exist = """C:\Program Files\BroadSoft\BroadWorks Assistant Enterprise"""
set o_fso = CreateObject("Scripting.FileSystemObject")
if o_fso.FolderExists(s_exist) then
	i_done = 1
end if

if not i_done = 1 then
	s_cmd = S_SVRDIR & "\source\Telstra_Special_14_6_22_1.msi /q"

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
	end if
end if


