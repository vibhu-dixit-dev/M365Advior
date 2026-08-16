##########################################################################
# DPDP Act 2023 - Data Sharing, Guest Governance & Exfiltration Safeguards
# Statutory Basis: Digital Personal Data Protection Act, 2023 (Sections 6, 8, 16)
##########################################################################

Describe "DPDP Act 2023 - Section 6 & 8: Data Sharing & Guest Access Safeguards" -Tag "DPDP", "DPDP2023", "DPDP.Sec.06", "DPDP.Sec.08" {
    It "DPDP.Sec.06.4: Ensure external guest user directory permissions are strictly restricted" -Tag "DPDP.Sec.06.4", "DPDP" {
        $result = Test-MtCisEnsureGuestAccessRestricted
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 6 mandates that external third parties cannot enumerate data principal identities"
        }
    }

    It "DPDP.Sec.06.5: Ensure guest users are dynamically categorized for automated lifecycle governance" -Tag "DPDP.Sec.06.5", "DPDP" {
        $result = Test-MtCisEnsureGuestUserDynamicGroup
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 6 requires continuous access tracking for all external data processors"
        }
    }

    It "DPDP.Sec.08.6: Ensure no unapproved public Microsoft 365 Groups expose sensitive organizational conversations" -Tag "DPDP.Sec.08.6", "DPDP" {
        $result = Test-MtCis365PublicGroup
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires protecting internal communications containing data principal information"
        }
    }

    It "DPDP.Sec.08.7: Ensure SharePoint default sharing link is not set to anonymous Anyone" -Tag "DPDP.Sec.08.7", "DPDP" {
        $result = Test-MtCisSpoDefaultSharingLink
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 prohibits untracked, anonymous exfiltration of files containing personal data"
        }
    }

    It "DPDP.Sec.08.8: Ensure default sharing link permissions are restricted to View Only" -Tag "DPDP.Sec.08.8", "DPDP" {
        $result = Test-MtCisSpoDefaultSharingLinkPermission
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 enforces principle of least privilege on data sharing"
        }
    }

    It "DPDP.Sec.08.9: Ensure guest access expiration is configured for SharePoint Online document libraries" -Tag "DPDP.Sec.08.9", "DPDP" {
        $result = Test-MtCisSpoGuestAccessExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8(7) requires data access to be time-bound and automatically terminated"
        }
    }

    It "DPDP.Sec.08.10: Ensure external guests cannot share unowned SharePoint documents" -Tag "DPDP.Sec.08.10", "DPDP" {
        $result = Test-MtCisSpoGuestCannotShareUnownedItem
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 mandates that third parties cannot cascade data sharing to unvetted entities"
        }
    }

    It "DPDP.Sec.08.11: Ensure downloading malicious files is blocked in SharePoint Online" -Tag "DPDP.Sec.08.11", "DPDP" {
        $result = Test-MtCisSpoPreventDownloadMaliciousFile
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 mandates technical safeguards against malware and ransomware threats"
        }
    }

    It "DPDP.Sec.08.12: Ensure Entra B2B collaboration integration restricts unvetted cross-tenant sharing" -Tag "DPDP.Sec.08.12", "DPDP" {
        $result = Test-MtCisSpoB2BIntegration
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 16 cross-border transfer and collaboration safeguards require domain boundary governance"
        }
    }

    It "DPDP.Sec.08.13: Ensure Teams communication with unmanaged external users is restricted" -Tag "DPDP.Sec.08.13", "DPDP" {
        $result = Test-MtCisCommunicateWithUnmanagedTeamsUsers
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 protects instant messaging channels from unverified external interception"
        }
    }

    It "DPDP.Sec.08.14: Ensure Teams meeting lobby prevents unauthorized participants from bypassing verification" -Tag "DPDP.Sec.08.14", "DPDP" {
        $result = Test-MtCisTeamsLobbyBypass
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 mandates attendee identity verification for meetings where personal data is discussed"
        }
    }

    It "DPDP.Sec.08.15: Ensure third-party storage services are restricted across Microsoft 365" -Tag "DPDP.Sec.08.15", "DPDP" {
        $result = Test-MtCisThirdPartyStorageServicesRestricted
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 prohibits unmonitored shadow cloud storage exfiltration"
        }
    }

    It "DPDP.Sec.08.16: Ensure third-party file sharing in Teams is restricted" -Tag "DPDP.Sec.08.16", "DPDP" {
        $result = Test-MtCisThirdPartyFileSharing
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 ensures all personal data remains within governed fiduciary boundaries"
        }
    }
}
