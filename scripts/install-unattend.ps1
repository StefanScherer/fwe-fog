$ErrorActionPreference = 'Stop'

$unattendXML = "unattend.xml"
Write-Output "Downloading $unattendXML"
curl.exe -o $env:TEMP\$unattendXML http://$fogServerIP/fwe-fog/conf/$unattendXML
Move-Item -Force $env:TEMP\$unattendXML C:\Windows\Panther\unattend.xml
