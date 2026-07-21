function Update-MtM365AdvisorApp {
    <#
    .SYNOPSIS
    Updates an existing M365Advisor application with the latest required permissions.

    .DESCRIPTION
    Updates an existing M365Advisor application in Azure AD/Entra ID with the current set of required
    Graph API permissions. This is useful when new permissions are added to M365Advisor and existing
    applications need to be updated to include them.

    .PARAMETER ApplicationId
    The Application (Client) ID of the existing M365Advisor application to update.

    .PARAMETER SendMail
    If specified, includes the Mail.Send permission scope.

    .PARAMETER SendTeamsMessage
    If specified, includes the ChannelMessage.Send permission scope.

    .PARAMETER Privileged
    If specified, includes privileged permission scopes for read-write operations.

    .PARAMETER Scopes
    Additional custom permission scopes to include beyond the default M365Advisor scopes.

    .EXAMPLE
    Update-MtM365AdvisorApp -AppId "12345678-1234-1234-1234-123456789012"

    Updates the specified M365Advisor app with the current default permissions.

    .EXAMPLE
    Update-MtM365AdvisorApp -AppId "12345678-1234-1234-1234-123456789012" -SendMail -Privileged

    Updates the specified M365Advisor app with mail sending and privileged capabilities.

    .EXAMPLE
    Update-MtM365AdvisorApp -AppId "12345678-1234-1234-1234-123456789012" -Scopes @("User.Read.All")

    Updates the specified M365Advisor app with additional custom scopes.

    .LINK
    https://m365advisor.dev/docs/commands/Update-MtM365AdvisorApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
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

        # Include Mail.Send permission scope
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $SendMail,

        # Include ChannelMessage.Send permission scope
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $SendTeamsMessage,

        # Include privileged permission scopes
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [ValidateSet('ById', 'ByApplicationId')]
        [switch] $Privileged,

        # Additional custom permission scopes
        [Parameter(Mandatory = $false, ParameterSetName = 'ById')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApplicationId')]
        [string[]] $Scopes = @()
    )

    process {
        if (-not (Test-MtAzContext)) {
            return
        }
        try {

            if ($Id) {
                $app = Get-MtM365AdvisorApp -Id $Id -ErrorAction Stop
                if (-not $app) {
                    Write-Error "M365Advisor application with ID '$Id' not found. Use Get-MtM365AdvisorApp to find existing M365Advisor applications."
                    return
                }
                $AppId = $app.appId
            } else {
                # Find the application by AppId
                $appFilter = "appId eq '$AppId'"
                $result = Invoke-MtAzureRequest -RelativeUri 'applications' -Filter $appFilter -Method GET -Graph
                $apps = $result.value
                if ($apps.Count -eq 0) {
                    Write-Error "Application with ID '$AppId' not found. Use Get-MtM365AdvisorApp to find existing M365Advisor applications."
                    return
                }

                $app = $apps[0]
            }

            Write-Host "✅ Found application: $($app.displayName)" -ForegroundColor Green

            # Verify this is a M365Advisor app
            if ($app.tags -notcontains "m365advisor") {
                Write-Warning "Application '$($app.displayName)' does not have the 'm365advisor' tag. Do you want to tag this as a M365Advisor application?"
                $confirmation = Read-Host "Do you want to continue? (y/N)"
                if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
                    Write-Host "Update cancelled." -ForegroundColor Yellow
                    return
                }
            }

            # Get the required scopes
            $scopeParams = @{}
            if ($SendMail) { $scopeParams['SendMail'] = $true }
            if ($SendTeamsMessage) { $scopeParams['SendTeamsMessage'] = $true }
            if ($Privileged) { $scopeParams['Privileged'] = $true }

            $requiredScopes = Get-MtGraphScope @scopeParams

            # Add any additional custom scopes
            if ($Scopes) {
                $requiredScopes += $Scopes
                $requiredScopes = $requiredScopes | Sort-Object -Unique
            }

            Write-Host "Updating permissions..." -ForegroundColor Yellow
            Write-Verbose "Required scopes: $($requiredScopes -join ', ')"

            # Set the permissions
            Set-M365AdvisorAppPermission -AppId $app.appId -Scopes $requiredScopes

            # Update the application tags and description
            $updateBody = @{
                tags        = @("m365advisor")
                description = "Application created by M365Advisor for running security assessments in DevOps pipelines"
            } | ConvertTo-Json

            Write-Host "Updating application metadata..." -ForegroundColor Yellow
            Invoke-MtAzureRequest -RelativeUri "applications/$($app.id)" -Method PATCH -Payload $updateBody -Graph | Out-Null
            Write-Host "✅ Application metadata updated successfully" -ForegroundColor Green

            # Output the result
            $result = Get-M365AdvisorAppInfo -App $app

            Write-Host ""
            Write-Host "🎉 M365Advisor application updated successfully!" -ForegroundColor Green

            return $result

        } catch {
            Write-Error "Failed to update M365Advisor application: $($_.Exception.Message)"
            throw
        }
    }
}

