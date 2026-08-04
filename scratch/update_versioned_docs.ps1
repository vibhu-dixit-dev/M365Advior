$folders = @(".\website\docs", ".\website\versioned_docs")

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        $files = Get-ChildItem -Path $folder -Recurse -Filter "*.md*"
        foreach ($file in $files) {
            $content = Get-Content -Path $file.FullName -Raw
            $updated = $false

            if ($content -match "Install-Module ('M365Advisor'|M365Advisor)") {
                $content = $content -replace "Install-Module 'M365Advisor'", "Install-Module 'Audit365'"
                $content = $content -replace "Install-Module M365Advisor", "Install-Module Audit365"
                $updated = $true
            }

            if ($content -match "\*\*M365Advisor\*\*") {
                $content = $content -replace "\*\*M365Advisor\*\*", "**Audit365**"
                $updated = $true
            }

            if ($updated) {
                Set-Content -Path $file.FullName -Value $content
                Write-Host "Updated $($file.FullName)"
            }
        }
    }
}

Write-Host "Targeted versioned documentation update complete."
