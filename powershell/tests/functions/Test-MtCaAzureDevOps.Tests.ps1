Describe 'Test-MtCaAzureDevOps' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../M365Advisor.psd1 -Force

        function New-CaPolicy {
            param(
                [string]$Id,
                [string]$DisplayName,
                [string[]]$IncludeApplications
            )

            return [PSCustomObject]@{
                id          = $Id
                displayName = $DisplayName
                state       = 'enabled'
                conditions  = [PSCustomObject]@{
                    applications = [PSCustomObject]@{
                        includeApplications = $IncludeApplications
                    }
                }
            }
        }
    }

    Context 'Azure DevOps app is unavailable in tenant' {
        It 'Should skip and return null' {
            $script:SkippedBecause = $null
            $script:SkippedCustomReason = $null

            Mock -ModuleName M365Advisor Test-MtConnection { return $true }
            Mock -ModuleName M365Advisor Get-MtLicenseInformation { return 'P1' }
            Mock -ModuleName M365Advisor Invoke-MtGraphRequest { return @() }
            Mock -ModuleName M365Advisor Add-MtTestResultDetail {
                param($SkippedBecause, $SkippedCustomReason)
                $script:SkippedBecause = $SkippedBecause
                $script:SkippedCustomReason = $SkippedCustomReason
            }

            $result = Test-MtCaAzureDevOps

            $result | Should -BeNull
            $script:SkippedBecause | Should -Be 'Custom'
            $script:SkippedCustomReason | Should -BeLike '*499b84ac-1321-427f-aa17-267ca6975798*'
        }
    }

    Context 'Azure DevOps app is available in tenant' {
        BeforeEach {
            Mock -ModuleName M365Advisor Test-MtConnection { return $true }
            Mock -ModuleName M365Advisor Get-MtLicenseInformation { return 'P1' }
            Mock -ModuleName M365Advisor Invoke-MtGraphRequest { return @{ id = 'sp-id' } }
        }

        It 'Should return true when at least one enabled policy explicitly includes Azure DevOps' {
            $policies = @(
                New-CaPolicy -Id 'policy1' -DisplayName 'Include Azure DevOps' -IncludeApplications @('499b84ac-1321-427f-aa17-267ca6975798')
            )
            Mock -ModuleName M365Advisor Get-MtConditionalAccessPolicy { return $policies }
            Mock -ModuleName M365Advisor Add-MtTestResultDetail {}

            Test-MtCaAzureDevOps | Should -BeTrue
        }

        It 'Should return false when no enabled policy explicitly includes Azure DevOps' {
            $policies = @(
                New-CaPolicy -Id 'policy1' -DisplayName 'All apps policy' -IncludeApplications @('All')
            )
            Mock -ModuleName M365Advisor Get-MtConditionalAccessPolicy { return $policies }
            Mock -ModuleName M365Advisor Add-MtTestResultDetail {}

            Test-MtCaAzureDevOps | Should -BeFalse
        }
    }
}

