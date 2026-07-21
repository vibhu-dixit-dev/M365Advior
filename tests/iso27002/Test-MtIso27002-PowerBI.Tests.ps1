##########################################################################
# ISO 27002 / ISO 27002 - Power BI Security Tests
# Ported from M365-Assess: PowerBI/Get-PowerBISecurityConfig.ps1
# Controls: A.5.15, A.5.16, A.8.12, A.8.13, A.8.20, A.8.24
##########################################################################

Describe "ISO 27002 - Power BI Guest Access" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.5.15", "ISO27002:A.5.16", "ISO27002:A.5.15", "ISO27002:A.5.16" {
    BeforeAll {
        $script:pbiCmdAvailable = Get-Command -Name Invoke-PowerBIRestMethod -ErrorAction SilentlyContinue
        $script:allSettings = @()

        if ($script:pbiCmdAvailable) {
            try {
                $tenantSettings = Invoke-PowerBIRestMethod -Url 'admin/tenantSettings' -Method Get -ErrorAction Stop -WarningAction SilentlyContinue | ConvertFrom-Json
                $script:allSettings = if ($tenantSettings -and $tenantSettings.tenantSettings) { @($tenantSettings.tenantSettings) } else { @() }
            } catch {
                # API not accessible or not connected
            }
        }
    }

    # Helper function to get setting value
    function Get-TestTenantSetting {
        param([string]$SettingName)
        $match = $script:allSettings | Where-Object { $_.settingName -eq $SettingName }
        if ($match) { return $match.isEnabled }
        return $null
    }

    It "ISO27002.5.15.2: Guest user directory browsing must be disabled" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $guestLookup = Get-TestTenantSetting -SettingName 'AllowGuestLookup'
        $guestLookup | Should -Be $false -Because "ISO A.5.15 / A.5.16 require restricting guest permissions to browse the organizational directory"
    }

    It "ISO27002.5.16.4: Invite external users permission must be disabled for guests" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $guestInvite = Get-TestTenantSetting -SettingName 'ElevatedGuestsTenant'
        $guestInvite | Should -Be $false -Because "ISO A.5.16 requires restricting guests from inviting other external users"
    }

    It "ISO27002.5.16.5: Guest access to organizational content must be disabled/restricted" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $guestContent = Get-TestTenantSetting -SettingName 'AllowGuestUserToAccessSharedContent'
        $guestContent | Should -Be $false -Because "ISO A.5.16 requires restricting guest access to shared workspaces/content to prevent data exposure"
    }
}

Describe "ISO 27002 - Power BI Content Sharing" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.12", "ISO27002:A.8.13", "ISO27002:A.8.12", "ISO27002:A.8.13" {
    It "ISO27002.8.12.1: Publish to Web (anonymous access) must be disabled" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        # In Power BI API, this is True if disabled (i.e. WebDashboardsPublishToWebDisabled)
        $publishToWebDisabled = Get-TestTenantSetting -SettingName 'WebDashboardsPublishToWebDisabled'
        $publishToWebDisabled | Should -Be $true -Because "ISO A.8.12 / A.8.13 require blocking public publish to web to prevent anonymous exposure of internal reports"
    }

    It "ISO27002.8.13.1: R and Python custom visuals must be disabled" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $rPython = Get-TestTenantSetting -SettingName 'RScriptVisuals'
        $rPython | Should -Be $false -Because "ISO A.8.13 / A.8.20 require disabling unsafe script engines (R/Python) within Power BI dashboards to protect client environments"
    }

    It "ISO27002.8.12.2: Shareable links to entire organization must be disabled" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $shareLinks = Get-TestTenantSetting -SettingName 'ShareLinkToEntireOrg'
        $shareLinks | Should -Be $false -Because "ISO A.8.12 requires restricting broad internal links to prevent unauthorized internal data sharing"
    }

    It "ISO27002.8.12.3: External data sharing receiver collaboration must be disabled" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $extDataSharing = Get-TestTenantSetting -SettingName 'AllowExternalDataSharingReceiverWorksWithShare'
        $extDataSharing | Should -Be $false -Because "ISO A.8.12 / A.8.13 require disabling external data collaboration features to protect organization data boundaries"
    }
}

Describe "ISO 27002 - Power BI Protection & Authentication" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.24", "ISO27002:A.5.15", "ISO27002:A.8.24", "ISO27002:A.5.15" {
    It "ISO27002.8.24.1: Sensitivity labels must be enabled in Power BI" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $sensitivityLabels = Get-TestTenantSetting -SettingName 'UseSensitivityLabels'
        $sensitivityLabels | Should -Be $true -Because "ISO A.8.24 requires sensitivity labeling of assets to ensure consistent information classification and protection policies"
    }

    It "ISO27002.5.15.3: ResourceKey authentication must be blocked" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $blockResKey = Get-TestTenantSetting -SettingName 'BlockResourceKeyAuthentication'
        $blockResKey | Should -Be $true -Because "ISO A.5.15 requires blocking legacy/insecure resource-key authentication patterns"
    }

    It "ISO27002.5.15.4: Service Principal API access must be disabled or restricted" {
        if (-not $script:pbiCmdAvailable -or $script:allSettings.Count -eq 0) {
            Set-ItResult -Skipped -Because "Power BI admin API not connected or not available in this session"
            return
        }

        $spAccess = Get-TestTenantSetting -SettingName 'ServicePrincipalAccess'
        $spAccess | Should -Be $false -Because "ISO A.5.15 requires limiting machine/service access to authorized security groups or disabling it globally"
    }
}
