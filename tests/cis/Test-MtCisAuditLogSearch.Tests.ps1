Describe "CIS" -Tag "CIS.M365.3.1.1", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.33", "ISO27002:5.33", "ISO27001:8.15", "ISO27002:8.15", "ISO27001:8.16", "ISO27002:8.16" {
    It "CIS.M365.3.1.1: Ensure Microsoft 365 audit log search is Enabled" {

        $result = Test-MtCisAuditLogSearch

        if ($null -ne $result) {
            $result | Should -Be $true -Because "audit log search is enabled."
        }
    }
}