' File:		asc2hex.vbs
' Author:	Michael Spence
' Date:		2010-07-14
'
' Purpose:
' This is intended for use with setup of WAPs so that conversion between Ascii passcodes and Hex can be done
'==================================

Option Explicit

' Trivial
dim i

' Meaningful
dim s_asc
dim s_hex

' Get input String
s_asc = InputBox("Enter Ascii String", vbOkCancel)

'msgbox s_asc

' Convert to Hex
s_hex = ""
for i = 1 to len(s_asc)
	s_hex = s_hex & hex(asc(mid(s_asc, i, 1))) & " "
next

msgbox s_hex
