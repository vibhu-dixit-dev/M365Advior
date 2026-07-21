function Get-MtM365AdvisorConfigGlobalSetting {
    <#
    .SYNOPSIS
    Gets the global settings from the M365Advisor config.
    .DESCRIPTION
    This function retrieves the value of the specified global setting from the M365Advisor config.
    It returns the value of the specified global setting, which may be of any type depending on the configuration.
    .EXAMPLE
    $globalSettings = Get-MtM365AdvisorConfigGlobalSetting -SettingName 'EmergencyAccessAccounts'
    # This will return the global settings for the setting with name 'EmergencyAccessAccounts'.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # The setting name of the configuration for which to retrieve the settings.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SettingName
    )

    # Check if the M365Advisor config is loaded
    if (-not ($__MtSession -and $__MtSession.M365AdvisorConfig -and $__MtSession.M365AdvisorConfig.GlobalSettings )) {
        Write-Verbose "M365Advisor global config not loaded. Please run Get-MtM365AdvisorConfig first to load the config."
        return $null
    } else {
        Write-Verbose "M365Advisor global config loaded"
        Write-Verbose "M365Advisor global config `"$SettingName`": $($__MtSession.M365AdvisorConfig.GlobalSettings.$SettingName | ConvertTo-Json -Depth 5 -Compress)"
    }

    # Retrieve the test settings from the M365Advisor config
    return $__MtSession.M365AdvisorConfig.GlobalSettings.$SettingName
}

