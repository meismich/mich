'
' File:		BuildRDP.vbs
' Date:		2013-03-05
' Author:	Michael Spence
' Version:	1.0
'
' Purpose:
' Builds the RDP file for the entered user and destination computer 
' accessed via the GateKeeper defined as "tmp.apeagers.com.au"
'
option explicit

dim oWsh, oArg, sCmd, i
Set oWsh = CreateObject("WScript.Shell")
Set oArg = WScript.Arguments

dim sDesk, sUname, sServer, sTarget, sString

for i = 0 to oArg.count -1
	if left(oArg.Item(i), 1) = "-" then
		select case mid(oArg.item(i), 2, 1)
			case "T"
				sTarget=mid(oArg.Item(i), 3) & ".gk.apeagers.com.au"
			case "U"
				sUname=mid(oArg.Item(i), 3)
			case "S"
				sServer=mid(oArg.Item(i), 3)
		end select
	end if
next

sDesk = oWsh.SpecialFolders("Desktop")

if sTarget = "" then sTarget = "emp.gk.apeagers.com.au"

if sUname = "" then sUname = InputBox("Please enter USERNAME (eg 'apeagers\jblogs')")
if sServer = "" then sServer = InputBox("Please enter Target COMPUTER")

sString = 	"screen mode id:i:2" & vbcrlf & _
		"desktopwidth:i:1280" & vbcrlf & _
		"desktopheight:i:1024" & vbcrlf & _
		"session bpp:i:32" & vbcrlf & _
		"winposstr:s:0,3,67,148,1219,754" & vbcrlf & _
		"compression:i:1" & vbcrlf & _
		"keyboardhook:i:2" & vbcrlf & _
		"displayconnectionbar:i:1" & vbcrlf & _
		"disable wallpaper:i:1" & vbcrlf & _
		"disable full window drag:i:1" & vbcrlf & _
		"allow desktop composition:i:0" & vbcrlf & _
		"allow font smoothing:i:0" & vbcrlf & _
		"disable menu anims:i:1" & vbcrlf & _
		"disable themes:i:0" & vbcrlf & _
		"disable cursor setting:i:0" & vbcrlf & _
		"bitmapcachepersistenable:i:1" & vbcrlf & _
		"full address:s:" & sServer & vbcrlf & _
		"audiomode:i:0" & vbcrlf & _
		"redirectprinters:i:1" & vbcrlf & _
		"redirectcomports:i:0" & vbcrlf & _
		"redirectsmartcards:i:1" & vbcrlf & _
		"redirectclipboard:i:1" & vbcrlf & _
		"redirectposdevices:i:0" & vbcrlf & _
		"autoreconnection enabled:i:1" & vbcrlf & _
		"authentication level:i:0" & vbcrlf & _
		"prompt for credentials:i:1" & vbcrlf & _
		"negotiate security layer:i:1" & vbcrlf & _
		"remoteapplicationmode:i:0" & vbcrlf & _
		"gatewayhostname:s:" & sTarget & vbcrlf & _
		"gatewayusagemethod:i:1" & vbcrlf & _
		"gatewaycredentialssource:i:0" & vbcrlf & _
		"gatewayprofileusagemethod:i:1" & vbcrlf & _
		"promptcredentialonce:i:1" & vbcrlf & _
		"use multimon:i:0" & vbcrlf & _
		"audiocapturemode:i:0" & vbcrlf & _
		"videoplaybackmode:i:1" & vbcrlf & _
		"connection type:i:2" & vbcrlf & _
		"redirectdirectx:i:1" & vbcrlf & _
		"use redirection server name:i:0" & vbcrlf & _
		"drivestoredirect:s:" 

if sUname <> "" then sString = sString & vbcrlf & "username:s:" & sUname

if sServer = "" then sServer = "Blank"

dim oFso, oFile

set oFso = CreateObject("Scripting.FileSystemObject")
set oFile = oFso.OpenTextFile(sDesk & "\" & sServer & ".rdp", 2, True)

oFile.Write(sString)
oFile.Close

