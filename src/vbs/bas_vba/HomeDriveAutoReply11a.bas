Attribute VB_Name = "HomeDriveAutoReply"
'
' File:         HomeDriveAutoReply.bas
' Author:       Michael Spence
' Date:         2009-06-25
' Version:      1.1
'
' Purpose:
' Give an auto response to homedrive enquiries, with a standard layout, from a single person.
'
' Method:
' Searches original email from 'donotreply@homedrive.com.au' for string "EMail:" (note the capital M)
' Obtians the email address of the enquiree for target email address of AutoReply
' Creates a new mail message to send via SMTP at bne-mx1.  Body of email in HTML, which links an image from
' website.
'
' Future:
' Add image to email, instead of linking to website
'
' Installation:
' In VbaProject include this file as a module.  (ie Right-Click project and "Import file...")
' In "Rules and Alerts..." (under "Tools" Menu) create a rule for "donotreply@homedrive.com.au" for all
' messages from this sender, to use a script.  Use script "Project1!AutoReply" (where Project1 is the
' project name for this copy of Outlook.  AutoReply is this function below

' AutoReply -
' The function which causes the autoreply, via SMTP using bne-mx1
Sub AutoReply(omiIn As Outlook.MailItem)
    Dim cdo_mail
    Dim szBody As String, szEAddr As String
    
    ' Strip out Email address
    With omiIn
        szBody = .Body
        i = InStr(szBody, "EMail:")
        If i > 0 Then
            j = InStr(i, szBody, vbcrlf)
            szEAddr = Trim(Mid(szBody, i + 6, j - i - 6))
            'MsgBox szEAddr
        End If
    End With
    
    ' If not a valid email address....
    If szEAddr = "" Or InStr(szEAddr, "@") < 1 Then
        szEAddr = ""
    Else
        ' Create and Send Email
        Set cdo_mail = CreateObject("CDO.Message")
        With cdo_mail
            .To = szEAddr
            .From = "enquiry@homedrive.com.au"
            .Subject = "HomeDrive"
            '.TextBody = "Hi," & vbcrlf & vbcrlf & _
                    "Thank you for your email.  I am Diane Batley, the Online Manager for homedrive.com.au.  I will be passing your details onto your closest authorized dealer and they will be in contact within a couple of hours (during business hours) to confirm your appointment to bring a new car to you for a test drive." & vbcrlf & vbcrlf & _
                    "I will be contacting you following your test drive to see if you found your HomeDrive easy and convenient.  This will only take a couple of minutes and your thoughts concerning your HomeDrive experience are valuable to us and we will use your input to constantly improve our service." & vbcrlf & vbcrlf & _
                    "Enjoy the fantastic experience that HomeDrive has to offer and the excitement of a new car purchase.  We hope we have made the process just a little bit easier for you." & vbcrlf & vbcrlf & _
                    "You may contact me by email or direct on 1300 852 796 if you would like to discuss anything at all with me, I am always available." & vbcrlf & vbcrlf & _
                    "Talk to you soon." & vbcrlf & vbcrlf & _
                    "Kind Regards," & vbcrlf & vbcrlf & _
                    "Diane Bately" & vbcrlf & _
                        "Online Manager" & vbcrlf & _
                    "HomeDrive.com.au"
                    
            ' HTML Formatted body for the reply email
            .HTMLBody = "<html><body><font face=Arial color=blue>Hi,<br><br>" & _
                    "Thank you for your email.  I am Diane Batley, the Online Manager for homedrive.com.au.  I will be passing your details onto your closest authorized dealer and they will be in contact within a couple of hours (during business hours) to confirm your appointment to bring a new car to you for a test drive.<br><br>" & _
                    "I will be contacting you following your test drive to see if you found your HomeDrive easy and convenient.  This will only take a couple of minutes and your thoughts concerning your HomeDrive experience are valuable to us and we will use your input to constantly improve our service.<br><br>" & _
                    "Enjoy the fantastic experience that HomeDrive has to offer and the excitement of a new car purchase.  We hope we have made the process just a little bit easier for you.<br><br>" & _
                    "You may contact me by email or direct on 1300 852 796 if you would like to discuss anything at all with me, I am always available.<br><br>" & _
                    "Talk to you soon.<br><br>" & _
                    "Kind Regards,<br><br>" & _
                    "Diane Batley<br><br>" & _
                    "Online Manager<br>" & _
                    "HomeDrive.com.au<br><br>" & _
                    "<img src='http://demo.dealersolutions.com.au/homedrive/assets/images/header.jpg'></body></html>"
            .Configuration.Fields.Item _
                    ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
            .Configuration.Fields.Item _
                    ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "bne-mx1"
            .Configuration.Fields.Item _
                    ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
            .Configuration.Fields.Update
            .Send
        End With
        Set cdo_mail = Nothing
        
        Set omi_mail = CreateItem(olMailItem)
        With omi_mail
            .To = "enquiry@homedrive.com.au"
            .Subject = "Confirmed Reply to " & szEAddr
            .Send
        End With
        
    End If
End Sub

