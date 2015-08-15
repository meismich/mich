'
' File:		mso07_tempfolder_location.vbs
' Date:		2010-08-10
' Author:	Michael Spence
' 
' Purpose:
' To loate exactly the Microsoft Outlook 2007 temp folder
'
Option Explicit

dim oReg
dim sKey, sName, sVal

const HKEY_CURRENT_USER = &H80000001

Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}" & _
			"!\\.\root\default:StdRegProv")

sKey = "Software\Microsoft\Office\12.0\Outlook\Security"
sName = "OutlookSecureTempFolder"

oReg.GetStringValue HKEY_CURRENT_USER, sKey, sName, sVal

msgbox sVal
