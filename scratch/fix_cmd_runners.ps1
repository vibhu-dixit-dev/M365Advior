$downloadPath = ".\website\static\download"

# 1. run-m365advisor-cis.cmd
$cisContent = Get-Content -Path "$downloadPath\run-m365advisor-cis.cmd" -Raw
$cisContent = $cisContent -replace "Install-Module Audit365 -Scope CurrentUser;", "Install-Module Audit365 -Scope CurrentUser -Force -AllowClobber;"
$cisContent = $cisContent -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
$cisContent = $cisContent -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Tag 'CIS';"
Set-Content -Path "$downloadPath\run-m365advisor-cis.cmd" -Value $cisContent

# 2. run-m365advisor-iso27001.cmd
$iso1Content = Get-Content -Path "$downloadPath\run-m365advisor-iso27001.cmd" -Raw
$iso1Content = $iso1Content -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
if (-not ($iso1Content -match "-Path \\\.\\iso27001")) {
    $iso1Content = $iso1Content -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Path .\iso27001;"
}
Set-Content -Path "$downloadPath\run-m365advisor-iso27001.cmd" -Value $iso1Content

# 3. run-m365advisor-iso27002.cmd
$iso2Content = Get-Content -Path "$downloadPath\run-m365advisor-iso27002.cmd" -Raw
$iso2Content = $iso2Content -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
if (-not ($iso2Content -match "-Path \\\.\\iso27002")) {
    $iso2Content = $iso2Content -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Path .\iso27002;"
}
Set-Content -Path "$downloadPath\run-m365advisor-iso27002.cmd" -Value $iso2Content

# 4. run-m365advisor-cisa.cmd
$cisaContent = Get-Content -Path "$downloadPath\run-m365advisor-cisa.cmd" -Raw
$cisaContent = $cisaContent -replace "Install-Module Audit365 -Scope CurrentUser;", "Install-Module Audit365 -Scope CurrentUser -Force -AllowClobber;"
$cisaContent = $cisaContent -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
$cisaContent = $cisaContent -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Tag 'CISA';"
Set-Content -Path "$downloadPath\run-m365advisor-cisa.cmd" -Value $cisaContent

# 5. run-m365advisor-eidsca.cmd
$eidscaContent = Get-Content -Path "$downloadPath\run-m365advisor-eidsca.cmd" -Raw
$eidscaContent = $eidscaContent -replace "Install-Module Audit365 -Scope CurrentUser;", "Install-Module Audit365 -Scope CurrentUser -Force -AllowClobber;"
$eidscaContent = $eidscaContent -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
$eidscaContent = $eidscaContent -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Tag 'EIDSCA';"
Set-Content -Path "$downloadPath\run-m365advisor-eidsca.cmd" -Value $eidscaContent

# 6. run-m365advisor-orca.cmd
$orcaContent = Get-Content -Path "$downloadPath\run-m365advisor-orca.cmd" -Raw
$orcaContent = $orcaContent -replace "Install-Module Audit365 -Scope CurrentUser;", "Install-Module Audit365 -Scope CurrentUser -Force -AllowClobber;"
$orcaContent = $orcaContent -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
$orcaContent = $orcaContent -replace "Invoke-M365Advisor;", "Invoke-M365Advisor -Tag 'ORCA';"
Set-Content -Path "$downloadPath\run-m365advisor-orca.cmd" -Value $orcaContent

# 7. run-m365advisor-m365.cmd (All compliance check!)
$m365Content = Get-Content -Path "$downloadPath\run-m365advisor-m365.cmd" -Raw
$m365Content = $m365Content -replace "Install-Module Audit365 -Scope CurrentUser;", "Install-Module Audit365 -Scope CurrentUser -Force -AllowClobber;"
$m365Content = $m365Content -replace "Install-M365AdvisorTests;", "Install-M365AdvisorTests -Force;"
Set-Content -Path "$downloadPath\run-m365advisor-m365.cmd" -Value $m365Content

Write-Host "Updated all runner .cmd scripts with target-specific Invoke-M365Advisor commands!"
