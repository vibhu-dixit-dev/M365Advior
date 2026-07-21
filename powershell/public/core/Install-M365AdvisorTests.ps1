function Install-M365AdvisorTests {
    <#
    .SYNOPSIS
    Installs the latest ready-made M365Advisor tests built by the M365Advisor team and the required Pester module.

    .DESCRIPTION
    The M365Advisor team maintains a repository of ready made tests that can be used to verify the configuration of your Microsoft 365 tenant.

    The tests can be viewed at https://github.com/m365advisor365/m365advisor/tree/main/tests

    .PARAMETER Path
    The path to install the M365Advisor tests in. Defaults to the current directory.

    .PARAMETER SkipPesterCheck
    Skips the automatic installation check for Pester.

    .PARAMETER Force
    Forces the installation and overwrites existing test files without prompting.

    .EXAMPLE
    Install-M365AdvisorTests

    Install the latest set of M365Advisor tests in the current directory and installs the Pester module if needed.

    .EXAMPLE
    Install-M365AdvisorTests -Path .\m365advisor-tests

    Installs the latest M365Advisor tests in the specified directory and installs the Pester module if needed.

    .EXAMPLE
    Install-M365AdvisorTests -SkipPesterCheck

    Installs the latest M365Advisor tests in the current directory. Skips the check for the required version of Pester.

    .LINK
    https://m365advisor.dev/docs/commands/Install-M365AdvisorTests
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This command updates multiple tests')]
    [CmdletBinding()]
    param(
        # The path to install the M365Advisor tests to, defaults to the current directory.
        [Parameter(Mandatory = $false)]
        [string] $Path = ".\",

        # Skip automatic installation of Pester
        [Parameter(Mandatory = $false)]
        [switch] $SkipPesterCheck,

        # Force the installation and overwrite of tests without prompting
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    # Note: If testing this locally in dev, you will need to run ./build/Copy-M365AdvisorTestsToPSModule.ps1 to copy the tests to the correct location.
    # This script is automatically run during the build process to embed the tests into the PowerShell module.

    [version]$MinPesterVersion = '5.5.0'
    # The default action installs the minimum required version of Pester if not present. Opt out with -SkipPesterCheck.
    if ( $PSBoundParameters.ContainsKey('SkipPesterCheck') ) {
        Write-Verbose "Skipping Pester version check."
    } else {
        if ( ((Get-Module -Name 'Pester' -ListAvailable).Version | Sort-Object -Descending | Select-Object -First 1) -lt $MinPesterVersion ) {
            Write-Host "The minimum required version of Pester is not installed." -ForegroundColor Yellow
            Write-Host "Installing Pester version $MinPesterVersion..." -ForegroundColor Yellow
            Install-Module -Name 'Pester' -MinimumVersion $MinPesterVersion -SkipPublisherCheck -Force -Scope CurrentUser
            Import-Module -Name 'Pester'
        } else {
            Write-Verbose "The minimum required version of Pester is already installed."
        }
    }

    Get-IsNewM365AdvisorVersionAvailable | Out-Null

    Write-Verbose "Installing M365Advisor tests to $Path"

    $targetFolderExists = (Test-Path -Path $Path -PathType Container)


    # Check if current folder is empty and prompt user to continue if it is not
    if ($targetFolderExists -and (Get-ChildItem -Path $Path).Count -gt 0) {
        if (!$Force) {
            $message = "`nThe folder $Path is not empty.`nWe recommend installing the tests in an empty folder.`nDo you want to continue with this folder? (y/n): "
            $continue = Get-MtConfirmation $message
            if (!$continue) {
                Write-Host "M365Advisor tests not installed." -ForegroundColor Red
                return
            }
        }
    }

    Update-MtM365AdvisorTests -Path $Path -Install -Force:$Force
}

