'
' File:		map_drive.vbs
' Author:	Michael Spence
' Date:		2009-07-29
' Version:	0.5
'
' Purpose:
' 	Map Network drives based on group membership
'
' Additions:
' (2009-07-29) Now also creates shortcut on current user's desktop
'
' Usage:
'	map_drive.vbs -f<drive file>|-h
'
'	drive file is to be formatted a particular way.
'	1st line must be "APE.GPS.MAP_DRIVE.ETC"
'	2nd line is the number of groups to check
'	any #'d line is a comment
'	any other line is expected to be a group entry
'	group entry contains csv'd data, 3 items per line
'	items are group name, UNC path, and drive letter
'	there must be enough valid lines to match 2nd line
'
'--------------------------------------------------------------------------------
'
Option Explicit

On Error Resume Next

' Debug mode (0 = off, 1 = on)
const b_debug = 0
' Location of Config file
const K_path = "\\apeagers.com.au\sysvol\apeagers.com.au\etc\"
const K_err = "Error Mapping Drive: "

const CFG_SGR_NAME = 1
const CFG_UNC_PATH = 2
const CFG_DRV_LTTR = 3

' Objects
dim o_fso, o_file			' Files
dim o_sh				' Shell
dim o_adinfo, o_ldap			' AD/LDAP
dim o_net				' Network

' Useful Variables
dim c_grps				' Collection of AD groups
dim i_gpdrvs, a_gpdrvs()		' No of Drives and array of
dim s_config				' Config file

' Trivial Variables
dim i, j, k
dim s, t, r

'--------------------------------------------------------------------------------
' STEP 0:  Check Command Line Arguements
'--------------------------------------------------------------------------------
if WScript.Arguments.Count = 0 then
	msgbox K_err & "Invalid Arguments"
	WScript.Quit(-9)
end if

for each s in WScript.Arguments
	t = left(s, 2)
	select case t
		case "-f"
			r = mid(s, 3)
			if b_debug = 0 then
				s_config = K_path & r
			else 
				s_config = r
				msgbox s_config
			end if
		case "-h"
			msgbox "map_drive -f<drive file>|-h"
			wscript.Quit(0)
	end select
next

'--------------------------------------------------------------------------------
' STEP 1:  Read Config File
'--------------------------------------------------------------------------------
' Open File for Reading
set o_fso = CreateObject("Scripting.FileSystemObject")
set o_file = o_fso.OpenTextFile(s_config, 1)

' If correct file ...
s = o_file.ReadLine
if s = "APE.GPS.MAP_DRIVE.ETC" then
	' ... get expected number of Lines
	s = o_file.ReadLine
	i_gpdrvs = cint(s)

	redim a_gpdrvs(i_gpdrvs, 3)

	' ... for all the expected number of lines ...
	for i = 1 to i_gpdrvs
		' ... make sure not EOF
		if o_file.AtEndOfStream then
			msgbox K_err & "Unexpected end of config File"
			i_err = 99
			exit for
		end if
		s = o_file.ReadLine

		' ... if line is a comment
		if left(s, 1) = "#" then
			' ... disregard line
			i = i - 1
		else
			' ... otherwise get details
			j = instr(s, ",")
			k = instr(j+1, s, ",")
			a_gpdrvs(i, CFG_SGR_NAME) = trim(mid(s, 1, j-1))	' Get Security GP Name
			a_gpdrvs(i, CFG_UNC_PATH) = trim(mid(s, j+1, k-j-1))	' Get Drive UNC Path
			a_gpdrvs(i, CFG_DRV_LTTR) = trim(mid(s, k+1))		' Get Drive Letter
		end if
	next
else
	msgbox K_err & "Invalid/Corrupt or Unreadable config file." & vbcrlf & "Please Log a Helpdesk Call"
end if

'--------------------------------------------------------------------------------
' STEP 2:  Determine Drive to Map based on Config and User Details
'--------------------------------------------------------------------------------
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

	' ... and based on CN, map drive if present in config
	for k = 1 to i_gpdrvs
		if r = a_gpdrvs(k, CFG_SGR_NAME) then
			map_drive a_gpdrvs(k, CFG_DRV_LTTR), a_gpdrvs(k, CFG_UNC_PATH)
			add_dscut a_gpdrvs(k, CFG_DRV_LTTR)
		end if
	next
next

'--------------------------------------------------------------------------------
' Function to Map Drive:  Map Network Drive (or at least pretend to)
'--------------------------------------------------------------------------------
function map_drive(s_drive, s_path) 
	dim c_drvs, i_done
	dim a

	if b_debug then 
		msgbox s_drive & vbcrlf & s_path
	else 
		' As long as we did find a drive to map ...
		if s_drive <> "" and s_path <> "" then
			i_done = 0
			set c_drvs = o_net.EnumNetworkDrives()
			for a = 0 to c_drvs.count - 1 step 2
				if c_drvs.item(a) = s_drive then i_done = 1
			next
			' ... do the actual map
			if i_done = 0 then
				set o_net = CreateObject("WScript.Network")
				o_net.MapNetworkDrive s_drive, s_path
			end if
		end if
	end if
end function

'--------------------------------------------------------------------------------
' Function to Create Desktop Shortcut:  Points to drive and is called '# Drive'
'--------------------------------------------------------------------------------
function add_dscut(s_drive)
	dim o_wsh, o_sc
	dim s_dtpath, s_scpath

	set o_wsh = wscript.createobject("Wscript.Shell")

	s_dtpath = o_wsh.specialfolders("Desktop")

	if b_debug = 1 then
		msgbox s_dtpath & vbcrlf & s_drive
	end if

	s_scpath = s_dtpath & "\" & left(s_drive, 1) & " Drive.lnk"

	set o_sc = o_wsh.createshortcut(s_scpath)

	o_sc.targetpath = s_drive & "\"

	o_sc.save
end function
