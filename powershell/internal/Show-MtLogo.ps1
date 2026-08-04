function Show-MtLogo {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [OutputType([string])]
    param ()

    $manifestFile = Get-ChildItem -Path $PSScriptRoot -Filter "*.psd1" | Select-Object -First 1
    if (-not $manifestFile) { $manifestFile = Get-ChildItem -Path (Join-Path $PSScriptRoot "..") -Filter "*.psd1" | Select-Object -First 1 }
    $Version = if ($manifestFile) { (Import-PowerShellDataFile -Path $manifestFile.FullName).ModuleVersion } else { "1.0.0" }
    # ASCII Art using style "ANSI Shadow"
    $Logo = @"

    ███╗   ███╗██████╗  ██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗██╗███████╗ ██████╗ ██████╗ 
    ████╗ ████║╚════██╗██╔════╝ ██╔════╝██╔══██╗██╔══██╗██║   ██║██║██╔════╝██╔═══██╗██╔══██╗
    ██╔████╔██║ █████╔╝███████╗ ███████╗███████║██║  ██║██║   ██║██║███████╗██║   ██║██████╔╝
    ██║╚██╔╝██║ ╚═══██╗██╔═══██╗╚════██║██╔══██║██║  ██║╚██╗ ██╔╝██║╚════██║██║   ██║██╔══██╗
    ██║ ╚═╝ ██║██████╔╝╚██████╔╝███████║██║  ██║██████╔╝ ╚████╔╝ ██║███████║╚██████╔╝██║  ██║
    ╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ v$Version

"@

    Write-Host $Logo -ForegroundColor Green
}

