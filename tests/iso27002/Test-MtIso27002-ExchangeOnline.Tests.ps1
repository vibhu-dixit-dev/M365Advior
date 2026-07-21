##########################################################################
# ISO 27002 / ISO 27002 - Exchange Online Security Tests
# Ported from M365-Assess: Exchange-Online/Get-ExoSecurityConfig.ps1
# Controls: A.5.14, A.5.16, A.8.15, A.8.20, A.8.21
##########################################################################

Describe "ISO 27002 - Exchange Online" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.20", "ISO27002:A.8.5", "ISO27002:A.8.20" {
    BeforeAll {
        $script:exoConnected = $false
        try {
            $null = Get-OrganizationConfig -ErrorAction Stop
            $script:exoConnected = $true
        } catch {}
    }


    It "ISO27002.8.20.1: Modern Authentication must be enabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $orgConfig = Get-OrganizationConfig -ErrorAction Stop
        $orgConfig.OAuth2ClientProfileEnabled | Should -Be $true `
            -Because "ISO A.8.20 requires modern auth protocols to prevent credential theft via legacy auth"
    }

    It "ISO27002.8.20.2: SMTP AUTH must be disabled org-wide" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $transportConfig = Get-TransportConfig -ErrorAction Stop
        $transportConfig.SmtpClientAuthenticationDisabled | Should -Be $true `
            -Because "ISO A.8.20 requires disabling legacy SMTP AUTH which bypasses MFA and modern auth controls"
    }
}

Describe "ISO 27002 - Exchange Auditing" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.15", "ISO27002:A.8.15" {
    It "ISO27002.8.15.1: Exchange organization-level auditing must not be disabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $orgConfig = Get-OrganizationConfig -ErrorAction Stop
        $orgConfig.AuditDisabled | Should -Be $false `
            -Because "ISO A.8.15 requires audit logging to be enabled for security monitoring and incident investigation"
    }

    It "ISO27002.8.15.2: No mailboxes should have audit bypass enabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $bypassed = @(Get-MailboxAuditBypassAssociation -ResultSize Unlimited -ErrorAction Stop -WarningAction SilentlyContinue |
            Where-Object { $_.AuditBypassEnabled -eq $true })
        $bypassed.Count | Should -Be 0 `
            -Because "ISO A.8.15 requires complete audit trails - mailbox audit bypass creates unmonitored accounts"
    }

    It "ISO27002.8.15.3: Mailbox auditing must be enabled on all user mailboxes (sample)" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $mailboxes = Get-Mailbox -ResultSize 50 -RecipientTypeDetails UserMailbox -ErrorAction Stop -WarningAction SilentlyContinue
        if (@($mailboxes).Count -eq 0) {
            Set-ItResult -Skipped -Because "No user mailboxes found in this tenant"
            return
        }
        $disabledAudit = @($mailboxes | Where-Object { -not $_.AuditEnabled })
        $disabledAudit.Count | Should -Be 0 `
            -Because "ISO A.8.15 requires per-mailbox audit logging to be enabled for all users"
    }
}

Describe "ISO 27002 - Exchange Email Security" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.5.14", "ISO27002:A.8.21", "ISO27002:A.5.14", "ISO27002:A.8.21" {
    It "ISO27002.5.14.2: Auto-forwarding to external domains must be disabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $defaultDomain = Get-RemoteDomain -Identity Default -ErrorAction Stop
        $defaultDomain.AutoForwardEnabled | Should -Be $false `
            -Because "ISO A.5.14 requires preventing unauthorized data transfer - auto-forwarding exfiltrates data to external mailboxes"
    }

    It "ISO27002.8.21.7: External sender tagging must be enabled to identify phishing attempts" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $externalInOutlook = Get-ExternalInOutlook -ErrorAction Stop
        $externalInOutlook.Enabled | Should -Be $true `
            -Because "ISO A.8.21 requires users to be able to identify untrusted external senders to prevent phishing"
    }

    It "ISO27002.8.21.8: Connection filter IP Allow List must be empty (no IPs bypass spam filtering)" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $connFilter = Get-HostedConnectionFilterPolicy -ErrorAction Stop | Where-Object { $_.Name -eq 'Default' }
        if (-not $connFilter) { Set-ItResult -Skipped -Because "Default connection filter policy not found"; return }
        $ipAllowCount = @($connFilter.IPAllowList).Count
        $ipAllowCount | Should -Be 0 `
            -Because "ISO A.8.21 requires all inbound email to pass spam filters - IP allowlist bypasses all filtering"
    }

    It "ISO27002.8.21.9: Connection filter safe list must be disabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $connFilter = Get-HostedConnectionFilterPolicy -ErrorAction Stop | Where-Object { $_.Name -eq 'Default' }
        if (-not $connFilter) { Set-ItResult -Skipped -Because "Default connection filter policy not found"; return }
        $connFilter.EnableSafeList | Should -Be $false `
            -Because "ISO A.8.21 requires the safe list to be off - it allows known-good senders to bypass spam checks"
    }

    It "ISO27002.8.21.10: No transport rules should whitelist domains by bypassing spam filtering (SCL=-1)" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $transportRules = Get-TransportRule -ErrorAction Stop
        $whitelistRules = @($transportRules | Where-Object { $_.SetSCL -eq -1 -and $_.SenderDomainIs })
        $whitelistRules.Count | Should -Be 0 `
            -Because "ISO A.8.21 requires all email to pass anti-spam - SCL=-1 rules create bypass paths for malicious email"
    }
}

Describe "ISO 27002 - Exchange Mailbox Security" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.5.16", "ISO27002:A.8.2", "ISO27002:A.5.16", "ISO27002:A.8.2" {
    It "ISO27002.8.2.2: All shared mailbox accounts must have sign-in blocked" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $sharedMailboxes = @(Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize 100 -ErrorAction Stop -WarningAction SilentlyContinue)
        if ($sharedMailboxes.Count -eq 0) {
            Set-ItResult -Skipped -Because "No shared mailboxes found in this tenant"
            return
        }
        $enabledAccounts = @()
        foreach ($mbx in $sharedMailboxes) {
            try {
                $mgUser = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/users/$($mbx.UserPrincipalName)?`$select=accountEnabled" -ErrorAction SilentlyContinue
                if ($mgUser -and $mgUser['accountEnabled'] -eq $true) { $enabledAccounts += $mbx.UserPrincipalName }
            } catch {}
        }
        $enabledAccounts.Count | Should -Be 0 `
            -Because "ISO A.8.2 requires shared mailbox accounts to be disabled - they must not allow interactive sign-in"
    }

    It "ISO27002.5.16.2: OWA additional storage providers must be disabled" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $owaPolicies = Get-OwaMailboxPolicy -ErrorAction Stop -WarningAction SilentlyContinue
        $enabledStorage = @($owaPolicies | Where-Object { $_.AdditionalStorageProvidersAvailable -eq $true })
        $enabledStorage.Count | Should -Be 0 `
            -Because "ISO A.5.16 requires restricting data storage to approved locations - OWA third-party storage providers bypass corporate data governance"
    }

    It "ISO27002.5.16.3: Default role assignment policy must not allow user-installed Outlook add-ins" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $defaultPolicy = Get-RoleAssignmentPolicy -ErrorAction Stop | Where-Object { $_.IsDefault }
        if (-not $defaultPolicy) { Set-ItResult -Skipped -Because "Default role assignment policy not found"; return }
        $assignedRoles = $defaultPolicy.AssignedRoles -join '; '
        $hasUnsafeRoles = $assignedRoles -match 'MyMarketplaceApps|MyCustomApps|MyReadWriteMailboxApps'
        $hasUnsafeRoles | Should -Be $false `
            -Because "ISO A.5.16 requires restricting user-installed apps - Outlook add-ins can exfiltrate data from mailboxes"
    }

    It "ISO27002.8.21.11: No inbound connectors should allow unauthenticated relay (no TLS + no domain restriction)" {
        if (-not $script:exoConnected) {
            Set-ItResult -Skipped -Because "Exchange Online cmdlets not connected"
            return
        }

        $inboundConnectors = @(Get-InboundConnector -ErrorAction Stop)
        $relayConnectors = @($inboundConnectors | Where-Object {
            $_.Enabled -eq $true -and $_.RequireTls -eq $false -and $_.RestrictDomainsToIPAddresses -eq $false
        })
        $relayConnectors.Count | Should -Be 0 `
            -Because "ISO A.8.21 requires all inbound connectors to use TLS and restrict by domain/IP to prevent open relay abuse"
    }
}
