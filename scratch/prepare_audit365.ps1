$destDir = ".\module\Audit365"
if (Test-Path $destDir) {
    Remove-Item -Path $destDir -Recurse -Force
}
New-Item -ItemType Directory -Path $destDir -Force | Out-Null

# Copy compiled build files from .\module\ to .\module\Audit365\
Copy-Item ".\module\M365Advisor.Format.ps1xml" $destDir -Force
Copy-Item ".\module\OrcaClasses.ps1" $destDir -Force
Copy-Item ".\module\assets" $destDir -Recurse -Force
Copy-Item ".\module\public" $destDir -Recurse -Force
if (Test-Path ".\module\m365advisor-tests") {
    Copy-Item ".\module\m365advisor-tests" $destDir -Recurse -Force
}

# Copy and rename .psm1 and .psd1
Copy-Item ".\module\M365Advisor.psm1" "$destDir\Audit365.psm1" -Force
Copy-Item ".\module\M365Advisor.psd1" "$destDir\Audit365.psd1" -Force

# Update manifest values in Audit365.psd1
$manifest = Get-Content "$destDir\Audit365.psd1" -Raw
$manifest = $manifest -replace "RootModule\s*=\s*'[^']+'", "RootModule = 'Audit365.psm1'"
$manifest = $manifest -replace "ModuleVersion\s*=\s*'[^']+'", "ModuleVersion = '1.0.1'"
Set-Content -Path "$destDir\Audit365.psd1" -Value $manifest

Write-Host "Successfully prepared Audit365 v1.0.1 package at .\module\Audit365\"
