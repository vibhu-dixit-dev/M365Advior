Describe 'Test-MtDomainsDmarcRecordMaturity' {
    BeforeEach {
        $script:skipCustomReason = $null

        Mock -ModuleName M365Advisor Test-MtConnection { return $true }
        Mock -ModuleName M365Advisor Add-MtTestResultDetail {
            param(
                $SkippedBecause,
                $SkippedCustomReason
            )

            $script:skipCustomReason = $SkippedCustomReason
        }
    }

    It 'skips cleanly when no verified managed domains are found' {
        Mock -ModuleName M365Advisor Invoke-MtGraphRequest { return @() }

        Test-MtDomainsDmarcRecordMaturity | Should -Be $null
        $script:skipCustomReason | Should -Be 'No verified and managed domains found in tenant'
    }
}

