# Fixes all 9 CMD launcher scripts:
# 1. Removes the CMD echo header (lines 3-11) so PS starts immediately with the blue box
# 2. Adds PnP.PowerShell install to all launchers (needed for some MT checks)
# Then re-applies the UTF-8 BOM fix to the installed psm1.

$downloadDir = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\website\static\download"
$files = Get-ChildItem -Path $downloadDir -Filter "*.cmd"

foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    # Keep only line 1 (@echo off / title) and the powershell.exe line (last non-empty line)
    # Strip lines 3-11 (the echo header / "Launching PowerShell..." text)
    $newLines = @($lines[0])  # @echo off

    # Find the powershell.exe line
    $psLine = $lines | Where-Object { $_ -match '^powershell\.exe' } | Select-Object -First 1

    if ($psLine) {
        # Inject PnP.PowerShell install if not already there
        if ($psLine -notmatch 'PnP.PowerShell') {
            $psLine = $psLine -replace `
                "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber;", `
                "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber; if (-not (Get-Module PnP.PowerShell -ListAvailable)) { Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber };"
        }
        $newLines += $psLine
        $newLines += ""  # trailing blank line
    }

    Set-Content -Path $file.FullName -Value $newLines -Encoding UTF8
    Write-Host "Fixed: $($file.Name)"
}

Write-Host ""
Write-Host "Re-applying UTF-8 BOM to installed Audit365 1.0.6 module..."

$dest = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Documents\WindowsPowerShell\Modules\Audit365\1.0.6"
$src  = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\module\Audit365"
$utf8Bom = New-Object System.Text.UTF8Encoding $true

foreach ($filename in @("Audit365.psm1", "Audit365.psd1", "M365Advisor.Format.ps1xml", "OrcaClasses.ps1")) {
    $srcFile  = Join-Path $src  $filename
    $destFile = Join-Path $dest $filename
    $content  = [System.IO.File]::ReadAllText($srcFile, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($destFile, $content, $utf8Bom)
    Write-Host "  BOM-written: $filename"
}

Write-Host ""
Write-Host "Done. Verifying import..."
Remove-Module Audit365 -Force -ErrorAction SilentlyContinue
$err = $null
Import-Module "$dest\Audit365.psd1" -Force -ErrorAction SilentlyContinue -ErrorVariable err
if ($err) {
    Write-Host "IMPORT FAILED: $err" -ForegroundColor Red
} else {
    Write-Host "SUCCESS - Module 1.0.6 imported cleanly." -ForegroundColor Green
}
