Describe "CIS" -Tag "CIS.M365.2.1.2", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.2.1.2: Ensure the Common Attachment Types Filter is enabled (Only Checks Default Policy)" {

        $result = Test-MtCisAttachmentFilter

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the default malware filter policy has the common attachment file filter is enabled."
        }
    }
}