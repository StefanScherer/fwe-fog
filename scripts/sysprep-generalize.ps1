Write-Output "Der sysprep läuft in 15 Sekunden. Jetzt ist noch Zeit zum Abbrechen !!!"
Start-Sleep 15

C:\Windows\system32\sysprep\sysprep.exe /generalize /shutdown /oobe

Write-Output "Falls es nicht klappt, dann bitte das bereits geöffnete"
Write-Output "Systemvorbereitungsprogramm nach vorne holen und folgende"
Write-Output "Einstellungen machen:"
Write-Output ""
Write-Output "1. Out-of-Box-Experience (OOBE) für System aktivieren"
Write-Output "2. Verallgemeinern auswählen"
Write-Output "3. Option für Herunterfahren: Herunterfahren auswählen"
Write-Output "4. OK anklicken"
Write-Output ""
Write-Output "Danach fährt der Rechner herunter und ein neues Image"
Write-Output "kann in FOG erzeugt werden und von diesem Rechner mit"
Write-Output "Wake-on-LAN hochgeladen werden."
