 $psm1 = 'C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\module\Audit365\Audit365.psm1'
$lines = [System.IO.File]::ReadAllLines($psm1, [System.Text.Encoding]::UTF8)

# Find all EIDSCA function start/end lines
$eidscaFns = @()
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^function Test-MtEidsca\w+') {
        $fnName = ($lines[$i] -replace 'function (Test-MtEidsca\w+).*', '$1').Trim()
        $eidscaFns += [PSCustomObject]@{ Name = $fnName; Line = $i + 1 }
    }
}

Write-Host "Total EIDSCA functions found: $($eidscaFns.Count)"

# For each, check if it has Add-MtTestResultDetail -Description
$noDesc = @()
foreach ($fn in $eidscaFns) {
    $startLine = $fn.Line - 1
    # Search next 100 lines for Add-MtTestResultDetail
    $endLine = [Math]::Min($startLine + 100, $lines.Length - 1)
    $hasDesc = $false
    for ($i = $startLine; $i -le $endLine; $i++) {
        if ($lines[$i] -match 'Add-MtTestResultDetail.*-Description') {
            $hasDesc = $true
            break
        }
        if ($i -gt $startLine + 5 -and $lines[$i] -match '^function ') { break }
    }
    if (-not $hasDesc) {
        $noDesc += $fn.Name
    }
}

Write-Host "EIDSCA functions WITHOUT -Description: $($noDesc.Count)"
$noDesc | Select-Object -First 10
