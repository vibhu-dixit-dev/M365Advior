##########################################################################
# DPDP Act 2023 - Notice, Consent & Permission Governance Tests
# Statutory Basis: Digital Personal Data Protection Act, 2023 (Sections 4, 5, 6)
##########################################################################

Describe "DPDP Act 2023 - Section 4 & 5: Notice & Valid Consent Architecture" -Tag "DPDP", "DPDP2023", "DPDP.Sec.04", "DPDP.Sec.05" {
    It "DPDP.Sec.04.1: Ensure Admin Consent Workflow is enabled to prevent unconsented 3rd-party access to personal data" -Tag "DPDP.Sec.04.1", "DPDP" {
        $result = Test-MtCisAdminConsentWorkflowEnabled
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 4 & 5 require that processing of personal data must be based on explicit, verifiable consent and reviewed by data fiduciary admins"
        }
    }

    It "DPDP.Sec.04.2: Ensure user consent to third-party applications is disallowed to enforce consent unbundling" -Tag "DPDP.Sec.04.2", "DPDP" {
        $result = Test-MtCisEnsureUserConsentToAppsDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 5(1) requires consent to be specific, clear, and unbundled from generic service agreements"
        }
    }

    It "DPDP.Sec.04.3: Ensure user-owned and unregistered third-party application access is restricted" -Tag "DPDP.Sec.04.3", "DPDP" {
        $result = Test-MtCisThirdPartyApplicationsDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 6 mandates that data fiduciaries maintain strict inventory and control over data processing channels"
        }
    }

    It "DPDP.Sec.05.1: Ensure tenant creation and self-service authorization are restricted to authorized administrators" -Tag "DPDP.Sec.05.1", "DPDP" {
        $result = Test-MtCisCreateTenantDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 6 requires that no unmanaged tenant boundaries or shadow data silos are created"
        }
    }
}
