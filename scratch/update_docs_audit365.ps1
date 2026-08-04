$websitePath = ".\website"

# Search all .md files across website/ (including docs/ and versioned_docs/)
$mdFiles = Get-ChildItem -Path $websitePath -Recurse -Filter "*.md*"
foreach ($file in $mdFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $updated = $false

    if ($content -match "Install-Module ('M365Advisor'|M365Advisor)") {
        $content = $content -replace "Install-Module 'M365Advisor'", "Install-Module 'Audit365'"
        $content = $content -replace "Install-Module M365Advisor", "Install-Module Audit365"
        $updated = $true
    }

    if ($content -match "\*\*M365Advisor\*\* PowerShell module") {
        $content = $content -replace "\*\*M365Advisor\*\* PowerShell module", "**Audit365** PowerShell module"
        $updated = $true
    }

    if ($updated) {
        Set-Content -Path $file.FullName -Value $content
        Write-Host "Updated $($file.FullName)"
    }
}

# Update all .cmd runner scripts in website/static/download
$cmdFiles = Get-ChildItem -Path "$websitePath\static\download" -Filter "*.cmd"
foreach ($file in $cmdFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match "Install-Module M365Advisor") {
        $content = $content -replace "Install-Module M365Advisor", "Install-Module Audit365"
        Set-Content -Path $file.FullName -Value $content
        Write-Host "Updated $($file.FullName)"
    }
}

Write-Host "All website documentation (including versioned_docs) updated for Audit365."
