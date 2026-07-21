Describe "CIS" -Tag "CIS.M365.5.1.5.2", "L1", "CIS E3 Level 1", "CIS E3", "CIS E5 Level 1", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.16", "ISO27002:5.16", "ISO27001:5.17", "ISO27002:5.17", "ISO27001:5.23", "ISO27002:5.23" {
    It "CIS.M365.5.1.5.2: Ensure the admin consent workflow is enabled" {

        $result = Test-MtCisAdminConsentWorkflowEnabled

        if ($null -ne $result) {
            $result | Should -Be $true -Because "admin consent workflow is enabled"
        }
    }
}