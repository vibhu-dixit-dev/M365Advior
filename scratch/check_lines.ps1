$lines = Get-Content "c:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\powershell\public\Connect-M365Advisor.ps1"
for ($i = 265; $i -lt 285; $i++) {
    Write-Host "$($i+1): $($lines[$i])"
}
