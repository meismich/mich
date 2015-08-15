Option Explicit
Dim WSHNetwork, objArgs, ADOconnObj, bstrADOQueryString, RootDom, RSObj
Dim FSMOobj,CompNTDS, Computer, Path, HelpText


Set WSHNetwork = CreateObject("WScript.Network")
Set objArgs = WScript.Arguments

HelpText = "This script will find the FSMO role owners for your domain." & Chr(13) &_
           Chr(10) & "The syntax is as follows:" & Chr(13) & Chr(10) &_
           "find_fsmo DC=MYDOM,DC=COM" & Chr(13) & Chr(10) &_
           """Where MYDOM.COM is your domain name.""" & Chr(13) & Chr(10) & "OR:" &_
           Chr(13) & Chr(10) & "find_fsmo MYDCNAME " & Chr(13) & Chr(10) &_
           """Where MYDCNAME is the name of a Windows 2000 Domain Controller"""


Select Case objArgs.Count
    Case 0
        Path = InputBox("Enter your DC name or the DN for your domain"&_
                        " 'DC=MYDOM,DC=COM':","Enter path",WSHNetwork.ComputerName)
    Case 1
        Select Case UCase(objArgs(0))
            Case "?"
                WScript.Echo HelpText
                WScript.Quit
            Case "/?"
                WScript.Echo HelpText
                WScript.Quit
            Case "HELP"
                WScript.Echo HelpText
                WScript.Quit
            Case Else
                Path = objArgs(0)
        End Select
    Case Else
        WScript.Echo HelpText
        WScript.Quit
End Select




Set ADOconnObj = CreateObject("ADODB.Connection")

ADOconnObj.Provider = "ADSDSOObject"
ADOconnObj.Open "ADs Provider"


'PDC FSMO
bstrADOQueryString = "<LDAP://"&Path&">;(&(objectClass=domainDNS)(fSMORoleOwner=*));adspath;subtree"
Set RootDom = GetObject("LDAP://RootDSE")
Set RSObj = ADOconnObj.Execute(bstrADOQueryString)
Set FSMOobj = GetObject(RSObj.Fields(0).Value)
Set CompNTDS = GetObject("LDAP://" & FSMOobj.fSMORoleOwner)
Set Computer = GetObject(CompNTDS.Parent)
WScript.Echo "The PDC FSMO is: " & Computer.dnsHostName


'Rid FSMO
bstrADOQueryString = "<LDAP://"&Path&">;(&(objectClass=rIDManager)(fSMORoleOwner=*));adspath;subtree"

Set RSObj = ADOconnObj.Execute(bstrADOQueryString)
Set FSMOobj = GetObject(RSObj.Fields(0).Value)
Set CompNTDS = GetObject("LDAP://" & FSMOobj.fSMORoleOwner)
Set Computer = GetObject(CompNTDS.Parent)
WScript.Echo "The RID FSMO is: " & Computer.dnsHostName


'Infrastructure FSMO
bstrADOQueryString = "<LDAP://"&Path&">;(&(objectClass=infrastructureUpdate)(fSMORoleOwner=*));adspath;subtree"

Set RSObj = ADOconnObj.Execute(bstrADOQueryString)
Set FSMOobj = GetObject(RSObj.Fields(0).Value)
Set CompNTDS = GetObject("LDAP://" & FSMOobj.fSMORoleOwner)
Set Computer = GetObject(CompNTDS.Parent)
WScript.Echo "The Infrastructure FSMO is: " & Computer.dnsHostName


'Schema FSMO
bstrADOQueryString = "<LDAP://"&RootDom.Get("schemaNamingContext")&_
                     ">;(&(objectClass=dMD)(fSMORoleOwner=*));adspath;subtree"

Set RSObj = ADOconnObj.Execute(bstrADOQueryString)
Set FSMOobj = GetObject(RSObj.Fields(0).Value)
Set CompNTDS = GetObject("LDAP://" & FSMOobj.fSMORoleOwner)
Set Computer = GetObject(CompNTDS.Parent)
WScript.Echo "The Schema FSMO is: " & Computer.dnsHostName


'Domain Naming FSMO
bstrADOQueryString = "<LDAP://"&RootDom.Get("configurationNamingContext")&_
                     ">;(&(objectClass=crossRefContainer)(fSMORoleOwner=*));adspath;subtree"

Set RSObj = ADOconnObj.Execute(bstrADOQueryString)
Set FSMOobj = GetObject(RSObj.Fields(0).Value)
Set CompNTDS = GetObject("LDAP://" & FSMOobj.fSMORoleOwner)
Set Computer = GetObject(CompNTDS.Parent)
WScript.Echo "The Domain Naming FSMO is: " & Computer.dnsHostName
