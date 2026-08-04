$path = "c:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\powershell\public\Connect-M365Advisor.ps1"
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors)
foreach ($e in $errors) {
    Write-Host "Line $($e.Extent.StartLineNumber), Col $($e.Extent.StartColumnNumber): $($e.Message)"
}
