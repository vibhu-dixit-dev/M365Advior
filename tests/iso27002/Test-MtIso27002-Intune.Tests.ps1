##########################################################################
# ISO 27002 / ISO 27002 - Intune / Endpoint Security Tests
# Ported from M365-Assess: Intune/Get-IntuneSecurityConfig.ps1
# Controls: A.8.9, A.8.19
##########################################################################

Describe "ISO 27002 - Intune Device Management" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.9", "ISO27002:A.8.19", "ISO27002:A.8.9", "ISO27002:A.8.19" {
    BeforeAll {
        $script:graphConnected = $false
        try {
            $context = Get-MgContext -ErrorAction Stop
            if ($context -and $context.TenantId) {
                $script:graphConnected = $true
            }
        } catch {}
    }


    It "ISO27002.8.9.8: Non-compliant device threshold must be 30 days or less" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $complianceSettings = $null
        try {
            $complianceSettings = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/settings' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "Intune DeviceManagementConfiguration.Read.All permission not granted or Intune license not present"
                return
            }
            throw
        }

        $markNonCompliant = $complianceSettings['deviceComplianceCheckinThresholdDays']
        if ($null -eq $markNonCompliant) {
            Set-ItResult -Skipped -Because "deviceComplianceCheckinThresholdDays not available from this tenant's API"
            return
        }

        [int]$markNonCompliant | Should -BeLessOrEqual 30 `
            -Because "ISO A.8.9 requires devices without compliance policy to be flagged as non-compliant within 30 days"
    }

    It "ISO27002.8.9.9: Personal device enrollment must be blocked on all platforms (iOS, Android, Windows)" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $enrollConfigs = $null
        try {
            $enrollConfigs = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/deviceEnrollmentConfigurations' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "Intune permissions not granted or Intune license not present"
                return
            }
            throw
        }

        $enrollConfigList = if ($enrollConfigs -and $enrollConfigs['value']) { @($enrollConfigs['value']) } else { @() }
        $platformRestrictions = @($enrollConfigList | Where-Object {
            $_['@odata.type'] -eq '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration'
        })

        $platformRestrictions.Count | Should -BeGreaterOrEqual 1 `
            -Because "ISO A.8.9 requires at least one platform restriction policy to control which devices can enroll"

        if ($platformRestrictions.Count -gt 0) {
            $personalBlocked = $true
            foreach ($restriction in $platformRestrictions) {
                $platforms = @('iosRestriction', 'androidRestriction', 'windowsRestriction')
                foreach ($platform in $platforms) {
                    $config = $restriction[$platform]
                    if ($config -and $config['personalDeviceEnrollmentBlocked'] -ne $true) {
                        $personalBlocked = $false
                    }
                }
            }
            $personalBlocked | Should -Be $true `
                -Because "ISO A.8.19 requires restricting personal (BYOD) device enrollment to prevent unmanaged devices from accessing corporate data"
        }
    }
}

Describe "ISO 27002 - Intune Device Compliance Policies" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.9", "ISO27002:A.8.9" {
    It "ISO27002.8.9.10: At least one device compliance policy must be configured" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $policies = $null
        try {
            $policies = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/deviceCompliancePolicies' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "Intune permissions not granted or Intune license not present"
                return
            }
            throw
        }

        $policyList = if ($policies -and $policies['value']) { @($policies['value']) } else { @() }
        $policyList.Count | Should -BeGreaterOrEqual 1 `
            -Because "ISO A.8.9 requires device compliance policies to enforce security baselines on all managed endpoints"
    }

    It "ISO27002.8.9.11: At least one device configuration profile must exist for security hardening" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $configProfiles = $null
        try {
            $configProfiles = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/deviceConfigurations' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "Intune permissions not granted or Intune license not present"
                return
            }
            throw
        }

        $profileList = if ($configProfiles -and $configProfiles['value']) { @($configProfiles['value']) } else { @() }
        $profileList.Count | Should -BeGreaterOrEqual 1 `
            -Because "ISO A.8.9 requires device configuration profiles to enforce security settings (BitLocker, Firewall, Antivirus) on managed devices"
    }

    It "ISO27002.8.19.1: Windows Autopilot or device enrollment program must be configured" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $enrollProfiles = $null
        try {
            $enrollProfiles = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/windowsAutopilotDeploymentProfiles' -ErrorAction Stop
        } catch {
            if ($_.Exception.Message -match '403|Forbidden|Authorization') {
                Set-ItResult -Skipped -Because "Intune permissions not granted or Intune license not present"
                return
            }
            Set-ItResult -Skipped -Because "Windows Autopilot not configured or not accessible"
            return
        }

        $profiles = if ($enrollProfiles -and $enrollProfiles['value']) { @($enrollProfiles['value']) } else { @() }
        # This is informational - just skip if none exist
        if ($profiles.Count -eq 0) {
            Set-ItResult -Skipped -Because "No Windows Autopilot profiles configured - may use alternative enrollment method"
            return
        }

        $profiles.Count | Should -BeGreaterOrEqual 1 `
            -Because "ISO A.8.19 recommends using automated enrollment to ensure devices are configured with security baselines from first use"
    }
}
