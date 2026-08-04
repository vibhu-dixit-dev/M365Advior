$lines = Get-Content "c:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\powershell\public\Connect-M365Advisor.ps1"
for ($n = 10; $n -le $lines.Count; $n += 10) {
    $sub = ($lines[0..($n-1)]) -join "`n"
    $t = $null; $e = $null
    [System.Management.Automation.Language.Parser]::ParseInput($sub, [ref]$t, [ref]$e)
    $ampErr = $e | Where-Object { $_.Message -like "*ampersand*" }
    if ($ampErr) {
        Write-Host "Ampersand error appeared at line range 1..$n"
        break
    }
}
