function Get-MtM365AdvisorApp {
    <#
    .SYNOPSIS
    Retrieves M365Advisor applications from Azure AD/Entra ID.

    .DESCRIPTION
    Retrieves all applications in Azure AD/Entra ID that have been tagged as M365Advisor applications.
    This includes applications created by New-MtM365AdvisorApp or manually tagged with 'm365advisor'.

    .PARAMETER AppId
    If specified, retrieves only the M365Advisor application with the specified Application (Client) ID.

    .PARAMETER Name
    If specified, retrieves only M365Advisor applications with display names containing the specified text.

    .EXAMPLE
    Get-MtM365AdvisorApp

    Retrieves all M365Advisor applications in the tenant.

    .EXAMPLE
    Get-MtM365AdvisorApp -AppId "12345678-1234-1234-1234-123456789012"

    Retrieves the specific M365Advisor application with the given Application ID.

    .EXAMPLE
    Get-MtM365AdvisorApp -Name "DevOps"

    Retrieves all M365Advisor applications that start with "DevOps" in their display name.

    .LINK
    https://m365advisor.dev/docs/commands/Get-MtM365AdvisorApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [CmdletBinding()]
    param(
        # The ID of the M365Advisor app to update
        [Parameter(Mandatory = $true, ParameterSetName = 'ById')]
        [Alias('ObjectId')]
        [string] $Id,

        # The Application (Client) ID of the M365Advisor app to update
        [Parameter(Mandatory = $true, ParameterSetName = 'ByApplicationId')]
        [Alias('ClientId')]
        [string] $AppId,

        # Filter by application display name (starts with)
        # The Application (Client) ID of the M365Advisor app to update
        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [string] $Name
    )

    if (-not (Test-MtAzContext)) {
        return
    }

    Write-Verbose "Searching for M365Advisor applications..."

    $select = "id,appId,displayName,description,tags,createdDateTime,signInAudience"

    if ($Id) {
        # If Id is specified, get the application directly
        Write-Verbose "Getting application with Object ID: $Id"
        $app = Invoke-MtAzureRequest -RelativeUri "applications/$Id" -Method GET -Graph -Select $select
        if ($null -eq $app.id) {
            Write-Warning "No application found with ID '$Id'."
            return
        }
        return Get-M365AdvisorAppInfo -App $app
    } else {
        # Build the filter
        $filters = @()

        # Add AppId filter if specified
        if ($AppId) {
            $filters += "appId eq '$AppId'"
        } else {
            # Filter by the m365advisor tag
            $filters += "tags/any(t:t eq 'm365advisor')"
        }

        # Add Name filter if specified
        if ($Name) {
            $filters += "startswith(displayName, '$Name')"
        }

        $filter = $filters -join ' and '

        Write-Verbose "Query URI: $path"
        $result = Invoke-MtAzureRequest -RelativeUri "applications" -Method GET -Graph -Filter $filter -Select $select

        $apps = $result.value

        if ($apps.Count -eq 0) {
            if ($AppId) {
                Write-Warning "No M365Advisor application found with App ID '$AppId'."
            } elseif ($Name) {
                Write-Warning "No M365Advisor applications found with name containing '$Name'."
            } else {
                Write-Warning "No M365Advisor applications found in this tenant."
                Write-Host "Use New-MtM365AdvisorApp to create a new M365Advisor application." -ForegroundColor Yellow
            }
            return
        }

        # Get service principal information for each app
        foreach ($app in $apps) {
            Get-M365AdvisorAppInfo -App $app
        }
        Write-Verbose "Found $($apps.Count) M365Advisor application(s)"
    }
}

