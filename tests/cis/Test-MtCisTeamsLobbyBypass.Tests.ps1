Describe "CIS" -Tag "CIS.M365.8.5.3", "L1", "CIS E3 Level 1", "CIS E3", "CIS", "CIS M365 v6.0.1", "ISO 27001", "ISO 27002", "ISO27001:5.14", "ISO27002:5.14", "ISO27001:8.20", "ISO27002:8.20" {
    It "CIS.M365.8.5.3: Ensure only people in my org can bypass the lobby" {

        $result = Test-MtCisTeamsLobbyBypass

        if ($null -ne $result) {
            $result | Should -Be $true -Because "Global (Org-wide default) meeting policy is configured to only bypass the lobby for 'Peoply in my org'."
        }
    }
}