'=========================================================================
' TITLE:		DelFileBasedOnExtDateMaxAge.vbs
'
' AUTHOR:  		Eric Phelps
' URL:			 http://www.ericphelps.com
'
' REVISOR:		Christian Sawyer
' COMPANY: 		Implanciel Inc.
' DATE:    		2004-11-08
' EMAIL:		csawyer@implanciel.com
'
' PURPOSE:		Deletes old files based on age. You must specify a target
'				 directory and max age. This script looks for these items
'				 on the command line - The directory is the first argument,
'				 and the max age is the second argument. If no arguments are
'				 supplied, the environment is checked for KILL_FILES_IN and
'				 MAX_FILE_AGE. If no environment variables are found, the user
'				 is asked.
'=========================================================================

Option Explicit 
'On Error Resume Next 
	Const READONLY = 1 
	Const HIDDEN = 2 
	Const SYSTEM = 4
	Const EXT2DELETE = "Tmp"
	Dim objFSO 'As Scripting.FileSystemObject
	Dim objShell 'As WScript.Shell 
	Dim objFile 'As Scripting.File 
	Dim objFiles 'As Scripting.Files 
	Dim objFolder 'As Scripting.Folder 
	Dim objFolders 'As Scripting.Folders
	Dim objDir 'As String
	Dim arrEmptyFolders(100000)
	Dim intX
	Dim strStartingDirectory 'As String 
	Dim strExt
	Dim strCurrentExt
	Dim dblMaxAge 'As Double 


'Create needed Global object
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell") 

Main
WScript.Quit 0 

Sub Main() 
	'Initialize input variables 
	strStartingDirectory = "" 
	dblMaxAge = 0 
	'Get data from command line 
	If WScript.Arguments.Count > 0 Then 
		strStartingDirectory = WScript.Arguments(0) 
		If WScript.Arguments.Count = 2 Then 
			dblMaxAge = CDbl(WScript.Arguments(1)) 
		End If 
	End If 
	'Get data from the environment 
	If strStartingDirectory = "" Then 
		strStartingDirectory = objShell.Environment.Item("KILL_FILES_IN") 
	End If
	
	If dblMaxAge = 0 Then 
		If IsNumeric(objShell.Environment.Item("MAX_FILE_AGE")) Then 
			dblMaxAge = CDbl(objShell.Environment.Item("MAX_FILE_AGE")) 
		End If 
	End If 
	'Ask user for data 
	If strStartingDirectory = "" Then 
		strStartingDirectory = InputBox("Enter path to start deleting at:", "Delete Old Files", FileNameInThisDir("")) 
		MsgBox "You could have supplied the path information as the environment variable KILL_FILES_IN or as the first argument to this script" 
	End If 
	If strStartingDirectory = "" Then 
		WScript.Quit 1 
	End If 
	If dblMaxAge = 0 Then 
		dblMaxAge = CDbl(InputBox("Enter the minimum time since file creation (in days) of files to delete", "Delete Old Files", "180")) 
		MsgBox "You could have supplied the file age information in the environment variable MAX_FILE_AGE or as the second argument to this script" 
	End If 
	If dblMaxAge = 0 Then 
		WScript.Quit 1 
	End If 
	'Initialize objDir to argument or environnement Folder.
	Set objDir = objFSO.GetFolder(strStartingDirectory) 
	'dblMaxAge has to be greater than 0
	If dblMaxAge < 1 Then WScript.Quit 1 
	
'Find and delete all files matching extension define in EXT2DELETE and 
'matching max age define in argument. Will go through all subfolders under
'strStartingDirectory from argument or Environnement.
FindFiles2Delete objDir.Path
'Check for any empty sub folders.
FindEmptyFolders objDir.Path
DeleteEmptyFldr


End Sub

Function FileNameInThisDir(strFileName) 'As String 
'Returns the complete path and file name to a file in 
'the script directory. For example, "trans.log" might 
'return "C:\Program Files\Scripts\Database\trans.log" 
'if the script was in the "C:\Program Files\Scripts\Database" 
'directory.
FileNameInThisDir = objFSO.GetAbsolutePathName(objFSO.BuildPath(WScript.ScriptFullName, "..\" & strFileName)) 
End Function

Function FindFiles2Delete(strPath)
	For Each objFile In objFSO.GetFolder(strPath).Files 
		'Get current extension in selected folder.
		strCurrentExt = objFSO.GetExtensionName(objFile.Path) 
		WScript.Echo(objFile & " has an extension of " & strCurrentExt) 
		If (CDbl(Now) - CDbl(objFile.DateCreated)) > dblMaxAge Then 
			If ((objFile.Attributes And READONLY) = 0) Then 
				If ((objFile.Attributes And SYSTEM) = 0) Then 
					If ((objFile.Attributes And HIDDEN) = 0) Then 
						If LCase(objFile.Path) <> LCase(WScript.ScriptFullName) Then 
							If LCase(strCurrentExt) = LCase(EXT2DELETE) Then 
								objFile.Delete
							End If 
						End If 
					End If 
				End If 
			End If 
		End If 
	Next
	' If there is subfolder(s) under current folder in strPath, call
	' recursively this sub until there is no other subfolder(s)
	For Each objFolder In objFSO.GetFolder(strPath).SubFolders
		'Recall itself for next subfolder to find files to delete based on specified
		'extension and max age.
		FindFiles2Delete(objFolder.Path)
	Next
End Function

Function FindEmptyFolders(strPath)
	Dim objFolder
	Dim strDriveLetter
	
	' Take only drive letter without :.
	strDriveLetter = Left(strPath, 1)
	' Verify if current folder in strPath is a system folder.
	If (strPath = strDriveLetter+":\RECYCLED") Or (strPath = strDriveLetter+":\RECYCLER") Or (strPath = strDriveLetter+":\System Volume Information") Then 
		'Do Nothing
	Else		
		' Verify if there is subfolder(s) and file(s) in it. If not, add current
		' folder in array arrEmptyFolders.
		If (objFSO.GetFolder(strPath).SubFolders.Count = 0) And (objFSO.GetFolder(strPath).Files.Count = 0) Then
			arrEmptyFolders(intX) = strPath
			intX = intX + 1
		End If
		' If there is subfolder(s) under current folder in strPath, call
		' recursively this sub until there is no other subfolder(s)
		For Each objFolder In objFSO.GetFolder(strPath).SubFolders
			'Recall itself for next subfolder.
			FindEmptyFolders(objFolder.Path)
		Next
	End If
End Function

Sub DeleteEmptyFldr()
	Dim intY
	Do
		For intY = 0 To intX - 1
			On Error Resume Next
			objFSO.DeleteFolder (arrEmptyFolders(intY))
		Next
		intX = 0
	   FindEmptyFolders(strStartingDirectory)
	Loop While intX > 0
End Sub