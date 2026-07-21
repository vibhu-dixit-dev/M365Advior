@echo off
title M365 Advisor Launcher - CIS Benchmarks
echo =======================================================================
echo.
echo    M365 Advisor - Automated Assessment Launcher
echo    Targeting: CIS Benchmarks
echo.
echo =======================================================================
echo.
echo Launching PowerShell and executing assessment script...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -Command "Write-Host '=================================================================' -ForegroundColor Cyan; Write-Host '             M365 Advisor Automated Assessment' -ForegroundColor Cyan; Write-Host '             Targeting: CIS Benchmarks' -ForegroundColor Cyan; Write-Host '=================================================================' -ForegroundColor Cyan; Write-Host ''; Write-Host '[1/4] Checking and installing required modules...' -ForegroundColor Yellow; Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser; Install-Module M365Advisor -Scope CurrentUser; Write-Host ''; Write-Host '[2/4] Setting up local tests directory (M365Advisor-tests)...' -ForegroundColor Yellow; New-Item -ItemType Directory -Force -Path M365Advisor-tests | Out-Null; Set-Location M365Advisor-tests; Install-M365AdvisorTests; Write-Host ''; Write-Host '[3/4] Connecting to Microsoft 365...' -ForegroundColor Yellow; Write-Host 'A browser window should open shortly for administrative authentication.' -ForegroundColor Gray; Connect-M365Advisor; Write-Host ''; Write-Host '[4/4] Starting security audit...' -ForegroundColor Yellow; Invoke-M365Advisor; Write-Host ''; Write-Host '=================================================================' -ForegroundColor Green; Write-Host 'Assessment complete!' -ForegroundColor Green; Write-Host 'Your HTML dashboard is generated under M365Advisor-tests\\test-results\\' -ForegroundColor Green; Write-Host '=================================================================' -ForegroundColor Green"
