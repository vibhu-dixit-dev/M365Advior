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

    # Execute inside a dummy function frame named Test-MtEidscaAF03
    function Test-MtEidscaAF03 {
        Add-MtTestResultDetail -Result "Sample result string" -Severity "High"
    }

    Test-MtEidscaAF03

    Write-Host "--- SESSION TEST RESULT DETAIL OBJECT ---"
    $testInfo = $script:__MtSession.TestResultDetail["EIDSCA.AF03: Test FIDO2 Attestation"]
    Write-Host "TestTitle:       $($testInfo.TestTitle)"
    Write-Host "TestDescription: $($testInfo.TestDescription)"
    Write-Host "TestResult:      $($testInfo.TestResult)"
}
