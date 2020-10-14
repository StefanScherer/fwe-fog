# FOG-Server an der FWE

## Ziele

Ziel dieses Projekts ist es, Leihnotebooks für Schüler*innen vorzubereiten.

- Erstellung eines Master-Images, das auf die Notebooks verteilt werden kann
- Zurücksetzen der Notebooks nach Rückgabe
- Aktualisierung des Master-Images mit neuen Windows-Updates oder neuer Software

## FOG-Server vorbereiten

- Ein [FOG-Server](https://fogproject.org/) dient zur Ablage der Images und Verwaltung der Rechner
- Linux Laptop mit Ubuntu
- [statische IP Adresse am LAN-Port](https://www.howtoforge.com/linux-basics-set-a-static-ip-on-ubuntu)
- [DHCP-Server](https://www.techrepublic.com/article/how-to-setup-a-dhcp-server-with-ubuntu-server-18-04/) - kann aber über die FOG-Installation gemacht werden.
- [FOG-Server installieren](https://schulnetz.alp.dillingen.de/materialien/Fog.pdf)
- Git Repo für die Automatisierung
  - Repo clonen
    ```
    git clone git@github.com:StefanScherer/fwe-fog
    ```
  - Repo ins Apache-Verzeichnis verschieben
    ```
    sudo mv fwe-fog /var/www/html
    ```
  - Repo aktualisieren
    ```
    cd /var/www/html && git pull
    ```
  - Windows-Passwörter anpassen
    ```
    vi /var/www/html/fwe-fog/conf/unattend.xml
    ```

## Ablauf

- FOG-Server per LAN und Switch mit einem anderen Laptop verbinden, WLAN kann aus bleiben, es ist kein Internetzugriff notwendig
- FOG-Server booten
- FOG-Server verteilt IP-Adresse an die HP Notebooks
- Auf dem Linux-Laptop http://localhost/fog/ öffnen
- HP Notebooks imagen
- FOG-Server herunterfahren

## HP ProBook 455 G7 vorbereiten

- Schnellstart (Fast boot) abschalten
  - Systemsteuerung -> Hardware und Sound -> Energieoptionen
  - Verhalten des Netzschalters
  - Schnellstart deaktivieren
  - das macht das Installationsscript mittlerweile automatisch.
- BIOS mit F10
  - Secure Boot abschalten (Legacy boot enabled)
  - Wake on LAN aktivieren
  - eventuell hiermit? http://www.systanddeploy.com/2019/03/list-and-change-bios-settings-with.html

### erster Boot

- Windows-Product-Key auslesen
  - `Get-CimInstance -Class SoftwareLicensingService`
- MAC-Adressen auslesen
  - `Get-WmiObject win32_networkadapterconfiguration | select description, macaddress`
- Seriennummer auslesen
  - `wmic bios get serialnumber`

## Windows Image

- in den Audit Mode wechseln
  - `C:\Windows\system32\sysprep\sysprep.exe`

### Softwarepakete

- Powershell Set Execution Policy
  - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`
- Chocolatey
  - `iwr -useb https://chocolatey.org | iex`
- Libre Office
- Firefox
- 7 Zip
- Geogebra
- Zoom
- Adobe Reader

### Windows 10 aufräumen

- Debloat Windows Scripte ausführen
- Windows Product-Key entfernen
  - `slmgr.vbs /upk`
- Benutzer "admin" entfernen
- unattend.xml einspielen

## FOG benutzen

### Ein Image vom Laptop sichern

- In FOG ein neues Image erzeugen
- Ins BIOS mit F12 zum Netboot
- "Perform Full Host Registration and Inventory"
- Windows Product-Key gleich mit aufnehmen
- Das neue Image dem Rechner zuweisen
- In FOG den Task "Capture" starten
- Rechner in Netboot bringen

### Ein Image auf ein Laptop spielen

- In FOG das Image dem Rechner zuweisen
- In FOG beim Rechner den Task "Deploy" starten
- Rechner in Netboot bringen

### Ein Image aktualisieren

- In FOG das Image "win10-v2004-clean" verwenden
- Da ist noch der Benutzer "admin" drauf und die Lizenz vom ersten Notebook.
- Hier könnte man Windows Updates neu aufspielen und ggf. ein neues Image speichern.
- Ein CMD Terminal im Adminmodus öffnen (WIN + R dann `cmd.exe`)
- Danach dann das Script zum Installieren der Software aufrufen
  ```
  curl.exe -o install.bat http://192.168.4.2/fwe-fog/install.bat
  install.bat
  ```
