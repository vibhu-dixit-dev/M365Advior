Describe "CIS" -Tag "CIS.M365.1.1.1", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.16", "ISO27002:5.16", "ISO27001:5.18", "ISO27002:5.18", "ISO27001:8.2", "ISO27002:8.2" {
    It "CIS.M365.1.1.1: Ensure Administrative accounts are cloud-only" {

        $result = Test-MtCisCloudAdmin

        if ($null -ne $result) {
            $result | Should -Be $true -Because "admin accounts are cloud-only"
        }
    }
}