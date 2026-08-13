##########################################################################
# ISO 27001 / ISO 27002 - Microsoft Purview Security & Compliance Tests
# Ported from M365-Assess: Purview/* Checks
# Controls: A.8.10, A.8.15
##########################################################################

Describe "ISO 27001 - Purview Data Retention Policies" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.10", "ISO27002:A.8.10" {
    BeforeAll {
        $script:retentionCmdAvailable = Get-Command -Name Get-RetentionCompliancePolicy -ErrorAction SilentlyContinue
        $script:policies = $null

        if ($script:retentionCmdAvailable) {
            try {
                $script:policies = @(Get-RetentionCompliancePolicy -ErrorAction Stop)
            } catch {
                # Connected but no permission, or not connected
            }
        }
    }

    It "ISO27001.A.8.10.1: At least one data retention policy must be configured and active" {
        if (-not $script:retentionCmdAvailable -or $null -eq $script:policies) {
            Set-ItResult -Skipped -Because "Purview connection not active or Get-RetentionCompliancePolicy is not accessible"
            return
        }

        $enabledPolicies = @($script:policies | Where-Object { $_.Enabled -ne $false })
        $enabledPolicies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.10 requires retention and disposal controls to preserve data according to legal and business requirements"
    }

    It "ISO27001.A.8.10.2: Exchange locations must be covered by a retention policy" {
        if (-not $script:retentionCmdAvailable -or $null -eq $script:policies) {
            Set-ItResult -Skipped -Because "Purview connection not active or Get-RetentionCompliancePolicy is not accessible"
            return
        }

        $enabledPolicies = @($script:policies | Where-Object { $_.Enabled -ne $false })
        $exchangePolicies = @($enabledPolicies | Where-Object {
            ($_.ExchangeLocation -and @($_.ExchangeLocation).Count -gt 0) -or
            ($_.Workload -and $_.Workload -match 'Exchange')
        })

        $exchangePolicies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.10 requires email/mailbox communications to be retained under classification policies"
    }

    It "ISO27001.A.8.10.3: Teams channel locations and chats must be covered by a retention policy" {
        if (-not $script:retentionCmdAvailable -or $null -eq $script:policies) {
            Set-ItResult -Skipped -Because "Purview connection not active or Get-RetentionCompliancePolicy is not accessible"
            return
        }

        $enabledPolicies = @($script:policies | Where-Object { $_.Enabled -ne $false })
        $teamsPolicies = @($enabledPolicies | Where-Object {
            ($_.TeamsChannelLocation -and @($_.TeamsChannelLocation).Count -gt 0) -or
            ($_.TeamsChatLocation    -and @($_.TeamsChatLocation).Count    -gt 0) -or
            ($_.Workload -and $_.Workload -match 'Teams')
        })

        $teamsPolicies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.10 requires chat and channel records to be covered by corporate retention standards"
    }

    It "ISO27001.A.8.10.4: SharePoint and OneDrive locations must be covered by a retention policy" {
        if (-not $script:retentionCmdAvailable -or $null -eq $script:policies) {
            Set-ItResult -Skipped -Because "Purview connection not active or Get-RetentionCompliancePolicy is not accessible"
            return
        }

        $enabledPolicies = @($script:policies | Where-Object { $_.Enabled -ne $false })
        $sharepointPolicies = @($enabledPolicies | Where-Object {
            ($_.SharePointLocation -and @($_.SharePointLocation).Count -gt 0) -or
            ($_.OneDriveLocation   -and @($_.OneDriveLocation).Count   -gt 0) -or
            ($_.Workload -and $_.Workload -match 'SharePoint')
        })

        $sharepointPolicies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.10 requires documents stored in document management portals to have defined lifetimes"
    }

    It "ISO27001.A.8.10.5: Enabled retention policies must be in Enforce mode (not simulation/test)" {
        if (-not $script:retentionCmdAvailable -or $null -eq $script:policies) {
            Set-ItResult -Skipped -Because "Purview connection not active or Get-RetentionCompliancePolicy is not accessible"
            return
        }

        $enabledPolicies = @($script:policies | Where-Object { $_.Enabled -ne $false })
        if ($enabledPolicies.Count -eq 0) {
            Set-ItResult -Skipped -Because "No enabled retention policies found to verify enforcement mode"
            return
        }

        $testModePolicies = @($enabledPolicies | Where-Object { $_.Mode -ne 'Enforce' })
        $testModePolicies.Count | Should -Be 0 -Because "ISO A.8.10 requires active retention enforcement - simulation mode does not apply actual block/delete settings"
    }
}

Describe "ISO 27001 - Purview Audit & Logging" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.15", "ISO27002:A.8.15" {
    BeforeAll {
        $script:auditCmdAvailable = Get-Command -Name Get-AdminAuditLogConfig -ErrorAction SilentlyContinue
        $script:auditConfig = $null

        if ($script:auditCmdAvailable) {
            try {
                $script:auditConfig = Get-AdminAuditLogConfig -ErrorAction Stop
            } catch {}
        }
    }

    It "ISO27001.A.8.15.4: Unified Audit Log Ingestion must be enabled" {
        if (-not $script:auditCmdAvailable -or $null -eq $script:auditConfig) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-AdminAuditLogConfig is not accessible"
            return
        }

        if ($script:auditConfig.PSObject.Properties.Name -contains 'UnifiedAuditLogIngestionEnabled') {
            $script:auditConfig.UnifiedAuditLogIngestionEnabled | Should -Be $true -Because "ISO A.8.15 requires central security audit log ingestion enabled for compliance auditing"
        } else {
            Set-ItResult -Skipped -Because "UnifiedAuditLogIngestionEnabled property not found on audit config"
        }
    }

    It "ISO27001.A.8.15.5: Administrative auditing must be enabled globally" {
        if (-not $script:auditCmdAvailable -or $null -eq $script:auditConfig) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-AdminAuditLogConfig is not accessible"
            return
        }

        if ($script:auditConfig.PSObject.Properties.Name -contains 'AdminAuditLogEnabled') {
            $script:auditConfig.AdminAuditLogEnabled | Should -Be $true -Because "ISO A.8.15 requires administrative audit logging to track directory and Exchange admin command execution"
        } else {
            Set-ItResult -Skipped -Because "AdminAuditLogEnabled property not found on audit config"
        }
    }
}
