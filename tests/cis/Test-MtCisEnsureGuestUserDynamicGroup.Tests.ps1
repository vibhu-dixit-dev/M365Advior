Describe "CIS" -Tag "CIS.M365.5.1.3.1", "L1", "CIS E3 Level 1", "CIS E3", "CIS E5 Level 1", "CIS E5", "CIS", "Security", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.15", "ISO27002:5.15", "ISO27001:5.18", "ISO27002:5.18" {
    It "CIS.M365.5.1.3.1: Ensure a dynamic group for guest users is created" {

        $result = Test-MtCisEnsureGuestUserDynamicGroup

        if ($null -ne $result) {
            $result | Should -Be $true -Because "a dynamic group for Guest users exists."
        }
    }
}