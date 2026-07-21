Describe "CIS" -Tag "SharePoint Online", "CIS.M365.7.3.1", "L2", "CIS E5 Level 2", "CIS E5", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:8.7", "ISO27002:8.7" {
    It "CIS.M365.7.3.1: Ensure Office 365 SharePoint infected files are disallowed for download" {

        $result = Test-MtCisSpoPreventDownloadMaliciousFile

        if ($null -ne $result) {
            $result | Should -Be $true -Because "Office 365 SharePoint infected files are disallowed for download"
        }
    }
}