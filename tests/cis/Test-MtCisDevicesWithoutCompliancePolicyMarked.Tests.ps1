Describe "CIS" -Tag "CIS.M365.4.1", "L2", "CIS E3 Level 2", "CIS E3", "CIS E5 Level 2", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.1", "ISO27002:8.1" {
    It "CIS.M365.4.1: Ensure devices without a compliance policy are marked 'not compliant'" {

        $result = Test-MtCisDevicesWithoutCompliancePolicyMarked

        if ($null -ne $result) {
            $result | Should -Be $true -Because "devices without a compliance policy are marked 'not compliant'"
        }
    }
}