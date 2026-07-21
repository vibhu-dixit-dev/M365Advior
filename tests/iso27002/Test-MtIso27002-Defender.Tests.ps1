##########################################################################
# ISO 27002 / ISO 27002 - Defender for Office 365 Security Tests
# Ported from M365-Assess: Security/Defender* Checks
# Controls: A.8.13, A.8.21, A.8.22
##########################################################################

Describe "ISO 27002 - Defender Anti-Phishing & Anti-Spam" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.21", "ISO27002:A.8.21" {
    BeforeAll {
        $script:antiPhishAvailable = Get-Command -Name Get-AntiPhishPolicy -ErrorAction SilentlyContinue
        $script:antiSpamAvailable = Get-Command -Name Get-HostedContentFilterPolicy -ErrorAction SilentlyContinue
    }

    It "ISO27002.8.21.1: Phishing threshold, Spoof Intel, and DMARC policies must be configured" {
        if (-not $script:antiPhishAvailable) {
            Set-ItResult -Skipped -Because "Defender for Office 365 / Get-AntiPhishPolicy is not available in this session"
            return
        }

        $policies = Get-AntiPhishPolicy -ErrorAction Stop
        if (@($policies).Count -eq 0) {
            $null | Should -Not -Be $null -Because "ISO A.8.21 requires at least one Anti-Phishing policy configured"
            return
        }

        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue } # detailed checks on default policy

            # Phish threshold level: 2 (Aggressive) or higher
            [int]$policy.PhishThresholdLevel | Should -BeGreaterOrEqual 2 -Because "ISO A.8.21 requires aggressive phishing thresholds to block suspicious mail"
            $policy.EnableSpoofIntelligence | Should -Be $true -Because "ISO A.8.21 requires spoof intelligence to block domain spoofing attacks"
            $policy.HonorDmarcPolicy | Should -Be $true -Because "ISO A.8.21 requires honoring sender DMARC records to validate sender authenticity"
        }
    }

    It "ISO27002.8.21.2: Bulk threshold, spam actions, and ZAP must be enabled" {
        if (-not $script:antiSpamAvailable) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-HostedContentFilterPolicy is not available"
            return
        }

        $policies = Get-HostedContentFilterPolicy -ErrorAction Stop
        if (@($policies).Count -eq 0) {
            $null | Should -Not -Be $null -Because "ISO A.8.21 requires at least one Anti-Spam policy configured"
            return
        }

        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue }

            [int]$policy.BulkThreshold | Should -BeLessOrEqual 6 -Because "ISO A.8.21 requires bulk mail threshold set to 6 or lower to minimize spam delivery"
            $policy.HighConfidencePhishAction | Should -Be 'Quarantine' -Because "ISO A.8.21 requires quarantining high-confidence phishing messages"
            $policy.ZapEnabled | Should -Be $true -Because "ISO A.8.21 requires Zero-Hour Auto Purge (ZAP) enabled to remove delivered threats post-delivery"
        }
    }

    It "ISO27002.8.21.3: Inbound spam policy must not allow sender domains globally" {
        if (-not $script:antiSpamAvailable) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-HostedContentFilterPolicy is not available"
            return
        }

        $policies = Get-HostedContentFilterPolicy -ErrorAction Stop
        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue }
            @($policy.AllowedSenderDomains).Count | Should -Be 0 -Because "ISO A.8.21 / A.8.13 prohibit global domain whitelisting as it bypasses all anti-spam/phishing filtering"
        }
    }
}

Describe "ISO 27002 - Defender Safe Links & Attachments" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.21", "ISO27002:A.8.22", "ISO27002:A.8.21", "ISO27002:A.8.22" {
    BeforeAll {
        $script:slAvailable = Get-Command -Name Get-SafeLinksPolicy -ErrorAction SilentlyContinue
        $script:saAvailable = Get-Command -Name Get-SafeAttachmentPolicy -ErrorAction SilentlyContinue
        $script:atpAvailable = Get-Command -Name Get-AtpPolicyForO365 -ErrorAction SilentlyContinue
    }

    It "ISO27002.8.21.4: Safe Links URL scanning and click tracking must be enabled" {
        if (-not $script:slAvailable) {
            Set-ItResult -Skipped -Because "Defender for Office 365 P1/P2 (Safe Links cmdlets) not available"
            return
        }

        $policies = Get-SafeLinksPolicy -ErrorAction Stop
        $policies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.21 requires Safe Links policies to protect users against malicious URLs"

        foreach ($policy in @($policies)) {
            $policy.ScanUrls | Should -Be $true -Because "ISO A.8.21 requires real-time Safe Links scanning for all link clicks"
            $policy.DoNotTrackUserClicks | Should -Be $false -Because "ISO A.8.21 requires click tracking enabled to identify and audit links clicked by users"
        }
    }

    It "ISO27002.8.21.5: Safe Attachments policy must be enabled and set to block malicious files" {
        if (-not $script:saAvailable) {
            Set-ItResult -Skipped -Because "Defender for Office 365 P1/P2 (Safe Attachments cmdlets) not available"
            return
        }

        $policies = Get-SafeAttachmentPolicy -ErrorAction Stop
        $policies.Count | Should -BeGreaterThan 0 -Because "ISO A.8.21 / A.8.22 require Safe Attachments policies to scan email files"

        foreach ($policy in @($policies)) {
            $policy.Enable | Should -Be $true -Because "ISO A.8.22 requires Safe Attachments protection to be enabled"
            $policy.Action | Should -Match 'Block|Replace|DynamicDelivery' -Because "ISO A.8.22 action must be set to Block, Replace, or Dynamic Delivery (not Allow)"
        }
    }

    It "ISO27002.8.21.6: Safe Attachments for SharePoint, OneDrive, and Teams must be enabled" {
        if (-not $script:atpAvailable) {
            Set-ItResult -Skipped -Because "Defender for Office 365 / Get-AtpPolicyForO365 is not available"
            return
        }

        $atpPolicy = Get-AtpPolicyForO365 -ErrorAction Stop
        $atpPolicy.EnableATPForSPOTeamsODB | Should -Be $true -Because "ISO A.8.21 / A.8.22 require extending attachment protections to Teams, OneDrive, and SharePoint repositories"
    }
}

Describe "ISO 27002 - Defender Anti-Malware & Outbound Spam" -Tag "ISO 27002", "ISO 27002", "ISO27002:A.8.22", "ISO27002:A.5.14", "ISO27002:A.8.22", "ISO27002:A.5.14" {
    BeforeAll {
        $script:malwareAvailable = Get-Command -Name Get-MalwareFilterPolicy -ErrorAction SilentlyContinue
        $script:outboundAvailable = Get-Command -Name Get-HostedOutboundSpamFilterPolicy -ErrorAction SilentlyContinue
    }

    It "ISO27002.8.22.1: Common Attachment Filter and Malware ZAP must be enabled" {
        if (-not $script:malwareAvailable) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-MalwareFilterPolicy is not available"
            return
        }

        $policies = Get-MalwareFilterPolicy -ErrorAction Stop
        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue }
            $policy.EnableFileFilter | Should -Be $true -Because "ISO A.8.22 requires the common attachment filter to block known high-risk file extensions"
            $policy.ZapEnabled | Should -Be $true -Because "ISO A.8.22 requires Zero-Hour Auto Purge (ZAP) for malware to neutralize newly discovered threats"
        }
    }

    It "ISO27002.8.22.2: Malware filter must block comprehensive list of dangerous extensions" {
        if (-not $script:malwareAvailable) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-MalwareFilterPolicy is not available"
            return
        }

        $policies = Get-MalwareFilterPolicy -ErrorAction Stop
        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue }

            $fileTypes = @($policy.FileTypes)
            $requiredTypes = @('ace','ani','apk','app','cab','cmd','com','deb','dmg','exe',
                'hta','img','iso','jar','js','jse','lnk','msi','pif','ps1','reg','rgs',
                'scr','sct','vb','vbe','vbs','vhd','vxd','wsc','wsf','wsh')
            $missing = @($requiredTypes | Where-Object { $fileTypes -notcontains $_ })

            $missing.Count | Should -Be 0 -Because "ISO A.8.22 requires blocking all common dangerous script and executable file types: $($missing -join ', ')"
        }
    }

    It "ISO27002.5.14.1: Automatic external forwarding must be disabled in Outbound Spam policy" {
        if (-not $script:outboundAvailable) {
            Set-ItResult -Skipped -Because "Exchange Online / Get-HostedOutboundSpamFilterPolicy is not available"
            return
        }

        $policies = Get-HostedOutboundSpamFilterPolicy -ErrorAction Stop
        foreach ($policy in @($policies)) {
            if (-not $policy.IsDefault) { continue }
            $policy.AutoForwardingMode | Should -Be 'Off' -Because "ISO A.5.14 / A.8.21 require outbound forwarding rules disabled to prevent stealth data exfiltration via auto-forwarding"
        }
    }
}
