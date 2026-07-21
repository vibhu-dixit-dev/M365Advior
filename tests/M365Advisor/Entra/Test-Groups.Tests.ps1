Describe "M365Advisor/Entra" -Tag "M365Advisor", "Group" {
    It "MT.1055: Microsoft 365 Group (and Team) creation should be restricted to approved users. See https://m365advisor.dev/docs/tests/MT.1055" -Tag "MT.1055" {

        Test-MtGroupCreationRestricted | Should -Be $true -Because "Microsoft 365 Group creation should be restricted to approved users."
    }
}

