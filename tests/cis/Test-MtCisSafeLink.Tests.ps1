Describe "CIS" -Tag "CIS.M365.2.1.1", "L2", "CIS E5 Level 2", "CIS E5", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7", "ISO27001:8.23", "ISO27002:8.23" {
    It "CIS.M365.2.1.1: Ensure Safe Links for Office Applications is Enabled (Only Checks Priority 0 Policy)" {

        $result = Test-MtCisSafeLink

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the priority 0 safe link policy matches CIS recommendations"
        }
    }
}