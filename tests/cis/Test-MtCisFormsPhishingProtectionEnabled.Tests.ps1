Describe "CIS" -Tag "CIS.M365.1.3.5", "L1", "CIS E3 Level 1", "CIS E3", "CIS E5 Level 1", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.1.3.5: Ensure internal phishing protection for Forms is enabled" {

        $result = Test-MtCisFormsPhishingProtectionEnabled

        if ($null -ne $result) {
            $result | Should -Be $true -Because "Forms phishing protection is enabled."
        }
    }
}