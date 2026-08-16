##########################################################################
# DPDP Act 2023 - Mail, Threat Protection & Anti-Exfiltration Tests
# Statutory Basis: Digital Personal Data Protection Act, 2023 (Section 8)
##########################################################################

Describe "DPDP Act 2023 - Section 8: Personal Data Threat Protection & Defense" -Tag "DPDP", "DPDP2023", "DPDP.Sec.08" {
    It "DPDP.Sec.08.17: Ensure Zero-Hour Auto Purge (ZAP) for phishing and malware is enabled in Exchange Online" -Tag "DPDP.Sec.08.17", "DPDP" {
        $result = Test-MtCisZAP
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires automated retroactive threat neutralisation to prevent data breaches"
        }
    }

    It "DPDP.Sec.08.18: Ensure Safe Links protection is active to prevent credential-harvesting phishing" -Tag "DPDP.Sec.08.18", "DPDP" {
        $result = Test-MtCisSafeLink
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires real-time URL detonation and protection against personal data credential theft"
        }
    }

    It "DPDP.Sec.08.19: Ensure Safe Attachments ATP policy is active to block zero-day malicious payloads" -Tag "DPDP.Sec.08.19", "DPDP" {
        $result = Test-MtCisSafeAttachment
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires sandbox attachment inspection to safeguard tenant mailboxes"
        }
    }

    It "DPDP.Sec.08.20: Ensure Anti-Phishing protection policies are enabled for internal data principals" -Tag "DPDP.Sec.08.20", "DPDP" {
        $result = Test-MtCisSafeAntiPhishingPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 mandates domain impersonation and executive spoofing defense"
        }
    }

    It "DPDP.Sec.08.21: Ensure DKIM signing is enabled on all custom mail domains to prevent spoofing" -Tag "DPDP.Sec.08.21", "DPDP" {
        $result = Test-MtCisDkim
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires cryptographic email integrity validation"
        }
    }

    It "DPDP.Sec.08.22: Ensure Outbound Spam policies block automatic external email forwarding" -Tag "DPDP.Sec.08.22", "DPDP" {
        $result = Test-MtCisOutboundSpamFilterPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 mandates technical barriers against automated data exfiltration rules"
        }
    }

    It "DPDP.Sec.08.23: Ensure direct interactive sign-in on shared mailboxes is blocked" -Tag "DPDP.Sec.08.23", "DPDP" {
        $result = Test-MtCisSharedMailboxSignIn
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires attributable, individualized access control for all mailbox operations"
        }
    }
}
