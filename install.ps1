$ErrorActionPreference = 'Stop'

$fogServerIP = "192.168.4.2"

function Elevate-Privileges {
    param($Privilege)
    $Definition = @"
    using System;
    using System.Runtime.InteropServices;

    public class AdjPriv {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

        [DllImport("advapi32.dll", SetLastError = true)]
            internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
            internal struct TokPriv1Luid {
                public int Count;
                public long Luid;
                public int Attr;
            }

        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

        public static bool EnablePrivilege(long processHandle, string privilege) {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
    }
"@
    $ProcessHandle = (Get-Process -id $pid).Handle
    $type = Add-Type $definition -PassThru
    $type[0]::EnablePrivilege($processHandle, $Privilege)
}

Function Run($script) {
    Write-Output "Downloading $script"
    curl.exe -o $env:TEMP\$script http://$fogServerIP/fwe-fog/scripts/$script
    Write-Output "Running $script"
    . $env:TEMP\$script
}

Run("disable-fastboot.ps1")

if ($env:USERNAME -ne "Administrator") {
    Write-Output "Switching to Audit Mode first ..."
    Write-Output "The computer will shut down in a few seconds."
    Write-Output "Turn it on again and run this script again to continue."
    Start-Sleep 10
    C:\Windows\system32\sysprep\sysprep.exe /audit /shutdown
}

Run("install-chocolatey.ps1")
Run("install-software.ps1")

Run("remove-default-apps.ps1")
Run("remove-default-apps.ps1") # erst beim zweiten Mal wird alles entfernt

Run("remove-productkey.ps1")

Run("install-unattend.ps1")
Run("cleanup.ps1")
Run("sysprep-generalize.ps1")
