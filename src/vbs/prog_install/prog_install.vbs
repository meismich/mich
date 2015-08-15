'
' File:		prog_install.vbs
' Author:	Michael Spence
' Date:		2010-01-13
' Version:	0.1
'
' Purpose:
'	Install dealer programs automatically on first logon.
'
' Usage:
'	prog_install.vbs -f<progs file> | -h
'
'	prog file is to be formatted a particular way.
'	1st line must be "APE.GPS.PROG_INSTALL.ETC"
'	2nd line is the number of groups to check
'	any #'d line is a comment
'	any other line is expected to be a group entry.
'	Group entry contains csv'd data, 3 items minium per line
'	Items are group, log format, script and then optionally
'		both icon target and icon name
'	there must be enough valid lines to match 2nd line
'	log format specified as any alpha string with these
'		valid meta strings: %USER%, %COMPUTER%
'	scripts must write log file with log format name at location:
'		C:\etc\prog_install\.
'	all lines with icon target & name will cause this script
'		to reinstate icon every login
'
'--------------------------------------------------------------------------------
'
Option Explicit

On Error Resume Next

' Debug mode (0 = off, 1 = on)
const b_debug = 0
' Location of Config file
const K_debug_path = "C:\bin\"
const K_path = "\\apeagers.com.au\sysvol\apeagers.com.au\etc\"
const K_err = "Error Mapping Drive: "

const CFG_SGR_NAME = 1
const CFG_LOG_FILE = 2
const CFG_SRC_PATH = 3
const CFG_ICN_TRGT = 4
const CFG_ICN_NAME = 5

' Objects
dim o_fso, o_file			' Files
dim o_sh				' Shell
dim o_adinfo				' AD/LDAP
dim o_net				' Network

' Useful Variables
dim c_grps				' Collection of AD groups
dim i_gpdrvs, a_gpdrvs()		' No of Drives and array of
dim s_config				' Config file

' Trivial Variables
dim i, j, k, l, m
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
				s_config = K_debug_path & r
			else 
				s_config = K_path & r
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
if s = "APE.GPS.PROG_INSTALL.ETC" then
	' ... get expected number of Lines
	s = o_file.ReadLine
	i_gpdrvs = cint(s)

	redim a_gpdrvs(i_gpdrvs, 5)

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
			l = instr(k+1, s, ",")
			if l = 0 then
				a_gpdrvs(i, CFG_SGR_NAME) = trim(mid(s, 1, j-1))	' Get Security GP Name
				a_gpdrvs(i, CFG_LOG_FILE) = trim(mid(s, j+1, k-j-1))	' Get Log File Format
				a_gpdrvs(i, CFG_SRC_PATH) = trim(mid(s, k+1))		' Get Script Location
				a_gpdrvs(i, CFG_ICN_TRGT) = ""
				a_gpdrvs(i, CFG_ICN_NAME) = ""
			else 
				m = instr(l+1, s, ",")
				a_gpdrvs(i, CFG_SGR_NAME) = trim(mid(s, 1, j-1))	' Get Security GP Name
				a_gpdrvs(i, CFG_LOG_FILE) = trim(mid(s, j+1, k-j-1))	' Get LFF
				a_gpdrvs(i, CFG_SRC_PATH) = trim(mid(s, k+1, l-k-1))	' Get SL
				a_gpdrvs(i, CFG_ICN_TRGT) = trim(mid(s, l+1, m-l-1))	' Get Icon Target Locati
				a_gpdrvs(i, CFG_ICN_NAME) = trim(mid(s, m+1))		' Get Icon Name
			end if
			if b_debug = 1 then
				msgbox "1- " & a_gpdrvs(i, CFG_SGR_NAME) & vbcrlf & _
					"2- " & a_gpdrvs(i, CFG_UNC_PATH) & vbcrlf & _
					"3- " & a_gpdrvs(i, CFG_DRV_LTTR) & vbcrlf & _
					"4- " & a_gpdrvs(i, CFG_DRV_NICK)
			end if
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

BuildLogFiles o_adinfo.UserName, i_gpdrvs, a_gpdrvs
ObjectActions o_adinfo.UserName, i_gpdrvs, a_gpdrvs


'--------------------------------------------------------------------------------
' Sub-routine to Build Log File Locations:  
'--------------------------------------------------------------------------------
Sub BuildLogFiles (s_usr, i_gpds, a_gpds)

	dim i, j
	dim s, t, r

	for i = 0 to i_gpds
		s = a_gpds(i, CFG_LOG_FILE)
		j = instr(s, "%USER%")
		if j > 0 then
			t = mid(s, 1, j-1)
			r = mid(s, j+5) 
			a_gpds(i, CFG_LOG_FILE) = K_lpath & t & s_usr & r
		end if

		j = instr(s, "%COMP%)
		if j > 0 then
			t = mid(s, 1, j-1)
			r = mid(s, j+5)
			a_gpds(i, CFG_LOG_FILE) = K_lpath & t & "PC" & r
		end if
	next

End Sub

'--------------------------------------------------------------------------------
' Sub-routine to Check Groups:  Recurses objects' group membership tree
'--------------------------------------------------------------------------------
Sub ObjectActions (s_obj, i_gpds, a_gpds)

	dim o_ldap
	dim c_grps

	dim i, j, k
	dim s, t, r

	' ... Fetch the CN name
	t = LCase(s_obj)
	i = instr(t, "cn=")
	if i <= 0 then exit sub
	j = instr(i, t, ",")
	r = mid(t, i, j-i)

	' ... and based on CN, map drive if present in config
	for k = 1 to i_gpds
		if r = a_gpds(k, CFG_SGR_NAME) then
			run_instl a_gpds(k, CFG_LOG_FILE), a_gpds(k, CFG_SRC_PATH)
			add_dscut a_gpds(k, CFG_ICN_TRGT), a_gpds(k, CFG_ICN_NAME)
		end if
	next

	set o_ldap = GetObject("LDAP://" & s_obj)

	' Get the Collection of MemberOf
	if TypeName(o_ldap.MemberOf) = "Variant()" then
		c_grps = o_ldap.MemberOf
	else
		c_grps = array(o_ldap.MemberOf, "")
	end if

	' For each group in the collection....
	for each s in c_grps
		ObjectActions s, i_gpds, a_gpds
	next

End Sub

'--------------------------------------------------------------------------------
' Function to Run Install:  Runs install if log file not present
'--------------------------------------------------------------------------------
function run_instl(s_logfile, s_srcpath) 
	dim o_fsys, o_wsh

	if b_debug then 
		msgbox s_logfile & vbcrlf & s_srcpath
	end if
'	else 
		set o_fsys = CreateObject("Scripting.FileSystemObject")
		if NOT o_fsys.FileExists(s_logfile) then
			set o_wsh = CreateObject("Wscript.Shell")
			o_wsh.Run """" & s_srcpath & """"
		end if
'	end if
end function

'--------------------------------------------------------------------------------
' Function to Create Desktop Shortcut:  Points to drive and is called '# Drive'
'--------------------------------------------------------------------------------
function add_dscut(s_target, s_nick)
	dim o_wsh, o_sc
	dim s_dtpath, s_scpath

	set o_wsh = wscript.createobject("Wscript.Shell")

	s_dtpath = o_wsh.specialfolders("Desktop")

	if b_debug = 1 then
		msgbox s_dtpath & vbcrlf & s_target
	end if

	s_scpath = s_dtpath & "\" & s_nick & ".lnk"

	set o_sc = o_wsh.createshortcut(s_scpath)

	o_sc.targetpath = s_target & "\"

	o_sc.save
end function