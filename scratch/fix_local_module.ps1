$dest = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Documents\WindowsPowerShell\Modules\Audit365\1.0.6"
$src  = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\module\Audit365"

# PowerShell 5.1 reads files without a UTF-8 BOM as ANSI, which corrupts emoji/Unicode characters.
# We read the source with UTF-8 and re-write with UTF-8 BOM so PS5.1 parses it correctly.
$utf8Bom = New-Object System.Text.UTF8Encoding $true   # $true = emit BOM

foreach ($filename in @("Audit365.psm1", "Audit365.psd1", "M365Advisor.Format.ps1xml", "OrcaClasses.ps1")) {
    $srcFile  = Join-Path $src  $filename
    $destFile = Join-Path $dest $filename
    $content  = [System.IO.File]::ReadAllText($srcFile, [System.Text.Encoding]::UTF8)
    [System.IO.File]::WriteAllText($destFile, $content, $utf8Bom)
    Write-Host "Written (UTF-8 BOM): $filename"
}

Write-Host ""
Write-Host "Done! Lines in installed psm1:"
(Get-Content "$dest\Audit365.psm1" -Encoding UTF8 | Measure-Object -Line).Lines

Write-Host ""
Write-Host "Verifying Import-Module..."
Remove-Module Audit365 -Force -ErrorAction SilentlyContinue
$err = $null
Import-Module "$dest\Audit365.psd1" -Force -ErrorAction SilentlyContinue -ErrorVariable err
if ($err) {
    Write-Host "IMPORT FAILED: $err" -ForegroundColor Red
} else {
    $cmds = Get-Command Connect-M365Advisor, Install-M365AdvisorTests, Invoke-M365Advisor -ErrorAction SilentlyContinue
    if ($cmds.Count -eq 3) {
        Write-Host "SUCCESS - All 3 key commands available:" -ForegroundColor Green
        $cmds | Select-Object Name, Version | Format-Table -AutoSize
    } else {
        Write-Host "PARTIAL - only $($cmds.Count)/3 commands found" -ForegroundColor Yellow
    }
}
