Describe "CIS" -Tag "CIS.M365.1.2.1", "L2", "CIS E3 Level 2", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.15", "ISO27002:5.15", "ISO27001:5.18", "ISO27002:5.18" {
    It "CIS.M365.1.2.1: Ensure that only organizationally managed/approved public groups exist" {

        $result = Test-MtCis365PublicGroup

        if ($null -ne $result) {
            $result | Should -Be $true -Because "365 groups are private"
        }
    }
}