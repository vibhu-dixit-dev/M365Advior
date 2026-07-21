Describe "CIS" -Tag "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.14", "ISO27002:5.14", "ISO27001:5.21", "ISO27002:5.21" {
    It "CIS.M365.8.1.1: Ensure external file sharing in Teams is enabled for only approved cloud storage services" -Tag "CIS.M365.8.1.1", "CIS E3 Level 2" {

        $result = Test-MtCisThirdPartyFileSharing

        if ($null -ne $result) {
            $result | Should -Be $true -Because "file sharing with third-party cloud services is disabled."
        }
    }
}