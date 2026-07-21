<#
.SYNOPSIS
    Adds ISO 27001:2022 and ISO 27002:2022 compliance tags to CIS Pester test files.
.DESCRIPTION
    Reads each file line-by-line, finds the Describe line, appends ISO tags before
    the closing brace, and writes back. CRLF line endings are preserved.
    Idempotent - safe to re-run.
#>

$TestsDir = Join-Path $PSScriptRoot "..\tests\cis"

# ISO 27001/27002 control mappings per CIS test
# (ISO 27001 and ISO 27002:2022 share the same Annex A control IDs)
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

$TestFiles = Get-ChildItem -Path $TestsDir -Filter "*.Tests.ps1" -File
$Updated   = 0
$Skipped   = 0
$NotFound  = 0

foreach ($file in $TestFiles) {
    # Get the test name from the filename (strip .Tests.ps1)
    $testName = $file.BaseName -replace '\.Tests$', ''

    if (-not $Mappings.ContainsKey($testName)) {
        Write-Warning "No ISO mapping found for: $testName"
        $NotFound++
        continue
    }

    $controls = $Mappings[$testName]

    # Read lines preserving the raw bytes (to keep CRLF)
    $lines = [System.IO.File]::ReadAllLines($file.FullName, [System.Text.Encoding]::UTF8)

    # Skip if ISO tags already present (idempotent)
    if ($lines | Where-Object { $_ -match '"ISO 27001"' }) {
        Write-Host "  [SKIP] Already tagged: $($file.Name)" -ForegroundColor Yellow
        $Skipped++
        continue
    }

    # Build the ISO tag suffix: , "ISO 27001", "ISO 27002", "ISO27001:5.x", "ISO27002:5.x", ...
    $isoTags = @('"ISO 27001"', '"ISO 27002"')
    foreach ($ctrl in $controls) {
        $isoTags += "`"ISO27001:$ctrl`""
        $isoTags += "`"ISO27002:$ctrl`""
    }
    $isoSuffix = ", " + ($isoTags -join ", ")

    # Find and update the Describe line
    $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*Describe\s+') {
            # The Describe line ends with " {" — insert ISO tags before the " {"
            if ($lines[$i] -match '(.*)\s*\{\s*$') {
                $beforeBrace = $lines[$i].TrimEnd().TrimEnd('{').TrimEnd()
                $lines[$i] = "$beforeBrace$isoSuffix {"
            }
            $found = $true
            break
        }
    }

    if (-not $found) {
        Write-Warning "Could not find Describe line in: $($file.Name)"
        $NotFound++
        continue
    }

    # Write back with CRLF endings (Windows standard for PS1 files)
    $newContent = $lines -join "`r`n"
    [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK]   Updated: $($file.Name)" -ForegroundColor Green
    $Updated++
}

Write-Host ""
Write-Host "Done. Updated: $Updated | Skipped: $Skipped | Not found: $NotFound" -ForegroundColor Cyan
