$ErrorActionPreference = 'SilentlyContinue'

net stop COMSysApp
taskkill /F /IM dllhost.exe
taskkill /F /IM taskhost.exe
taskkill /F /IM taskhostex.exe
Remove-Item -Force C:\Users\Administrator\AppData\Local\Microsoft\Windows\Webcache\*
Remove-Item -Force -Recurse C:\Users\Administrator\AppData\Local\Microsoft\Windows\INetCache\*
Remove-Item -Force C:\Users\Administrator\AppData\Local\Microsoft\Windows\WebcacheLock.dat