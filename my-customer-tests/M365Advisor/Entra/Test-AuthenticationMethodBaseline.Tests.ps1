Describe "M365Advisor/Entra" -Tag "M365Advisor", "Authentication" {
    It "MT.1067: Authentication method policies should not reference non-existent groups. See https://m365advisor.dev/docs/tests/MT.1067" -Tag "MT.1067" {

        Test-MtAuthenticationPolicyReferencedObjectsExist | Should -Be $true -Because "authentication method policies should not reference deleted or non-existent groups"
    }
}

