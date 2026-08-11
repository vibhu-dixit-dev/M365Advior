Import-Module Audit365 -RequiredVersion 1.0.6 -Force
$h = Get-Help Test-MtEidscaAF03
Write-Host "Synopsis: $($h.synopsis)"
Write-Host "Description: $($h.description.Text)"
