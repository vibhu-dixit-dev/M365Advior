Describe "CIS" -Tag "CIS.M365.5.1.5.1", "L2", "CIS E3 Level 2", "CIS E3", "CIS E5 Level 2", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.16", "ISO27002:5.16", "ISO27001:5.17", "ISO27002:5.17" {
    It "CIS.M365.5.1.5.1: Ensure user consent to apps accessing company data on their behalf is not allowed" {

        $result = Test-MtCisEnsureUserConsentToAppsDisallowed

        if ($null -ne $result) {
            $result | Should -Be $true -Because "user consent to apps accessing company data on their behalf is not allowed."
        }
    }
}