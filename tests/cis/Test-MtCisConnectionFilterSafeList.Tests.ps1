Describe "CIS" -Tag "CIS.M365.2.1.13", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7", "ISO27001:8.20", "ISO27002:8.20" {
    It "CIS.M365.2.1.13: Ensure the connection filter safe list is off (Only Checks Default Policy)" {

        $result = Test-MtCisConnectionFilterSafeList

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the connection filter safe list not enabled."
        }
    }
}