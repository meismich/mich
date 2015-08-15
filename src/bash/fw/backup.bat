rem
rem FILE:	backup.bat
rem DATE:	2010-07-30
rem AUTHOR:	Michael Spence
rem
rem PURPOSE:
rem Forms final step of firewall Backup.
rem Backs up files ready for restoration by sister script "restore.bat" 
rem Script "backup.sh" must be run prior on firewall
rem

pscp -r mspence@10.1.1.253:data/backup/* backup/.
