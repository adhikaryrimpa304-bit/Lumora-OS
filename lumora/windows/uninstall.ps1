# Restores the settings saved by install.ps1 and removes the Lumora clock skin.
$ErrorActionPreference = 'Stop'
$backupFile = Join-Path $env:APPDATA 'Lumora\backup.json'
if (-not (Test-Path $backupFile)) { Write-Host 'No backup found; nothing to restore.'; exit 0 }
$b = Get-Content $backupFile -Raw | ConvertFrom-Json

foreach ($s in $b.Settings) {
    if ($null -eq $s.Value) {
        Remove-ItemProperty -Path $s.Path -Name $s.Name -ErrorAction SilentlyContinue
    } else {
        New-ItemProperty -Path $s.Path -Name $s.Name -Value ([int]$s.Value) -PropertyType DWord -Force | Out-Null
    }
}

if ($b.Wallpaper) {
    Add-Type @"
using System.Runtime.InteropServices;
public class LumoraWall2 {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int a, int b, string c, int d);
}
"@
    [LumoraWall2]::SystemParametersInfo(20, 0, $b.Wallpaper, 3) | Out-Null
}

$rm = @("$env:ProgramFiles\Rainmeter\Rainmeter.exe", "${env:ProgramFiles(x86)}\Rainmeter\Rainmeter.exe") |
      Where-Object { Test-Path $_ } | Select-Object -First 1
if ($rm) { & $rm '!DeactivateConfig' 'Lumora\Clock' }
Remove-Item (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'Rainmeter\Skins\Lumora') -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $backupFile -Force

Stop-Process -Name explorer -Force
Write-Host 'Restored. Rainmeter itself was left installed.'
