@echo off

echo ================================================
echo M365 Advisor - Dependency Test
echo ================================================
echo.

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NoExit -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; Write-Host 'PowerShell started' -ForegroundColor Green; Write-Host ''; Write-Host 'Checking Az.Accounts...' -ForegroundColor Yellow; $az=Get-Module Az.Accounts -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1; if(-not $az){throw 'Az.Accounts is NOT installed.'}; Write-Host ('Az.Accounts version: '+$az.Version) -ForegroundColor Green; Import-Module Az.Accounts -Force; Write-Host ''; Write-Host 'Checking Get-AzContext...' -ForegroundColor Yellow; Get-Command Get-AzContext -ErrorAction Stop | Format-Table Name,CommandType,Source -AutoSize; Write-Host 'Get-AzContext: OK' -ForegroundColor Green; Write-Host ''; Write-Host 'Checking PnP.PowerShell...' -ForegroundColor Yellow; $pnp=Get-Module PnP.PowerShell -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1; if(-not $pnp){throw 'PnP.PowerShell is NOT installed.'}; Write-Host ('PnP.PowerShell version: '+$pnp.Version) -ForegroundColor Green; Write-Host ''; Write-Host 'Checking Invoke-M365Advisor parameters...' -ForegroundColor Yellow; $cmd=Get-Command Invoke-M365Advisor -ErrorAction Stop; $cmd.Parameters.Keys | Sort-Object; Write-Host ''; if($cmd.Parameters.ContainsKey('Tag')){Write-Host 'Tag parameter: AVAILABLE' -ForegroundColor Green}else{Write-Host 'Tag parameter: NOT AVAILABLE' -ForegroundColor Red}; Write-Host ''; Write-Host 'Checking Connect-M365Advisor parameters...' -ForegroundColor Yellow; (Get-Command Connect-M365Advisor).Parameters.Keys | Sort-Object; Write-Host ''; Read-Host 'Press ENTER to close'"

echo.
echo PowerShell process ended.
pause