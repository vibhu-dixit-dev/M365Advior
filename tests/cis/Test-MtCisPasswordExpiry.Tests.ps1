Describe "CIS" -Tag "CIS.M365.1.3.1", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.17", "ISO27002:5.17" {
    It "CIS.M365.1.3.1: Ensure the 'Password expiration policy' is set to 'Set passwords to never expire (recommended)'" {

        $result = Test-MtCisPasswordExpiry

        if ($null -ne $result) {
            $result | Should -Be $true -Because "passwords are not set to expire"
        }
    }
}