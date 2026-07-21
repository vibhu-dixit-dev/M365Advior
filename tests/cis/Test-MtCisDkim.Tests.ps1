Describe "CIS" -Tag "CIS.M365.2.1.9", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.20", "ISO27002:8.20", "ISO27001:8.21", "ISO27002:8.21" {
    It "CIS.M365.2.1.9: Ensure that DKIM is enabled for all Exchange Online Domains" {

        $result = Test-MtCisDkim

        if ($null -ne $result) {
            $result | Should -Be $true -Because "DKIM record should exist and be configured."
        }
    }
}