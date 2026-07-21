Describe "CIS" -Tag "CIS.M365.1.2.2", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.16", "ISO27002:5.16", "ISO27001:5.17", "ISO27002:5.17" {
    It "CIS.M365.1.2.2: Ensure sign-in to shared mailboxes is blocked" {

        $result = Test-MtCisSharedMailboxSignIn

        if ($null -ne $result) {
            $result | Should -Be $true -Because "Sign ins are blocked for shared mailboxes"
        }
    }
}