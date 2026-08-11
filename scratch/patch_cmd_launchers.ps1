# This script patches all 9 CMD launcher scripts to:
# 1. Only install Audit365 1.0.6 if NOT already installed (avoids overwriting the good local copy)
# 2. Explicitly Import-Module after install to ensure it is loaded in the session

$downloadDir = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\website\static\download"
$files = Get-ChildItem -Path $downloadDir -Filter "*.cmd"

$oldInstall = "Install-Module Audit365 -RequiredVersion 1.0.6 -Scope CurrentUser -Force -AllowClobber"
$newInstall  = "if (-not (Get-Module Audit365 -ListAvailable | Where-Object { `$_.Version -eq '1.0.6' })) { Install-Module Audit365 -RequiredVersion 1.0.6 -Scope CurrentUser -AllowClobber }; Import-Module Audit365 -RequiredVersion 1.0.6 -Force"

$count = 0
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match [regex]::Escape($oldInstall)) {
        $content = $content.Replace($oldInstall, $newInstall)
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "Patched: $($file.Name)"
        $count++
    } else {
        Write-Host "Skipped (pattern not found): $($file.Name)"
    }
}

Write-Host "`nDone. $count file(s) patched."
