'
' File:		eralink_v7update.vbs
' Author:	Michael Spence
' Date:		2009-04-08
' Version:	0.1
'
' Purpose:
' Install appropriate files from "\\bne-issadm\FindERALink\EraLink\*.*" to eralink installation directory
'---------------------------------------
Option Explicit

Dim as_filelocs(10), n_filelocs
Dim o_net, s_machine
Dim o_fso, o_file, o_folders

Dim i, i_found, i_done, f

n_filelocs = 2
as_filelocs(1) = "c:\program files\eralink"
as_filelocs(2) = "c:\program files\eralink4.1"

set o_net = CreateObject("WScript.Network")
s_machine = o_net.ComputerName

set o_fso = CreateObject("Scripting.FileSystemObject")

i_found = 0
i_done = 0
for i = 1 to n_filelocs
	if o_fso.FolderExists(as_filelocs(i)) then
		i_found = i
		if o_fso.FileExists(as_filelocs(i) & "\ERALinkMachineID.exe") then
			i_done = 1
		end if
	end if
next


if i_found > 0 and not i_done = 1 then
	CopyDir "\\bne-issadm\finderalink\ERALink", as_filelocs(i_found), ""
	set o_file = o_fso.OpenTextFile ("\\bne-issadm\finderalink\era7up-" & s_machine & ".txt"  , 2, True)
	o_file.WriteLine("Updated machine '" & s_machine & "' today (" & now & ")" )
	o_file.Close
end if

Sub CopyDir (s_src, s_dest, s_ext)

	dim s_path, o_folder

	s_path = s_dest
	if not s_ext = "" then
		s_path = s_path & "\" & s_ext
	end if

	'msgbox "Source: " & s_src & vbcrlf & _
	'	"Destin: " & s_dest & vbcrlf & _
	'	"Extend: " & s_ext & vbcrlf & _
	'	"------------------------------" & vbcrlf & _
	'	"Total Path: " & s_path

	' For all files in directory ...
	for each o_file in o_fso.GetFolder(s_src).Files
		o_fso.CopyFile s_src & "\" & o_file.Name, s_path & "\" & o_file.Name, True
	next
	
	' ... and dirs in directory
	for each o_folder in o_fso.GetFolder(s_src).SubFolders
		CopyDir o_folder.path, s_path, o_folder.name
	next

end sub
