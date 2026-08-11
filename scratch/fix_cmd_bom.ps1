$downloadDir = "C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\website\static\download"
$files = Get-ChildItem -Path $downloadDir -Filter "*.cmd"

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    $psLine = $lines | Where-Object { $_ -match '^powershell\.exe' } | Select-Object -First 1

    $newContent = "@echo off`r`n" + $psLine

    # Write using UTF-8 NO BOM
    [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
    Write-Host "Set @echo off & NO BOM: $($file.Name)"
}

Write-Host ""
Write-Host "Done!"
