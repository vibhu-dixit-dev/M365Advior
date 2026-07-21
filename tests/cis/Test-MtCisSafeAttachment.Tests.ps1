Describe "CIS" -Tag "CIS.M365.2.1.4", "L2", "CIS E5 Level 2", "CIS E5", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.2.1.4: Ensure Safe Attachments policy is enabled (Only Checks Default Policy)" {

        $result = Test-MtCisSafeAttachment

        if ($null -ne $result) {
            $result | Should -Be $true -Because "the default Safe Attachement policy matches CIS recommendations."
        }
    }
}