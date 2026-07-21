<#
.SYNOPSIS
    Copies the M365Advisor tests from ./tests to ./powershell/m365advisor-tests folder to be included in the module.

.DESCRIPTION
    This allows the module to be self-contained and not require the tests to be downloaded separately.

    When developing locally if you wish to use the Install-M365AdvisorTests or Update-M365AdvisorTests functions you will need to run this
    script to copy the tests to the correct location.
#>

param(
    # Force to delete target folder if it exists without confirmation.
    [Parameter(Mandatory = $false)]
    [switch] $Force
)
$sourcePath = Join-Path $PSScriptRoot -ChildPath "../tests"
$destinationPath = Join-Path -Path $PSScriptRoot -ChildPath "../powershell/m365advisor-tests"

if (-not (Test-Path -Path $sourcePath)) {
    Write-Error "The source path $sourcePath does not exist."
    return
}

if (Test-Path -Path $destinationPath) {
    Write-Host "Deleting existing destination folder $destinationPath"
    Remove-Item -Path $destinationPath -Recurse -Force:$Force
}

Write-Host "Creating destination folder $destinationPath"
New-Item -Path $destinationPath -ItemType Directory


Write-Host "Copying M365Advisor tests from $sourcePath to $destinationPath"
Copy-Item -Path $sourcePath\* -Destination $destinationPath -Recurse -Force:$Force

Write-Host "M365Advisor tests copied successfully." -ForegroundColor Green
