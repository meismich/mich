const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002
strComputer = "."
Set StdOut = WScript.StdOut
 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
			strComputer & "\root\default:StdRegProv")
 
strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
strValueName1 = "ProxyServer"
strValueName2 = "ProxyEnable"
strValue = "string value"

r=msgbox("Are you at Work?", vbyesno)

if r = vbyes then
	strValue = "aus-csp:3128"
	dwdValue = 1
else
	strValue = ""
	dwdValue = 0
end if

msgbox "Proxy being set to: " & strValue & vbcrlf & "(" & dwdvalue & ")"
oReg.SetStringValue HKEY_CURRENT_USER, strKeyPath, strValueName1, strValue
oReg.SetDwordValue HKEY_CURRENT_USER, strKeyPath, strValueName2, dwdValue
