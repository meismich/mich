'
' File:		Location.vbs
' Author:	Michael Spence
' Date:		2009-06-??
' Version:	1.1
' 
' Purpose:
' Quick util for changing the proxy settings on a computer, which is regularly on and off our network.
' (For example a computer which is regularly used on a home network as well as ours)
'
const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002
 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}" &_ 
			"!\\.\root\default:StdRegProv")
 
strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings"

r=msgbox("Are you at Work?", vbyesno)

if r = vbyes then
	strValue = "bne-isa:8080"
	dwdValue = 1
else
	strValue = ""
	dwdValue = 0
end if

msgbox "Proxy being set to: " & strValue & vbcrlf & "(" & dwdvalue & ")"
oReg.SetStringValue HKEY_CURRENT_USER, strKeyPath, "ProxyServer", strValue
oReg.SetDwordValue HKEY_CURRENT_USER, strKeyPath, "ProxyEnable", dwdValue
