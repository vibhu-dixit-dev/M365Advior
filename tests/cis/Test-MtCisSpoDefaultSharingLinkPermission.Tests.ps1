Describe "CIS" -Tag "SharePoint Online", "OneDrive", "CIS.M365.7.2.11", "L1", "CIS E3 Level 1", "CIS E3", "CIS E5 Level 1", "CIS E5", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.14", "ISO27002:5.14", "ISO27001:5.15", "ISO27002:5.15" {
    It "CIS.M365.7.2.11: Ensure the SharePoint default sharing link permission is set" {

        $result = Test-MtCisSpoDefaultSharingLinkPermission

        if ($null -ne $result) {
            $result | Should -Be $true -Because "The SharePoint default sharing link permission is set"
        }
    }
}