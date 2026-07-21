Describe "CIS" -Tag "CIS.M365.2.1.7", "L1", "CIS E5 Level 1", "CIS E5", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.2.1.7: Ensure that an anti-phishing policy has been created (Only Checks Default Policy)" {

        $result = Test-MtCisSafeAntiPhishingPolicy

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the default anti-phishing policy is enabled."
        }
    }
}