function Get-MtHtmlReport {
    <#
    .Synopsis
    Generates a formatted html report using the M365AdvisorResults object created by ConvertTo-MtM365AdvisorResult

    .Description
    The generated html is a single file that provides a visual representation of the test
    results with a summary view and click through of the details.

    Supports both single-tenant results (from ConvertTo-MtM365AdvisorResult) and multi-tenant
    results (from Merge-MtM365AdvisorResult).

    .Example
    $pesterResults = Invoke-Pester -PassThru
    $m365advisorResults = ConvertTo-MtM365AdvisorResult $pesterResults
    $output = Get-MtHtmlReport -M365AdvisorResults $m365advisorResults
    $output | Out-File -FilePath $out.OutputHtmlFile -Encoding UTF8

    This example shows how to generate the html report and save it to a file by using Invoke-Pester

    .Example
    $m365advisorResults = Invoke-M365Advisor -PassThru
    $output = Get-MtHtmlReport -M365AdvisorResults $m365advisorResults
    $output | Out-File -FilePath $out.OutputHtmlFile -Encoding UTF8

    This example shows how to generate the html report and save it to a file by using Invoke-M365Advisor

    .Example
    $result1 = Invoke-M365Advisor -PassThru
    $result2 = Invoke-M365Advisor -PassThru
    $merged = Merge-MtM365AdvisorResult -M365AdvisorResults @($result1, $result2)
    $output = Get-MtHtmlReport -M365AdvisorResults $merged
    $output | Out-File -FilePath "MultiTenantReport.html" -Encoding UTF8

    This example shows how to generate a multi-tenant html report

    .LINK
    https://m365advisor.dev/docs/commands/Get-MtHtmlReport
    #>
    [CmdletBinding()]
    param(
        # The M365Advisor test results returned from `Invoke-Pester -PassThru | ConvertTo-MtM365AdvisorResult`
        # or from `Merge-MtM365AdvisorResult` for multi-tenant reports.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [psobject] $M365AdvisorResults
    )

    process {
        # Use depth 7 for multi-tenant to handle: Tenants > Tests > ErrorRecord > nested objects
        $isMultiTenant = $M365AdvisorResults.PSObject.Properties.Name -contains 'Tenants'
        $depth = if ($isMultiTenant) { 7 } else { 5 }

        Write-Verbose "Generating HTML report."
        $json = $M365AdvisorResults | ConvertTo-Json -Depth $depth -Compress -WarningAction Ignore

        $htmlFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../../assets/ReportTemplate.html'
        $templateHtml = Get-Content -Path $htmlFilePath -Raw

        # Insert the test results json into the template.
        # Locate the EndOfJson sentinel (handles both double-quote and backtick strings
        # produced by different Vite/Rolldown versions) then walk back to the variable
        # assignment that owns the placeholder object so the same variable name is preserved.
        $endPattern = 'EndOfJson:(?:"EndOfJson"|`EndOfJson`)\}'
        $endMatch = [regex]::Match($templateHtml, $endPattern)
        $insertLocationEnd = $endMatch.Index + $endMatch.Length

        # Find the last variable declaration (var/const/let NAME=) before the end marker.
        $startMatches = [regex]::Matches($templateHtml.Substring(0, $endMatch.Index), '(?:var|const|let)\s+\w+\s*=')
        $startMatch = $startMatches[$startMatches.Count - 1]
        $insertLocationStart = $startMatch.Index + $startMatch.Value.Length  # position just after the '='

        $outputHtml = $templateHtml.Substring(0, $insertLocationStart)
        $outputHtml += $json
        $outputHtml += $templateHtml.Substring($insertLocationEnd)

        return $outputHtml
    }
}

