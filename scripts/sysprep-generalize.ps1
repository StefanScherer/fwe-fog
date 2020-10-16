$ErrorActionPreference = 'SilentlyContinue'

Write-Output "Der sysprep läuft in 15 Sekunden. Jetzt ist noch Zeit zum Abbrechen !!!"
Start-Sleep 15

Stop-Process -Name sysprep
Start-Sleep 1

Start-Process -FilePath C:\Windows\system32\sysprep\sysprep.exe -ArgumentList "/generalize /quit /oobe" -Wait

# from https://docs.microsoft.com/de-de/windows-hardware/manufacture/desktop/customize-the-default-user-profile-by-using-copyprofile

New-PSDrive HKU Registry HKEY_USERS
Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\*
Remove-ItemProperty HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Name "_.html"
Remove-ItemProperty HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\FileAssociations\ProgIds -Name "_.jpg"
# Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\Shell\Associations\FileAssociationsUpdateVersion\*
# Remove-Item -Recurse HKU:\.DEFAULT\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\*

Stop-Computer -Force -Confirm
