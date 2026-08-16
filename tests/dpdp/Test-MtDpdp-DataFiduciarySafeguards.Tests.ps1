##########################################################################
# DPDP Act 2023 - Data Fiduciary Security Safeguards Tests
# Statutory Basis: Digital Personal Data Protection Act, 2023 (Section 8)
##########################################################################

Describe "DPDP Act 2023 - Section 8: Technical Safeguards & Access Control" -Tag "DPDP", "DPDP2023", "DPDP.Sec.08" {
    It "DPDP.Sec.08.1: Ensure Global Administrator accounts are restricted to 4 or fewer to minimize breach surface" -Tag "DPDP.Sec.08.1", "DPDP" {
        $result = Test-MtCisGlobalAdminCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8(1) requires reasonable security safeguards to prevent data breaches by restricting high-privilege access"
        }
    }

    It "DPDP.Sec.08.2: Ensure weak and legacy authentication protocols are disabled across the tenant" -Tag "DPDP.Sec.08.2", "DPDP" {
        $result = Test-MtCisWeakAuthenticationMethodsDisabled
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8(1) mandates blocking protocols vulnerable to password spraying and unauthorized data exfiltration"
        }
    }

    It "DPDP.Sec.08.3: Ensure dedicated emergency break-glass cloud administrator accounts exist" -Tag "DPDP.Sec.08.3", "DPDP" {
        $result = Test-MtCisCloudAdmin
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires operational continuity and emergency incident response readiness"
        }
    }

    It "DPDP.Sec.08.4: Ensure passwords are not configured to expire unnecessarily, mitigating weak password cycling" -Tag "DPDP.Sec.08.4", "DPDP" {
        $result = Test-MtCisPasswordExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Modern password policy safeguards data principal credentials against predictable variations"
        }
    }

    It "DPDP.Sec.08.5: Ensure Customer Lockbox is enabled for administrative approvals on support escalations" -Tag "DPDP.Sec.08.5", "DPDP" {
        $result = Test-MtCisCustomerLockBox
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires explicit fiduciary approval before any third-party service personnel accesses tenant data"
        }
    }
}
