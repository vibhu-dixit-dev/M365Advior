Import-Module Audit365 -RequiredVersion 1.0.6 -Force
& (Get-Module Audit365) {
    $cmd = Get-Command Test-MtEidscaAF03
    $h = Get-Help $cmd
    Write-Host "h.synopsis:    '$($h.synopsis)'"
    Write-Host "h.description: '$($h.description | Out-String)'"
}
