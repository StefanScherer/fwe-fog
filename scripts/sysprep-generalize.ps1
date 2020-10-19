$ErrorActionPreference = 'SilentlyContinue'

Write-Output "Der sysprep startet in 15 Sekunden. Jetzt ist noch Zeit zum Abbrechen !!!"
Start-Sleep 15

Stop-Process -Name sysprep
Start-Sleep 1

# from https://docs.microsoft.com/de-de/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-copyprofile

Remove-Item -Recurse HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\*
Remove-Item -Recurse HKCU:\Software\Microsoft\Windows\Shell\Associations\FileAssociationsUpdateVersion\*
Remove-Item -Recurse HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\*

Write-Output "Der sysprep ist gestartet."
Start-Process -FilePath C:\Windows\system32\sysprep\sysprep.exe -ArgumentList "/generalize /quit /oobe" -Wait

# from https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/customize-the-default-user-profile-by-using-copyprofile

# Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\*
# Remove-ItemProperty HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Name "_.html"
# Remove-ItemProperty HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Name "_.jpg"
# Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\Shell\Associations\FileAssociationsUpdateVersion\*
# Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\*

# from https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-8.1-and-8/hh825038(v=win.10)

Write-Output "Der Rechner wird in 10 Sekunden heruntergefahren. Jetzt ist noch Zeit zum Abbrechen !!!"
Start-Sleep 10
shutdown /s /t 5
