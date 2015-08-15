'
' FILE:		chgip.vbs
' DATE:		2010-10-21
' AUTHOR:	Michael Spence
' VERSION:	0.2
'
' PURPOSE:
' To be able to set the IP address machine based on the location
'
' USAGE:
' Plase file "chgip.etc" in "C:\bin\etc".
' Format file with correct Locationns, IP addresses and Gateways.
'
' File should look like:
' 
' APE.LOC.CHANGE_IP.ETC
' <MAC Address of Network Card>
' <Location 1 Name>
' <IP Address 1>
' <Gateway 1>
' <Location 2 Name>
' <IP Address 2>
' <Gateway 2>
' 
' Notes on Config file:
' MAC address should use colons (:) to separate the two hex digit segments
' Location Names can be anything, but make them useful
' NOW WORKS with DHCP, if IP is 0.0.0.0
Option Explicit

Const K_cfg = "c:\bin\etc\chgip.etc"

Dim sMAC
Dim sLoc1, sLoc2
Dim sIP1, sIP2
Dim sGW1, sGW2
Dim iFound
Dim oWMIS
Dim aCards, oCard
dim e, s
Dim oFSO, oFile

On Error Resume Next

'----------------------------------------
' Read Config File
'----------------------------------------
set oFSO = CreateObject("Scripting.FileSystemObject")
set oFile = oFSO.OpenTextFile(K_cfg, 1)

s = oFile.ReadLine
if s = "APE.LOC.CHANGE_IP.ETC" then
	sMAC = oFile.ReadLine
	sLoc1 = oFile.ReadLine
	sIP1 = oFile.ReadLine
	sGW1 = oFile.ReadLine
	sLoc2 = oFile.ReadLine
	sIP2 = oFile.ReadLine
	sGW2 = oFile.ReadLine
else
	Msgbox "Configuration file incorrectly formatted!! Refer to Helpdesk."
end if

'----------------------------------------
' Check Card Exists
'----------------------------------------
Set oWMIS = GetObject("winmgmts:\\.\root\cimv2")

Set aCards = oWMIS.ExecQuery( _
	"Select * from Win32_NetworkAdapterConfiguration where MACAddress='" & sMAC & "'")

'Set oCard = aCards.Index(0)

iFound=0
if aCards.Count > 0 then 
	For Each oCard in aCards
		iFound=1
'		msgbox "MAC: " & oCard.MACAddress & vbcrlf & _
'			"IP: " & oCard.IPAddress(0) 
		exit for
	Next
end if

'----------------------------------------
' Set the Appropriate IP Address
'----------------------------------------
if iFound then
	if msgbox("Are you at your standard location?" & vbcrlf & vbcrlf & _
			"'Yes' for " & sLoc1 & " (" & sIP1 &")" & vbcrlf & _
			"'No' for " & sLoc2 & " (" & sIP2 & ")", vbYesNo) = vbNo then
		setip oCard, sIP2, sGW2
	else
		setip oCard, sIP1, sGW1
	end if
else
	Msgbox "No Network Card Matches Configuration!  Refer to Helpdesk."
end if

sub setip(oNCard, sIPAddr, sIPGWay)
	msgbox "SETIP" & sIPAddr & vbcrlf & sIPGway
	if sIPAddr = "0.0.0.0" then
		e = oNCard.EnableDHCP()
	else
		e = oNCard.EnableStatic(Array(sIPAddr), Array("255.255.0.0"))
		e = oNCard.SetGateways(Array(sIPGWay))
	end if
end sub
