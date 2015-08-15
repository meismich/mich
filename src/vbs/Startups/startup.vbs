const  HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002


dim oReg

Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}" &_ 
			"!\\.\root\default:StdRegProv")

sKey = "Software\Microsoft\Windows\CurrentVersion\Run"

sTotData = FetchValueData(HKEY_LOCAL_MACHINE, sKey) & vbcrlf & _
	   FetchData(HKEY_LOCAL_MACHINE, "Software\Microsoft\Windows NT\CurrentVersion\Winlogon", "Userinit")



msgbox sTotData


Function FetchValueData(KReg, sKey)

	dim sReturn

	sReturn = "[" & KReg & " - " & sKey & "]"

	oReg.EnumValues KReg, sKey, aValues

	for each sValue in aValues
		oReg.GetStringValue KReg, sKey, sValue, sData
		sReturn = sReturn & vbcrlf & sValue & vbtab & sData
	next

	FetchValueData = sReturn

end function


Function FetchData(KReg, sKey, sValue)

	dim sReturn

	oReg.GetStringValue KReg, sKey, sValue, sReturn

	sReturn = "[" & KReg & " - " & sKey & vbcrlf & sValue & vbtab & sReturn

	FetchData = sReturn

end function