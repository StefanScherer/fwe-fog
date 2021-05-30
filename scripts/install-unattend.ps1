$ErrorActionPreference = 'Stop'

$fogServerIP = "192.168.4.2"

$unattendXML = "unattend.xml"
if (Test-Path .\conf\$unattendXML) {
    Write-Output "Use local $unattendXML"
    Copy-Item -Force .\conf\$unattendXML C:\Windows\Panther\unattend.xml
} else {
    Write-Output "Downloading $unattendXML"
    curl.exe -o $env:TEMP\$unattendXML http://$fogServerIP/fwe-fog/conf/$unattendXML
    Move-Item -Force $env:TEMP\$unattendXML C:\Windows\Panther\unattend.xml
}
