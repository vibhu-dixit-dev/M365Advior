---
title: Installation guide
---

- Install the **M365Advisor** PowerShell module, Pester, and the out-of-the-box tests.

```powershell
Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser
Install-Module M365Advisor -Scope CurrentUser

md m365advisor-tests
cd m365advisor-tests
Install-M365AdvisorTests
```

- Sign into your Microsoft 365 tenant and run the tests.

```powershell
Connect-M365Advisor
Invoke-M365Advisor
```

## Invoke-M365Advisor

To learn more about the `Invoke-M365Advisor` cmdlet including how to filter tests, and customize the run of the Pester configuration, see the [Invoke-M365Advisor](commands/Invoke-M365Advisor.mdx) documentation.

## Optional modules and permissions

M365Advisor includes optional [CISA](tests/cisa/) tests that require additional permissions and modules to run. These optional tests are skipped if the modules are not installed or there is no active connection.

### Installing Azure, Exchange Online, and Teams modules

```powershell
Install-Module Az.Accounts, ExchangeOnlineManagement, MicrosoftTeams -Scope CurrentUser
```

> The Security & Compliance PowerShell module is dependent on the ExchangeOnlineManagement `Connect-IPPSSession` cmdlet.

### Connecting to Azure, Exchange, and other services

In order to run all the CISA tests, you need to connect to the Azure, Exchange Online, and other modules.

For a more detailed introduction to these concepts see the [Connect-M365Advisor](connect-M365Advisor/readme.md) documentation.

Run the following command to interactively connect to the Azure, Microsoft Graph, Exchange Online, and other modules. A sign-in window will appear for each module.

```powershell
Connect-M365Advisor -Service All
```

### Permissions

Exchange Online implements a [role-based access control model](https://learn.microsoft.com/exchange/permissions-exo/permissions-exo). The controls these cmdlets test require minimum roles of either of the following:

* View-Only Configuration OR
* O365SupportViewConfig

### Installing Azure DevOps PowerShell module

```powershell
Install-Module ADOPS -Scope CurrentUser
```

### Connecting to Azure DevOps

In order to run all the Azure DevOps tests, you need to connect to Azure DevOps.

This is currently not included as part of [Connect-M365Advisor](connect-M365Advisor/readme.md) and must be called separately. Run the following command to interactively connect using the Azure DevOps modules. A sign-in window will appear.

Example with PowerShell variable
```powershell
$AdoPSAllowInsecureAPIs = $true
Import-Module ADOPS
Connect-ADOPS -Organization <Name Of DevOps Organization>
```

Example with ArgumentList
```powershell
Import-Module ADOPS -ArgumentList $true
Connect-ADOPS -Organization <Name Of DevOps Organization>
```

> Note: Some of the API endpoints used for Azure DevOps tests use unsupported endpoints.
To allow usage of unsupported endpoints, you must set `$true` in the argumentlist when importing the module, or set a PowerShell variable called "$AdoPSAllowInsecureAPIs" to `$true` before importing the module.
Reference: https://github.com/AZDOPS/AZDOPS/issues/248

### Permissions

Azure DevOps implements a [role-based access control model](https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions?view=azure-devops&tabs=preview-page). The controls these cmdlets test require the minimum role of:

* Project-Scoped Users at Organization level

## Next Steps

- Monitoring with M365Advisor
  - [Set up M365Advisor on GitHub](monitoring/github.md)
  - [Set up M365Advisor on Azure DevOps](monitoring/azure-devops.md)
  - [Set up M365Advisor on Azure Container App Jobs](monitoring/azure-container-app-job.md)
- Alerting with M365Advisor
  - [Set up M365Advisor email alerts](alerts/email.md)
  - [Set up M365Advisor Teams alerts](alerts/teams.md)
  - [Set up M365Advisor Slack alerts](alerts/slack.md)
- [Writing Custom Tests](writing-tests/index.mdx)

