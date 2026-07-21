function Get-MtM365AdvisorConfigTestSetting {
    <#
    .SYNOPSIS
    Gets the test settings for a specific test ID from the M365Advisor config.
    .DESCRIPTION
    This function retrieves the test settings for a specific test ID from the M365Advisor config.
    It returns the settings as a hashtable, which can be used to customize the behavior of the test.
    .EXAMPLE
    $testSettings = Get-MtM365AdvisorConfigTestSetting -TestId 'Mt.1001'
    # This will return the test settings for the test with ID 'Mt.1001'.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        # The ID of the test for which to retrieve the settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TestId
    )

    # Check if the M365Advisor config is loaded
    if (-not ($__MtSession -and $__MtSession.M365AdvisorConfig)) {
        Write-Verbose "M365Advisor config not loaded. Please run Get-MtM365AdvisorConfig first to get config for TestId: $TestId"
        return $null
    }

    # Retrieve the test settings from the M365Advisor config
    return $__MtSession.M365AdvisorConfig.TestSettingsHash[$TestId]
}

