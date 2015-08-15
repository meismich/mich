' File:		fake8.vbs
' Date:		2013-09-30
' Author:	Michael Spence
' Version:	0.1
' 

Option Explicit

dim s_date, s_user
dim s_text, s_serial
dim s_file
dim o_fso
dim o_file
dim i_done
dim i_year, i_month

const s_dir = "\\bne-issadm\tmp\drives\"
'const s_dir = "c:\tmp\"

i_year = datepart("yyyy", Now())
i_month = datepart("m", Now()) + 2
if datepart("m", Now()) > 10 then
	i_year = i_year + 1
	i_month = i_month - 12
end if

s_date = i_year & _
		right("00" & i_month, 2) & _
		right("00" & datepart("d", Now()), 2) & _
		right("00" & datepart("h", Now()), 2) & _
		right("00" & datepart("n", Now()), 2) & _
		right("00" & datepart("s", Now()), 2) & _
		".000000+600"

s_user = inputbox("Enter your ID:", vbOK)

i_done = 0

while i_done = 0

	s_serial = inputbox("Enter Serial Number ['done' to quit]:", vbOk)
	if s_serial = "done" then
		i_done = 1
	else

		s_text = "###,Interog8,v2.1" & vbcrlf & _
				"SNO," & s_date & ",UNKNOWN," & s_serial & vbcrlf & _
				"USR," & s_date & ",UNKNOWN,FakedBy:" & s_user & vbcrlf

		' Calculate the output file name
		s_file = "SERIAL_" & s_serial & "-" & s_user & "-INTEROG8.csv"
		
		' Connect to file system object and open file for writing
		set o_fso = CreateObject("Scripting.FileSystemObject")
		set o_file = o_fso.OpenTextFile(s_dir & s_file, 2, True)
		
		o_file.Write(s_text)
		o_file.Close
	end if

wend
