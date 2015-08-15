'
' File:		HomeDriveAutoReply.bas
' Author:	Michael Spence
' Date:		2009-06-25
' Version:	0.2
'
' Purpose:
' Give an auto response to homedrive enquiries, with a standard layout, from a single person.
'
Attribute VB_Name = "HomeDriveAutoReply"
Sub AutoReply(omiIn As Outlook.MailItem)
    Dim omiOut As Outlook.MailItem
    Dim szBody As String, szEAddr As String
    
    ' Strip out Email address
    With omiIn
        szBody = .Body
        i = InStr(szBody, "EMail:")
        If i > 0 Then
            j = InStr(i, szBody, vbCrLf)
            szEAddr = Trim(Mid(szBody, i + 6, j - i - 6))
            'MsgBox szEAddr
        End If
    End With
    
    ' Create and Send Email
    Set omiOut = CreateItem(olMailItem)   'omiIn.Reply
    With omiOut
        .To = szEAddr
	.Subject = "HomeDrive"
        .Body = "Hi," & vbcrlf & vbcrlf & _
		"Thank you for your email.  I am Diane Batley, the Online Manager for homedrive.com.au.  I will be passing your details onto your closest authorized dealer and they will be in contact within a couple of hours (during business hours) to confirm your appointment to bring a new car to you for a test drive." & vbcrlf & vbcrlf & _
		"I will be contacting you following your test drive to see if you found your HomeDrive easy and convenient.  This will only take a couple of minutes and your thoughts concerning your HomeDrive experience are valuable to us and we will use your input to constantly improve our service." & vbcrlf & vbcrlf & _
		"Enjoy the fantastic experience that HomeDrive has to offer and the excitement of a new car purchase.  We hope we have made the process just a little bit easier for you." & vbcrlf & vbcrlf & _
		"You may contact me by email or direct on 1300 852 796 if you would like to discuss anything at all with me, I am always available." & vbcrlf & vbcrlf & _
		"Talk to you soon." & vbcrlf & vbcrlf & _
		"Kind Regards," & vbcrlf & vbcrlf & _
		"Diane Bately" & vbcrlf & _
		"Online Manager" & vbcrlf & _
		"HomeDrive.com.au"
        .Send
    End With
    Set omiOut = Nothing
End Sub
