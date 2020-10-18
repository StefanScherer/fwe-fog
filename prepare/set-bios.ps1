# from https://www.systanddeploy.com/2019/03/list-and-change-bios-settings-with.html

Function Get_HP_BIOS_Settings
 { 
  $Script:Get_BIOS_Settings = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class hp_biosEnumeration -ErrorAction SilentlyContinue |  % { New-Object psobject -Property @{    
   Setting = $_."Name"
   Value = $_."currentvalue"
   Available_Values = $_."possiblevalues"
   }}  | select-object Setting, Value, possiblevalues
  $Get_BIOS_Settings
 } 


Get_HP_BIOS_Settings

Write-Output "Setze BIOS Einstellungen"
$bios = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BIOSSettingInterface
$bios.setbiossetting("Fast Boot", "Enable","")
$bios.setbiossetting("Network (PXE) Boot", "Enable","")
$bios.setbiossetting("Configure Legacy Support and Secure Boot", "Legacy Support Enable and Secure Boot Disable","")
$bios.setbiossetting("Wake On LAN", "Boot to Network","")
