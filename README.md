# FOG-Server an der FWE

## Ziele

Ziel dieses Projekts ist es, Leihnotebooks für Schüler*innen vorzubereiten.

- Erstellung eines Master-Images, das auf die Notebooks verteilt werden kann
- Zurücksetzen der Notebooks nach Rückgabe
- Aktualisierung des Master-Images mit neuen Windows-Updates oder neuer Software

## Aufbau

Es wird in einem autarken kleinen Netzwerk gearbeitet, wenn die Rechner ein neues Image erhalten sollen.

![Autarkes Netzwerk 192.168.4.x mit FOG-Server](images/network.png)

Internetzugriff ist dann nur notwendig, wenn ein neues Image erstellt wird und etwa die Windows-Updates und die Software installiert werden sollen. Man kann zum Beispiel einen der Windows Notebooks zuhause oder im WLAN vorbereiten und dann wieder per Kabel anschließen, um das Image in FOG einzuspielen.

Der FOG-Server dient auch als DHCP-Server, daher wird nur ein einfacher Switch und Patchkabel zwischen den Rechnern benötigt.

## Teil 1 - Vorbereitungen

Die Anleitung ["Klonen von Windows mit dem FOG-Server"](https://schulnetz.alp.dillingen.de/materialien/Fog.pdf) der Akademie Dillingen - SCHULNETZ war bei der Vorbereitung sehr hilfreich, ebenso weitere [Materialien](https://schulnetz.alp.dillingen.de/materialien.html).

### FOG-Server vorbereiten

- Ein [FOG-Server](https://fogproject.org/) dient zur Ablage der Images und Verwaltung der Rechner
- Linux Laptop mit Ubuntu und ausreichend Plattenplatz (500 GB)

- [statische IP Adresse am LAN-Port](https://www.howtoforge.com/linux-basics-set-a-static-ip-on-ubuntu)
  - [Beispielkonfiguration](server/etc/netplan/00-installer-config.yaml) mit `eno1` als Netzwerkkarte und IP-Adresse `192.168.4.2`
  - `sudo vi /etc/netplan/00-installer-config.yaml`
  - `sudo netplan apply`

- [DHCP-Server](https://www.techrepublic.com/article/how-to-setup-a-dhcp-server-with-ubuntu-server-18-04/) 
  - kann direkt über die FOG-Installation gemacht werden.
  - [Beispielkonfiguration](server/etc/dhcp/dhcpd.conf) mit DHCP-Bereich `192.168.4.10...254` und `192.168.4.2` als FOG-Server

- [FOG-Server installieren](https://schulnetz.alp.dillingen.de/materialien/Fog.pdf)
  - `sudo apt-get update`
  - `sudo apt-get upgrade`
  - `cd`
  - `git clone https://github.com/FOGProject/fogproject.git`
  - `cd ~/fogproject/bin`
  - Aktuelle Version von FOG auswählen
    `git checkout 1.5.9`
  - Installationsscript verwenden
    `sudo ./installfog.sh`
  - Es werden einige Dinge abgefragt, hier sind die Antworten
    * Here are the settings FOG will use:
    * Base Linux: Debian
    * Detected Linux Distribution: Ubuntu
    * Interface: eno1
    * Server IP Address: 192.168.4.2
    * Server Subnet Mask: 255.255.255.0
    * Server Hostname: fogserver
    * Installation Type: Normal Server
    * Internationalization: 0
    * Image Storage Location: /images
    * Using FOG DHCP: Yes
    * DHCP router Address: 192.168.4.1
  - URL http://192.168.4.2/fog öffnen und die Datenbank initialisieren

- Git Repo für die Automatisierung
  - Repo clonen
    `git clone git@github.com:StefanScherer/fwe-fog`
  - Repo ins Apache-Verzeichnis verschieben
    `sudo mv fwe-fog /var/www/html`
  - Repo aktualisieren
    `cd /var/www/html && git pull`
  - Windows-Passwörter anpassen
    `vi /var/www/html/fwe-fog/conf/unattend.xml`

### HP ProBook 455 G7 vorbereiten

- Schnellstart (Fast boot) abschalten
  - Systemsteuerung -> Hardware und Sound -> Energieoptionen
  - Verhalten des Netzschalters
  - Schnellstart deaktivieren
  - Siehe [`scripts/disable-fastboot.ps1`](scripts/disable-fastboot.ps1)
- BIOS mit F10
  - Secure Boot abschalten (Legacy boot enabled)
  - Wake on LAN aktivieren
  - Für HP Notebooks siehe [`scripts/set-bios.ps1`](scripts/set-bios.ps1)

#### erster Boot

- Ermittlung einiger wichtiger Angaben jedes einzelnen Rechners
- PowerShell Terminal öffnen (WIN + R drücken, dann `powershell` eingeben und RETURN)
- Windows-Product-Key auslesen
  - `Get-CimInstance -Class SoftwareLicensingService`
  - unter `OA3xOriginalProductKey` steht der Key in der Form `XXXXX-XXXXX-XXXXX-XXXXX-XXXXX`
- MAC-Adressen auslesen
  - `Get-WmiObject win32_networkadapterconfiguration | select description, macaddress`
- Seriennummer auslesen
  - `wmic bios get serialnumber`

## Teil 2 - FOG benutzen

- FOG-Server per LAN und Switch mit einem anderen Laptop verbinden, WLAN kann aus bleiben, es ist kein Internetzugriff notwendig
- FOG-Server booten
- FOG-Server verteilt IP-Adresse an die HP Notebooks
- Auf dem Linux-Laptop http://localhost/fog/ öffnen
- HP Notebooks imagen
- FOG-Server herunterfahren

### Einen neuen Rechner in die Liste aufnehmen

- Ins BIOS mit F12 zum Netboot
- "Perform Full Host Registration and Inventory" auwählen
- Windows Product-Key gleich mit aufnehmen

### Ein Image auf ein Laptop spielen

- In FOG das Image dem Rechner zuweisen
- Rechner am einfachsten Herunterfahren, FOG weckt den Rechner automatisch auf.
- In FOG beim Rechner den Task "Deploy" starten

### Ein Image vom Laptop sichern

- In FOG ein neues Image erzeugen
- Ins BIOS mit F12 zum Netboot
- "Perform Full Host Registration and Inventory" auwählen
- Windows Product-Key gleich mit aufnehmen
- Das neue Image dem Rechner zuweisen
- Rechner am einfachsten Herunterfahren, FOG weckt den Rechner automatisch auf.
- In FOG den Task "Capture" starten

### erstes Windows Image vorbereiten

- Den Rechner einschalten und alle Windows Updates einspielen.
- In den Audit Mode wechseln
  - `C:\Windows\system32\sysprep\sysprep.exe /audit /shutdown`
- Rechner wieder einschalten, ein Reboot beim vorherigen Befehl hat nicht funktioniert, daher der Shutdown und neuer Boot.
- Von diesem Stand ein Image in FOG erstellen, dann ist man bei der Software später noch flexibler.
- In FOG ein neues Image erzeugen, etwa `win10-v20h2-audit`
- Ins BIOS mit F12 zum Netboot
- "Perform Full Host Registration and Inventory" auswählen
- Windows Product-Key gleich mit aufnehmen
- Das neue Image dem Rechner zuweisen
- Rechner am einfachsten Herunterfahren, FOG weckt den Rechner automatisch auf.
- In FOG den Task "Capture" starten
- Ab jetzt hat man ein neues Image im Audit Mode, um immer wieder von hier aus Images mit der gewünschten Software zu bauen.

### Ein Image aktualisieren

- In FOG das Image `win10-v2004-audit` verwenden
- Wenn größere Windows Updates anstanden, möglichst wieder ein neues Image in FOG speichern, ansonsten weiter zur Installation der Software.
- Ein CMD Terminal im Adminmodus öffnen (WIN + R dann `cmd.exe`)
- Danach dann das Script zum Installieren der Software aufrufen
  ```
  curl.exe -o install.bat http://192.168.4.2/fwe-fog/install.bat
  install.bat
  ```
- Am Ende noch das Sysprep-Fenster nach vorne holen
  1. Out-of-Box-Experience (OOBE) für System aktivieren
  2. Verallgemeinern auswählen
  3. Option für Herunterfahren: Herunterfahren auswählen
  4. OK anklicken
- Der Rechner fährt herunter
- In FOG ein neues Image erzeugen, etwa `win10-v2004-mit-software-prep`
- Das neue Image dem Rechner zuweisen
- In FOG den Task "Capture" starten

## Teil 3 - Beschreibung der Automatisierung

Die Software und einige Einstellungen werden möglichst automatisch vorgenommen. Wie oben bereits gezeigt wurde, wird ein Script `install.bat` vom FOG-Server heruntergeladen, das dann noch weitere Scripte nachlädt.

In einem leeren Notebook, das gerade die aktuellen Windows Updates erhalten hat oder eines der `*-audit` Images zurückgespielt bekommen hat, wird das Script gestartet

Der bisherige Benutzer "admin" muss derzeit manuell entfernt werden.
- Eine CMD-Shell als Administrator öffnen.
   ```
   net user admin /DELETE
   ```
- Dann den Windows Explorer öffnen und das Verzeichnis C:\Users\admin komplett löschen.

Der Rechner befindet sich ja bereits im Audit Modus. Nun eine CMD Shell starten (WIN + R, dann `cmd` eingeben und RETURN).

```
curl.exe -o install.bat http://192.168.4.2/fwe-fog/install.bat
install.bat
```

### PowerShell Scripte erlauben

Das Script `install.bat` setzt erst einmal das Recht, weitere PowerShell-Scripte auszuführen.

### Install.ps1

Dann wird das Script `install.ps1` nachgeladen oder man kann es entsprechend direkt herunterladen und starten.

Dieses Script nimmt nun mehrere Änderungen vor, die in jeweils eigenen Scripten vermerkt sind:

- Fastboot deaktivieren in der Windows-Registry  
  Script [`scripts/disable-fastboot.ps1`](scripts/disable-fastboot.ps1)
- BIOS Einstellungen vornehmen. Hilft nur für den aktuellen Rechner udn wird nicht ins Image übernommen.  
  Script [`scripts/set-bios.ps1`](scripts/set-bios.ps1)
- Installation des Chocolatey Paketmanagers  
  Script [`scripts/install-chocolatey.ps1`](scripts/install-chocolatey.ps1)
- Installation der gewünschten Software. Die Liste kann in diesem Script entsprechend erweitert oder verändert werden. Eine Suche auf [chocolatey.org](https://chocolatey.org) hilft, um den Paketnamen einer Software zu finden.  
  Script [`scripts/install-software.ps1`](scripts/install-software.ps1)
- Entfernen einiger Apps, die den Sysprep verhindern  
  Script [`scripts/remove-default-apps.ps1`](scripts/remove-default-apps.ps1)
- Entfernen des Windows Produktschlüssels  
  Script [`scripts/remove-productkey.ps1`](scripts/remove-productkey.ps1)
- Installation der automatischen Vorbereitung mit einem Admin-Account und einem Standard-Account. Die Namen der Accounts und die Passwörter können in der Datei [`conf/unattend.xml`](conf/unattend.xml) vorgenommen werden, lokal auf dem FOG-Server.  
  Script [`scripts/install-unattend.ps1`](scripts/install-unattend.ps1)
- Löschen einiger Cache-Verzeichnisse  
  Script [`scripts/cleanup.ps1`](scripts/cleanup.ps1)
- Aufruf von Sysprep  
  Script [`scripts/sysprep-generalize.ps1`](scripts/sysprep-generalize.ps1)
