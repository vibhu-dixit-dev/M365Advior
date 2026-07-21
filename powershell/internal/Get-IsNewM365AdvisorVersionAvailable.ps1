function Get-IsNewM365AdvisorVersionAvailable {
    <#
    .SYNOPSIS
        Checks the PowerShell Gallery for a newer version of the M365Advisor module and displays a message if a newer version is available.

    .DESCRIPTION
        Compares the installed version of the M365Advisor module with the latest version available on the PowerShell Gallery.
        This is useful to let the user know if there are newer versions with updates and bug fixes.
        The function returns $true if a newer version is available, otherwise $false.

    .EXAMPLE
        Get-IsNewM365AdvisorVersionAvailable
    #>

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [OutputType([bool])]
    param()

    function ConvertTo-ComparableVersion {
        param(
            [Parameter(Mandatory = $true)]
            [AllowNull()]
            [object] $InputVersion
        )

        if ($null -eq $InputVersion) {
            return $null
        }

        if ($InputVersion -is [version]) {
            return $InputVersion
        }

        $versionString = [string]$InputVersion
        if ([string]::IsNullOrWhiteSpace($versionString)) {
            return $null
        }

        # Normalize prerelease-like strings to comparable version values.
        $numericVersion = $versionString -replace '-.*$', ''

        try {
            return [version]$numericVersion
        } catch {
            Write-Verbose -Message "Could not parse current module version '$InputVersion' (numeric: '$numericVersion')."
            return $null
        }
    }

    try {
        $currentVersion = ConvertTo-ComparableVersion -InputVersion (Get-MtModuleVersion)
        $latestVersion = Get-MtLatestModuleVersion -Name M365Advisor -TimeoutSec 10

        if ($null -eq $currentVersion) {
            Write-Verbose -Message 'Unable to determine installed M365Advisor version.'
            return $false
        }

        if ($null -ne $latestVersion -and $currentVersion -lt $latestVersion) {
            Write-Host '🔥 FYI: A newer version of M365Advisor is available! Run the commands below to update to the latest version.'
            Write-Host "💥 Installed version: $currentVersion → Latest version: $latestVersion" -ForegroundColor DarkGray
            Write-Host '✨ Update-Module M365Advisor' -NoNewline -ForegroundColor Green
            Write-Host ' → Install the latest version of M365Advisor.' -ForegroundColor Yellow
            Write-Host '💫 Update-M365AdvisorTests' -NoNewline -ForegroundColor Green
            Write-Host ' → Get the latest tests built by the M365Advisor team and community.' -ForegroundColor Yellow
            return $true
        }
    } catch { Write-Verbose -Message $_ }
    return $false
}

