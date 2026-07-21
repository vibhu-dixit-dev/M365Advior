Describe "CIS" -Tag "CIS.M365.2.1.11", "L2", "CIS E3 Level 2", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.2.1.11: Ensure comprehensive attachment filtering is applied" {

        $result = Test-MtCisAttachmentFilterComprehensive

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the default malware filter policy did not have comprehensive attachment filtering applied."
        }
    }
}