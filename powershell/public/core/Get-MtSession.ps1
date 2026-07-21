function Get-MtSession {
    <#
    .SYNOPSIS
    Gets the current M365Advisor session information which includes the current Graph base uri and other details.
    These are read-only and should not be modified directly.

    .DESCRIPTION
    The session information can be used to troubleshoot issues with the M365Advisor module.

    .EXAMPLE
    Get-MtSession

    Returns the current M365Advisor session information.

    .LINK
    https://m365advisor.dev/docs/commands/Get-MtSession
    #>
    [CmdletBinding()]
    param()

    Write-Verbose 'Getting the current M365Advisor session information.'
    Write-Output $__MtSession
}

