function Update-M365AdvisorTests {
    <#
    .SYNOPSIS
    Updates the specified folder with the latest ready-made M365Advisor tests built by the M365Advisor team.

    .DESCRIPTION
    The M365Advisor team maintains a repository of ready made tests that can be used to verify the configuration of your Microsoft 365 tenant.

    The tests can be viewed at https://github.com/m365advisor365/m365advisor/tree/main/tests

    .PARAMETER Path
    The path to install or update the M365Advisor tests in.

    .EXAMPLE
    Update-M365AdvisorTests -Path .\m365advisor-tests

    Installs or updates the latest M365Advisor tests in the specified directory.

    .EXAMPLE
    Update-M365AdvisorTests -Path .\

    Install the latest set of M365Advisor tests in the current directory.

    .LINK
    https://m365advisor.dev/docs/commands/Update-M365AdvisorTests
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This command updates multiple tests')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The path to install or update M365Advisor tests in. Defaults to the current directory.
        [Parameter(Mandatory = $false)]
        [string] $Path = '.\',

        # Switch to control the toggling off of the "Are you sure?" prompt
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )
    Write-Verbose 'Checking if newer version is available.'
    Get-IsNewM365AdvisorVersionAvailable | Out-Null

    Write-Verbose "Updating M365Advisor tests in '$Path'."
    Update-MtM365AdvisorTests -Path $Path -Force:$Force
}

