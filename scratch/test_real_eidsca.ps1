Import-Module Audit365 -RequiredVersion 1.0.6 -Force

& (Get-Module Audit365) {
    $script:____Pester = @{
        CurrentTest = @{
            ExpandedName = "EIDSCA.AF03: Test FIDO2 Attestation"
        }
    }
    $script:__MtSession = @{
        TestResultDetail = @{}
    }

    # Call the real Test-MtEidscaAF03 function from Audit365
    $EnabledAuthMethods = @('Fido2')
    Test-MtEidscaAF03

    Write-Host "--- REAL EIDSCA TEST RESULT DETAIL ---"
    $testInfo = $script:__MtSession.TestResultDetail["EIDSCA.AF03: Test FIDO2 Attestation"]
    Write-Host "TestTitle:       $($testInfo.TestTitle)"
    Write-Host "TestDescription: $($testInfo.TestDescription)"
    Write-Host "TestResult:      $($testInfo.TestResult)"
}
