:: 
:: File:	INSTALL.BAT
:: Date:	2013-03-05
:: Author:	Michael Spence
:: Version:	1.0
::
:: Purpose
:: Install required certificates and build RDP icon on desktop
::
:: set p=%~dp0
:: certutil -user -f -addstore "root" "%p%trial_ca.cer"
:: certutil -user -f -addstore "my" "%p%tmp.cer"
"%p%buildrdp.vbs" "-Temp" "-Uapeagers\mspence" "-Sbne-isdept"
