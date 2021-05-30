set fogServerIP=192.168.4.2

powershell -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted
if exist .\install.ps1 goto local
curl.exe -o %TEMP%\install.ps1 http://%fogServerIP%/fwe-fog/install.ps1
powershell -File %TEMP%\install.ps1
goto done
:local
powershell -File .\install.ps1
:done