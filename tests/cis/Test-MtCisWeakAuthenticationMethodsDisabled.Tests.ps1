Describe "CIS" -Tag "CIS.M365.5.2.3.5", "L1", "CIS E3 Level 1", "CIS E3", "CIS E5 Level 1", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.17", "ISO27002:5.17", "ISO27001:8.5", "ISO27002:8.5" {
    It "CIS.M365.5.2.3.5: Ensure weak authentication methods are disabled" {

        $result = Test-MtCisWeakAuthenticationMethodsDisabled

        if ($null -ne $result) {
            $result | Should -Be $true -Because "weak authentication methods are disabled."
        }
    }
}