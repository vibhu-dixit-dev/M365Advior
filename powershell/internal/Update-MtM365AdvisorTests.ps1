function Update-MtM365AdvisorTests {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'This command updates multiple tests')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The path to install the M365Advisor tests to, defaults to the current directory.
        [Parameter(Mandatory = $true)]
        [string] $Path,

        # Defaults to update, used to show the correct message as 'installed' or 'updated'.
        [Parameter(Mandatory = $false)]
        [switch] $Install,

        # Switch to control the toggling off of the "Are you sure?" prompt
        [Parameter(Mandatory = $false)]
        [switch] $Force
    )

    $M365AdvisorTestsPath = Get-MtM365AdvisorTestFolderPath
    if (-not (Test-Path -Path $M365AdvisorTestsPath -PathType Container)) {
        Write-Error "M365Advisor tests not found at $M365AdvisorTestsPath"
        return
    }

    $M365AdvisorTests = (Get-ChildItem -Path $M365AdvisorTestsPath -Exclude 'Custom').Name

    $targetFolderExists = (Test-Path -Path $Path -PathType Container)
    if (-not $targetFolderExists) {
        Write-Verbose "Creating directory $([System.IO.Path]::GetFullPath($Path))"
        try {
            New-Item -Path $Path -ItemType Directory | Out-Null
        } catch {
            Write-Error "Unable to create directory $([System.IO.Path]::GetFullPath($Path))"
            Write-Verbose $_
            return
        }
    }

    $installOrUpdate = if ($Install) { 'installed' } else { 'updated' }

    if ($targetFolderExists) {
        # Check if the folder already exists and prompt user to confirm overwrite.
        $itemsToDelete = Get-ChildItem -Path $Path | Where-Object { $_.Name -in $($M365AdvisorTests) }

        if ($itemsToDelete.Count -gt 0) {
            $message = "`nThe following items will be deleted when installing the latest M365Advisor tests:`n"
            $itemsToDelete | ForEach-Object { $message += "  $($_.FullName)`n" }

            # Display prompt unless Force has been explicitly set
            if (!$Force) {
                $message += 'Do you want to continue? (y/n): '
                $continue = Get-MtConfirmation $message
            }

            # Continue if either user has accepted prompt, or Force has been explicitly set
            if ($continue -or $Force) {
                foreach ($item in $itemsToDelete) {
                    if ($item.Attributes -ne 'Directory') {
                        Remove-Item -Path $item.FullName -Force
                    } else {
                        Remove-Item -Path $item.FullName -Recurse -Force
                    }
                }
            } else {
                Write-Host "M365Advisor tests not $installOrUpdate." -ForegroundColor Red
                return
            }
        }
    }

    try {
        Write-Verbose "Copying M365Advisor tests from $M365AdvisorTestsPath/* to $Path"
        Copy-Item -Path $M365AdvisorTestsPath/* -Destination $Path -Recurse -Force
    } catch {
        Write-Error "Unable to copy the M365Advisor tests to $Path."
        Write-Verbose $_
        return
    }

    $message = "Run `Connect-M365Advisor` to sign in and then run `Invoke-M365Advisor` to start testing."
    #if (Get-MgContext) { #ToAdjust: Issue with -SkipGraphConnect
    if (Test-MtConnection Graph) {
        $message = 'Run Invoke-M365Advisor to start testing.'
    }

    Write-Host "M365Advisor tests $installOrUpdate successfully!`n$message" -ForegroundColor Green
}

