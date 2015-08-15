:: 
:: File:	INSTALL.BAT
:: Date:	2013-03-05
:: Author:	Michael Spence
:: Version:	1.0
::
:: Purpose
:: Install required certificates and build RDP icon on desktop
::
set p=%~dp0
certutil -user -f -addstore "root" "%p%gk-ca.crt"
"%p%buildrdp.vbs" "-Temp" "-Sbne-apps"
