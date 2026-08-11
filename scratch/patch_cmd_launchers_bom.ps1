# Patches all 9 CMD launcher scripts to include an inline UTF-8 BOM fix step
# that runs after Install-Module but before Import-Module.
# This ensures the module psm1 is always written with a BOM, which PS5.1 needs
# to correctly read UTF-8 encoded files with emoji/Unicode characters.

$downloadDir = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\website\static\download"
$files = Get-ChildItem -Path $downloadDir -Filter "*.cmd"

# The old pattern to find and replace
$oldPattern = "if (-not (Get-Module Audit365 -ListAvailable | Where-Object { `$_.Version -eq '1.0.6' })) { Install-Module Audit365 -RequiredVersion 1.0.6 -Scope CurrentUser -AllowClobber }; Import-Module Audit365 -RequiredVersion 1.0.6 -Force"

# New: install if needed, then rewrite psm1 with UTF-8 BOM so PS5.1 reads Unicode correctly, then import
$newPattern  = "if (-not (Get-Module Audit365 -ListAvailable | Where-Object { `$_.Version -eq '1.0.6' })) { Install-Module Audit365 -RequiredVersion 1.0.6 -Scope CurrentUser -AllowClobber }; `$_a365 = (Get-Module Audit365 -ListAvailable | Where-Object { `$_.Version -eq '1.0.6' } | Select-Object -First 1).ModuleBase; if (`$_a365) { `$_bom = New-Object System.Text.UTF8Encoding `$true; foreach (`$_f in @('Audit365.psm1','Audit365.psd1','OrcaClasses.ps1')) { `$_fp = Join-Path `$_a365 `$_f; if (Test-Path `$_fp) { [System.IO.File]::WriteAllText(`$_fp, [System.IO.File]::ReadAllText(`$_fp, [System.Text.Encoding]::UTF8), `$_bom) } } }; Import-Module Audit365 -RequiredVersion 1.0.6 -Force"

$count = 0
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match [regex]::Escape($oldPattern)) {
        $content = $content.Replace($oldPattern, $newPattern)
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "Patched: $($file.Name)"
        $count++
    } else {
        Write-Host "Skipped (pattern not found): $($file.Name)"
    }
}

Write-Host ""
Write-Host "Done. $count file(s) patched."
