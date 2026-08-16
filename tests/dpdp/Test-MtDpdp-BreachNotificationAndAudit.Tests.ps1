##########################################################################
# DPDP Act 2023 - Audit Logging, Incident Notification & Retention Tests
# Statutory Basis: Digital Personal Data Protection Act, 2023 (Section 8(5), 8(7))
##########################################################################

Describe "DPDP Act 2023 - Section 8: Auditability, Breach Readiness & Retention" -Tag "DPDP", "DPDP2023", "DPDP.Sec.08" {
    It "DPDP.Sec.08.24: Ensure Unified Audit Logging is enabled for statutory personal data breach readiness" -Tag "DPDP.Sec.08.24", "DPDP" {
        $result = Test-MtCisAuditLogSearch
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8(5) mandates intimation of personal data breaches to the Data Protection Board and affected data principals; audit logs are mandatory evidence"
        }
    }

    It "DPDP.Sec.08.25: Ensure internal malware and threat notifications are configured for security personnel" -Tag "DPDP.Sec.08.25", "DPDP" {
        $result = Test-MtCisInternalMalwareNotification
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 requires real-time alerting mechanisms for swift incident triage"
        }
    }

    It "DPDP.Sec.08.26: Ensure Exchange connection filter safe-lists are not configured with 0.0.0.0 bypasses" -Tag "DPDP.Sec.08.26", "DPDP" {
        $result = Test-MtCisConnectionFilterSafeList
        if ($null -ne $result) {
            $result | Should -Be $true -Because "Section 8 prohibits disabling security controls that protect personal communication records"
        }
    }
}
