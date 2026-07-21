$TestsDir = Join-Path $PSScriptRoot "..\tests"
$CisDir = Join-Path $TestsDir "cis"
$Iso27001Dir = Join-Path $TestsDir "iso27001"
$Iso27002Dir = Join-Path $TestsDir "iso27002"

# Ensure dirs exist
if (-not (Test-Path $Iso27001Dir)) { New-Item -Path $Iso27001Dir -ItemType Directory | Out-Null }
if (-not (Test-Path $Iso27002Dir)) { New-Item -Path $Iso27002Dir -ItemType Directory | Out-Null }

# Clear them to make sure we don't have stale files
Remove-Item -Path "$Iso27001Dir\*" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path "$Iso27002Dir\*" -Force -Recurse -ErrorAction SilentlyContinue | Out-Null

$Mappings = @{
    "Test-MtCis365PublicGroup"                          = @("5.15", "5.18")
    "Test-MtCisAdminConsentWorkflowEnabled"             = @("5.16", "5.17", "5.23")
    "Test-MtCisAttachmentFilter"                        = @("8.7")
    "Test-MtCisAttachmentFilterComprehensive"           = @("8.7")
    "Test-MtCisAuditLogSearch"                          = @("5.33", "8.15", "8.16")
    "Test-MtCisCalendarSharing"                         = @("5.14", "5.15")
    "Test-MtCisCloudAdmin"                              = @("5.16", "5.18", "8.2")
    "Test-MtCisCommunicateInitiateExternalTeamsUsers"   = @("5.14")
    "Test-MtCisCommunicateWithUnmanagedTeamsUsers"      = @("5.14")
    "Test-MtCisConnectionFilterSafeList"                = @("8.7", "8.20")
    "Test-MtCisCreateTenantDisallowed"                  = @("5.15", "5.18")
    "Test-MtCisCustomerLockBox"                         = @("5.30", "5.31")
    "Test-MtCisDevicesWithoutCompliancePolicyMarked"    = @("8.1")
    "Test-MtCisDkim"                                    = @("8.20", "8.21")
    "Test-MtCisEnsureGuestAccessRestricted"             = @("5.14", "5.15")
    "Test-MtCisEnsureGuestUserDynamicGroup"             = @("5.15", "5.18")
    "Test-MtCisEnsureUserConsentToAppsDisallowed"       = @("5.16", "5.17")
    "Test-MtCisExoAdditionalStorageProvider"            = @("5.14")
    "Test-MtCisFormsPhishingProtectionEnabled"          = @("8.7")
    "Test-MtCisGlobalAdminCount"                        = @("5.15", "5.16", "8.2")
    "Test-MtCisHostedConnectionFilterPolicy"            = @("8.7", "8.20")
    "Test-MtCisInternalMalwareNotification"             = @("8.7", "8.16")
    "Test-MtCisOutboundSpamFilterPolicy"                = @("8.7", "8.20")
    "Test-MtCisPasswordExpiry"                          = @("5.17")
    "Test-MtCisSafeAntiPhishingPolicy"                  = @("8.7")
    "Test-MtCisSafeAttachment"                          = @("8.7")
    "Test-MtCisSafeAttachmentsAtpPolicy"                = @("8.7")
    "Test-MtCisSafeLink"                                = @("8.7", "8.23")
    "Test-MtCisSharedMailboxSignIn"                     = @("5.16", "5.17")
    "Test-MtCisSpoB2BIntegration"                       = @("5.14", "5.19")
    "Test-MtCisSpoDefaultSharingLink"                   = @("5.14")
    "Test-MtCisSpoDefaultSharingLinkPermission"         = @("5.14", "5.15")
    "Test-MtCisSpoGuestAccessExpiry"                    = @("5.14", "5.15", "5.18")
    "Test-MtCisSpoGuestCannotShareUnownedItem"          = @("5.14", "5.15")
    "Test-MtCisSpoPreventDownloadMaliciousFile"         = @("8.7")
    "Test-MtCisTeamsLobbyBypass"                        = @("5.14", "8.20")
    "Test-MtCisTeamsReportSecurityConcerns"             = @("5.24", "5.26")
    "Test-MtCisThirdPartyAndCustomApps"                 = @("5.21")
    "Test-MtCisThirdPartyApplicationsDisallowed"        = @("5.21")
    "Test-MtCisThirdPartyFileSharing"                   = @("5.14", "5.21")
    "Test-MtCisThirdPartyStorageServicesRestricted"     = @("5.14")
    "Test-MtCisUserOwnedAppsRestricted"                 = @("5.21")
    "Test-MtCisWeakAuthenticationMethodsDisabled"       = @("5.17", "8.5")
    "Test-MtCisZAP"                                     = @("8.7")
}

foreach ($entry in $Mappings.GetEnumerator()) {
    $cisName = $entry.Key
    $controls = $entry.Value
    
    $origFile = Join-Path $CisDir "$cisName.Tests.ps1"
    if (-not (Test-Path $origFile)) {
        Write-Warning "File not found: $origFile"
        continue
    }
    
    $content = [System.IO.File]::ReadAllText($origFile, [System.Text.Encoding]::UTF8)
    
    $remainder = $cisName -replace '^Test-MtCis', ''
    
    # --- ISO 27001 ---
    $iso27001Filename = "Test-MtIso27001-$remainder.Tests.ps1"
    $targetFile27001 = Join-Path $Iso27001Dir $iso27001Filename
    
    $tags27001 = @('"ISO 27001"')
    foreach ($ctrl in $controls) {
        $tags27001 += "`"ISO27001:$ctrl`""
    }
    $tagsStr27001 = $tags27001 -join ", "
    
    # Match the Describe block and tags.
    $descPattern = '(?s)Describe\s+["'']CIS["'']\s+-Tag\s+[^\{]+\{'
    $descRepl27001 = "Describe `"ISO 27001`" -Tag $tagsStr27001 {"
    
    $content27001 = [regex]::Replace($content, $descPattern, $descRepl27001)
    
    # Replace It blocks
    $idCtrls27001 = ($controls | ForEach-Object { "ISO27001.$_" }) -join ", "
    $itPattern = 'It\s+["'']CIS\.M365\.\d+(?:\.\d+)*:\s*'
    $itRepl27001 = 'It "' + $idCtrls27001 + ': '
    $content27001 = [regex]::Replace($content27001, $itPattern, $itRepl27001)
    
    [System.IO.File]::WriteAllText($targetFile27001, $content27001, [System.Text.Encoding]::UTF8)
    
    # --- ISO 27002 ---
    $iso27002Filename = "Test-MtIso27002-$remainder.Tests.ps1"
    $targetFile27002 = Join-Path $Iso27002Dir $iso27002Filename
    
    $tags27002 = @('"ISO 27002"')
    foreach ($ctrl in $controls) {
        $tags27002 += "`"ISO27002:$ctrl`""
    }
    $tagsStr27002 = $tags27002 -join ", "
    
    $descRepl27002 = "Describe `"ISO 27002`" -Tag $tagsStr27002 {"
    $content27002 = [regex]::Replace($content, $descPattern, $descRepl27002)
    
    $idCtrls27002 = ($controls | ForEach-Object { "ISO27002.$_" }) -join ", "
    $itRepl27002 = 'It "' + $idCtrls27002 + ': '
    $content27002 = [regex]::Replace($content27002, $itPattern, $itRepl27002)
    
    [System.IO.File]::WriteAllText($targetFile27002, $content27002, [System.Text.Encoding]::UTF8)
}

Write-Host "ISO tests generated successfully in tests/iso27001 and tests/iso27002!" -ForegroundColor Green
