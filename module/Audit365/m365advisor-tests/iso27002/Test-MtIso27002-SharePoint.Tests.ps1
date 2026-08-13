##########################################################################
# ISO 27002 / ISO 27002 - SharePoint & OneDrive Security Tests
# Ported from M365-Assess: Collaboration/Get-SharePointSecurityConfig.ps1
# Controls: A.5.14, A.8.3, A.8.4, A.8.7, A.8.20
##########################################################################

Describe "ISO 27002 - SharePoint External Sharing" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.5.14", "ISO27002:A.8.3", "ISO27002:A.5.14", "ISO27002:A.8.3" {
    BeforeAll {
        try {
            $script:spoSettings = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/admin/sharepoint/settings' -ErrorAction Stop
        } catch {
            $script:spoSettings = $null
            Write-Warning "SharePoint settings unavailable - ensure SharePointTenantSettings.Read.All is consented"
        }
        try {
            $script:spoSettingsBeta = Invoke-MgGraphRequest -Method GET -Uri '/beta/admin/sharepoint/settings' -ErrorAction Stop
        } catch {
            $script:spoSettingsBeta = $null
        }
    }

    It "ISO27002.5.14.3: SharePoint external sharing must not be set to 'Anyone with link'" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available - requires SharePointTenantSettings.Read.All"
            return
        }
        $sharingCapability = $script:spoSettings['sharingCapability']
        $sharingCapability | Should -Not -Be 'externalUserAndGuestSharing' `
            -Because "ISO A.5.14 requires external sharing to be restricted - 'Anyone with link' allows unauthenticated access to data"
    }

    It "ISO27002.5.14.4: External users must not be able to re-share content" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $script:spoSettings['isResharingByExternalUsersEnabled'] | Should -Be $false `
            -Because "ISO A.5.14 requires controlling information distribution - re-sharing allows uncontrolled propagation of shared content"
    }

    It "ISO27002.5.14.5: Sharing domain restriction must be configured (allow or block list)" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $domainRestriction = $script:spoSettings['sharingDomainRestrictionMode']
        $isRestricted = $domainRestriction -in @('allowList', 'blockList')
        $isRestricted | Should -Be $true `
            -Because "ISO A.5.14 requires limiting external sharing to trusted domains only via allow or block list"
    }

    It "ISO27002.8.3.3: Default sharing link type must be 'Specific people' (not Anyone or Organization)" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $defaultLinkType = $script:spoSettings['defaultSharingLinkType']
        $defaultLinkType | Should -Be 'specificPeople' `
            -Because "ISO A.8.3 requires the default sharing link to require explicit recipient selection - not broad organization or anonymous links"
    }

    It "ISO27002.5.14.6: Guest access expiration must be enabled and set to 30 days or less" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $guestExpRequired = $script:spoSettings['externalUserExpirationRequired']
        $guestExpDays = $script:spoSettings['externalUserExpireInDays']

        $guestExpRequired | Should -Be $true `
            -Because "ISO A.5.14 requires guest access to expire - permanent guest access creates unnecessary long-term risk"

        if ($guestExpRequired) {
            $guestExpDays | Should -BeLessOrEqual 30 `
                -Because "ISO A.5.14 requires guest access expiration to be 30 days or less to minimize exposure"
        }
    }

    It "ISO27002.8.3.4: Default sharing link permission must be 'View' (not Edit)" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $defaultPerm = $script:spoSettings['defaultLinkPermission']
        $defaultPerm | Should -Be 'view' `
            -Because "ISO A.8.3 requires the principle of least privilege - default sharing should grant read-only access"
    }
}

Describe "ISO 27002 - SharePoint Authentication & Access" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.20", "ISO27002:A.8.4", "ISO27002:A.8.20", "ISO27002:A.8.4" {
    BeforeAll {
        if (-not $script:spoSettings) {
            try { $script:spoSettings = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/admin/sharepoint/settings' -ErrorAction Stop } catch { $script:spoSettings = $null }
        }
    }

    It "ISO27002.8.20.3: Legacy authentication protocols must be disabled in SharePoint" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $legacyAuth = $script:spoSettings['isLegacyAuthProtocolsEnabled']
        if ($null -eq $legacyAuth) {
            Set-ItResult -Skipped -Because "isLegacyAuthProtocolsEnabled property not returned by this tenant's Graph API"
            return
        }
        $legacyAuth | Should -Be $false `
            -Because "ISO A.8.20 requires disabling legacy authentication - it bypasses MFA and modern conditional access policies"
    }

    It "ISO27002.8.4.1: OneDrive/SharePoint sync from unmanaged devices must be blocked" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $unmanagedSync = $script:spoSettings['isUnmanagedSyncClientRestricted']
        $unmanagedSync | Should -Be $true `
            -Because "ISO A.8.4 requires restricting data sync to managed, compliant devices only"
    }

    It "ISO27002.8.4.2: Idle session timeout policy must be configured" {
        if (-not $script:spoSettings) {
            Set-ItResult -Skipped -Because "SharePoint settings not available"
            return
        }
        $idlePolicy = $null
        try {
            $idlePolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/activityBasedTimeoutPolicies' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "ActivityBasedTimeoutPolicies permission not granted"
                return
            }
            throw
        }
        $hasPolicy = $idlePolicy -and $idlePolicy['value'] -and @($idlePolicy['value']).Count -gt 0
        $hasPolicy | Should -Be $true `
            -Because "ISO A.8.4 requires automatic session termination after inactivity to prevent unauthorized access to unattended sessions"
    }
}

Describe "ISO 27002 - SharePoint Malware Protection" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.7", "ISO27002:A.8.7" {
    BeforeAll {
        if (-not $script:spoSettingsBeta) {
            try { $script:spoSettingsBeta = Invoke-MgGraphRequest -Method GET -Uri '/beta/admin/sharepoint/settings' -ErrorAction Stop } catch { $script:spoSettingsBeta = $null }
        }
    }

    It "ISO27002.8.7.1: Infected file download must be blocked in SharePoint/OneDrive" {
        if (-not $script:spoSettingsBeta -or $null -eq $script:spoSettingsBeta['disallowInfectedFileDownload']) {
            Set-ItResult -Skipped -Because "Beta SharePoint settings not available or property not returned"
            return
        }
        $script:spoSettingsBeta['disallowInfectedFileDownload'] | Should -Be $true `
            -Because "ISO A.8.7 requires preventing download of files detected as infected by Safe Attachments scanning"
    }

    It "ISO27002.5.14.7: SharePoint/OneDrive B2B integration must be enabled for Entra-managed guest access" {
        if (-not $script:spoSettingsBeta -or $null -eq $script:spoSettingsBeta['isB2BIntegrationEnabled']) {
            Set-ItResult -Skipped -Because "Beta SharePoint settings not available or property not returned"
            return
        }
        $script:spoSettingsBeta['isB2BIntegrationEnabled'] | Should -Be $true `
            -Because "ISO A.5.14 requires guest access to be managed through Entra B2B for proper identity governance and MFA enforcement"
    }
}
