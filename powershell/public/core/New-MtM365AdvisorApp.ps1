function New-MtM365AdvisorApp {
    <#
    .SYNOPSIS
    Creates a new M365Advisor application in Entra ID with required permissions.

    .DESCRIPTION
    Creates a new application registration in Entra ID specifically configured for running
    M365Advisor tests in a DevOps pipeline. The application will be granted the necessary Graph API
    permissions based on the specified parameters and tagged for easy identification.

    The user running this command must have a permissions to create applications and consent to Graph Permissions.
    This requires a minimum of being a Privileged Role Administrator (and Cloud Application Administrator if needed) or Global Administrator.

    .PARAMETER Name
    The display name for the application. If not specified, defaults to 'M365Advisor DevOps Account'.

    .PARAMETER SendMail
    If specified, includes the Mail.Send permission scope.

    .PARAMETER SendTeamsMessage
    If specified, includes the ChannelMessage.Send permission scope.

    .PARAMETER Privileged
    If specified, includes privileged permission scopes for read-write operations.

    .PARAMETER Scopes
    Additional custom permission scopes to include beyond the default M365Advisor scopes.

    .PARAMETER GitHubOrganization
    Your GitHub organization name or GitHub username (e.g. 'jasonf'). When supplied
    together with -GitHubRepository the cmdlet will also create a federated identity
    credential for GitHub Actions OIDC.

    .PARAMETER GitHubRepository
    Your GitHub repository name where the workflow lives (e.g. 'm365advisor-tests').

    .PARAMETER GitHubActions
    Enable end-to-end GitHub Actions setup. Creates a federated identity credential
    after granting permissions, and auto-detects the GitHub organization/repository
    from the local git remote ('origin') when -GitHubOrganization/-GitHubRepository
    are not explicitly supplied. This is the recommended entry point for the GitHub
    flow.

    .PARAMETER SetGitHubSecrets
    Pushes AZURE_CLIENT_ID and AZURE_TENANT_ID to the target repository's Actions
    secrets via the GitHub CLI ('gh'). Falls back to printing manual instructions
    when 'gh' is unavailable or not authenticated. Passing -SetGitHubSecrets on its
    own implicitly enables the GitHub Actions flow, so -GitHubActions does not need
    to be specified alongside it.

    .EXAMPLE
    New-MtM365AdvisorApp

    Creates a new M365Advisor app with default permissions and name 'M365Advisor DevOps Account'.

    .EXAMPLE
    New-MtM365AdvisorApp -Name "My M365Advisor Pipeline App" -SendMail

    Creates a new M365Advisor app with mail sending capabilities.

    .EXAMPLE
    New-MtM365AdvisorApp -Privileged -Scopes @("User.Read.All", "Group.Read.All")

    Creates a new M365Advisor app with privileged scopes and additional custom scopes.

    .EXAMPLE
    New-MtM365AdvisorApp -GitHubActions -SetGitHubSecrets

    Full zero-config GitHub Actions setup. Auto-detects the target repository from
    the current git remote, creates the app, grants permissions, adds the federated
    credential, and pushes the AZURE_CLIENT_ID / AZURE_TENANT_ID secrets via gh CLI.

    .LINK
    https://m365advisor.dev/docs/commands/New-MtM365AdvisorApp
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Colors are beautiful')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'TODO: Implement ShouldProcess')]
    [CmdletBinding()]
    param(
        # The display name for the application
        [string] $Name,

        # Include Mail.Send permission scope
        [switch] $SendMail,

        # Include ChannelMessage.Send permission scope
        [switch] $SendTeamsMessage,

        # Include privileged permission scopes
        [switch] $Privileged,

        # Additional custom permission scopes
        [string[]] $Scopes = @(),

        # If specified adds federated credential for GitHub Actions
        # Your GitHub organization name or GitHub username. E.g. jasonf
        [string] $GitHubOrganization,

        # Your GitHub repository name where the GitHub Actions workflow is located. E.g. m365advisor-tests
        [string] $GitHubRepository,

        # Enable end-to-end GitHub Actions setup (creates a federated identity credential).
        # Auto-detects -GitHubOrganization/-GitHubRepository from the local git remote when
        # they are not explicitly provided.
        [switch] $GitHubActions,

        # Together with -GitHubActions, push AZURE_CLIENT_ID/AZURE_TENANT_ID to the repo's
        # Actions secrets via the GitHub CLI ('gh').
        [switch] $SetGitHubSecrets
    )

    # We use the Azure module to create the app registration since it has pre-consented permissions to create apps
    # M365Advisor is meant for read-only access, so we don't want users to consent to Application.ReadWrite.All or similar.
    # Instead, we create the app using the Az module context and then assign only the minimum required permissions.
    # This also avoids needing admin consent during Connect-MgGraph.
    if (-not (Test-MtAzContext)) {
        return
    }

    # Treat any GitHub-flow parameter as opting into the GitHub Actions path.
    $useGitHubFlow = $GitHubActions -or $SetGitHubSecrets -or $GitHubOrganization -or $GitHubRepository

    if ($useGitHubFlow) {
        # Auto-detect from local git remote only when BOTH are omitted. Mixing an explicit
        # value with auto-detection of the other is ambiguous (which repo did the caller
        # really mean?) so we require both-or-neither.
        if (-not $GitHubOrganization -and -not $GitHubRepository) {
            $detected = Get-MtGitHubRepoFromGit
            if ($detected) {
                $GitHubOrganization = $detected.Organization
                $GitHubRepository   = $detected.Repository
                Write-Host "Auto-detected GitHub repository from git remote: $GitHubOrganization/$GitHubRepository" -ForegroundColor Cyan
            }
        } elseif (-not $GitHubOrganization -or -not $GitHubRepository) {
            Write-Error "Specify both -GitHubOrganization and -GitHubRepository, or omit both to auto-detect from the local git remote."
            return
        }

        if (-not $GitHubOrganization -or -not $GitHubRepository) {
            Write-Error "Both GitHubOrganization and GitHubRepository must be specified to add a federated credential. They can be auto-detected when the current directory is a git working tree whose 'origin' remote points at GitHub."
            return
        }
    }

    if (-not $Name) {
        if($GitHubOrganization -and $GitHubRepository) {
            $Name = "M365Advisor DevOps Account - $GitHubOrganization/$GitHubRepository"
        } else {
            $Name = "M365Advisor DevOps Account"
        }
    }

    $existingApps = Get-MtM365AdvisorApp -WarningAction SilentlyContinue
    $appCount = ($existingApps | Measure-Object).Count
    if ($appCount -gt 0) {
        Write-Warning "We found $appCount M365Advisor application(s) in this tenant."
        $existingApps

        $confirmation = Read-Host "Create a new M365Advisor application anyway? (y/N)"
        if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
            Write-Host "Update cancelled." -ForegroundColor Yellow
            return
        }
    }

    Write-Host "Creating new M365Advisor application: $Name" -ForegroundColor Green

    # Create the application
    $appBody = @{
        displayName = $Name
        description = "Application created by M365Advisor for running security assessments in DevOps pipelines"
        tags        = @('m365advisor')
    } | ConvertTo-Json -Depth 3

    Write-Verbose "Creating application with body: $appBody"
    $app = Invoke-MtAzureRequest -RelativeUri 'applications' -Method POST -Payload $appBody -Graph

    Write-Host "✅ Application created successfully" -ForegroundColor Green
    Write-Host "   Application ID: $($app.appId)" -ForegroundColor Cyan
    Write-Host "   Object ID: $($app.id)" -ForegroundColor Cyan

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

    # Create a service principal for the app
    $spBody = @{
        appId = $app.appId
        tags  = @("m365advisor")
    } | ConvertTo-Json

    Write-Host "Creating service principal..." -ForegroundColor Yellow
    $servicePrincipal = Invoke-MtAzureRequest -RelativeUri "servicePrincipals" -Method POST -Payload $spBody -Graph
    Write-Host "✅ Service principal created successfully" -ForegroundColor Green
    Write-Host "   Service Principal ID: $($servicePrincipal.id)" -ForegroundColor Cyan

    # Set the permissions
    Write-Host "Configuring permissions..." -ForegroundColor Yellow
    Write-Verbose "Required scopes: $($requiredScopes -join ', ')"

    $permissionsGranted = $true
    try {
        Set-M365AdvisorAppPermission -AppId $app.appId -Scopes $requiredScopes
    } catch {
        $permissionsGranted = $false
        Write-Host "❌ $($_.Exception.Message)" -ForegroundColor Red
    }

    $result = Get-MtM365AdvisorApp -Id $app.id

    Write-Host ""
    if ($permissionsGranted) {
        Write-Host "🎉 M365Advisor application created successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ M365Advisor application was created but some permissions could not be granted." -ForegroundColor Red
        Write-Host "   The application is in a non-functional state until all required permissions are consented." -ForegroundColor Yellow
        Write-Host "   Ensure the account running New-MtM365AdvisorApp has Privileged Role Administrator or Global Administrator rights." -ForegroundColor Yellow
    }

    if ($useGitHubFlow) {
        $ficParams = @{
            AppId               = $app.appId
            GitHubOrganization  = $GitHubOrganization
            GitHubRepository    = $GitHubRepository
        }
        if ($SetGitHubSecrets) { $ficParams['SetGitHubSecrets'] = $true }
        Add-MtM365AdvisorAppFederatedCredential @ficParams
    } else {
        Write-Output $result
    }
}

