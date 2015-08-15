rem
rem FILE:	restore.bat
rem DATE:	2010-07-30
rem AUTHOR:	Michael Spence
rem
rem PURPOSE:
rem Forms first step of Restoration.
rem Restores backed up files from sister script "backup.bat" 
rem Restoration continues on firewall using "restore.sh"
rem

pscp -r bne-obfw45/* mspence@10.1.1.253:data/restore/.
