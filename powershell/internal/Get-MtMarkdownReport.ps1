function Get-MtMarkdownReport {
    <#
    .Synopsis
     Generates a markdown report using the M365Advisor test results format.

    .Description
       This markdown report can be used in GitHub actions to display the test results in a formatted way.

    .Example
       $pesterResults = Invoke-Pester -PassThru
       $m365advisorResults = ConvertTo-MtM365AdvisorResult -PesterResults $pesterResults
       Get-MtMarkdownReport $m365advisorResults
    #>
    [CmdletBinding()]
    param(
        # The M365Advisor test results returned from `Invoke-Pester -PassThru | ConvertTo-MtM365AdvisorResult`
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $M365AdvisorResults
    )
    $StatusIcon = @{
        Passed      = '<img src="https://m365advisor.dev/img/test-result/pill-pass.png" height="25" alt="Passed"/>'
        Failed      = '<img src="https://m365advisor.dev/img/test-result/pill-fail.png" height="25" alt="Failed"/>'
        NotRun      = '<img src="https://m365advisor.dev/img/test-result/pill-notrun.png" height="25" alt="Not Run"/>'
        Skipped     = '<img src="https://m365advisor.dev/img/test-result/pill-notrun.png" height="25" alt="Skipped"/>'
        Investigate = '<img src="https://m365advisor.dev/img/test-result/pill-investigate.png" height="25" alt="Investigate"/>'
        Error       = '<img src="https://m365advisor.dev/img/test-result/pill-fail.png" height="25" alt="Error"/>'
    }

    $StatusIconSm = @{
        Passed      = '✅'
        Failed      = '❌'
        NotRun      = '❔'
        Skipped     = '🚫'
        Investigate = '🔍'
        Error       = '⚠️'
    }

    $ResultDisplayName = @{
        Passed      = 'Passed'
        Failed      = 'Failed'
        NotRun      = 'Not Run'
        Skipped     = 'Skipped'
        Investigate = 'Investigate'
        Error       = 'Error'
    }

    $SeverityIcon = @{
        Critical = '🔴 Critical'
        High     = '🟠 High'
        Medium   = '🟡 Medium'
        Low      = '🟢 Low'
        Info     = 'ℹ️ Info'
    }

    function GetSeverityText($severity) {
        if ($severity -and $SeverityIcon.ContainsKey($severity)) { return $SeverityIcon[$severity] } else { return $severity }
    }

    function GetTestSummary() {
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.Append(@'
|Test|Severity|Status|
|-|:-:|:-:|

'@)
        foreach ($test in $M365AdvisorResults.Tests) {
            $severityText = GetSeverityText $test.Severity
            [void]$sb.Append("| $($test.Name) | $severityText | $($StatusIcon[$test.Result]) |`n")
        }
        return $sb.ToString()
    }

    function GetTestDetails() {
        $sb = [System.Text.StringBuilder]::new()

        foreach ($test in $M365AdvisorResults.Tests) {

            [void]$sb.Append("### $($StatusIconSm[$test.Result]) $($test.Name)`n`n")

            $severityText = GetSeverityText $test.Severity
            $resultName = if ($ResultDisplayName.ContainsKey($test.Result)) { $ResultDisplayName[$test.Result] } else { $test.Result }
            [void]$sb.Append("**Severity:** $severityText &nbsp;&nbsp;&nbsp;&nbsp; **Status:** $($StatusIconSm[$test.Result]) $resultName`n`n")

            if (![string]::IsNullOrEmpty($test.ResultDetail)) {
                # Test author has provided details
                [void]$sb.Append("#### Overview`n`n$($test.ResultDetail.TestDescription)`n`n")
                [void]$sb.Append("#### Test Results`n`n$($test.ResultDetail.TestResult)`n`n")
            } elseif (![string]::IsNullOrEmpty($test.ScriptBlock)) {
                # Test author has not provided details, use default code in script
                # make sure we do not execute the code in the script block!
                $cleanedScriptBlock = $test.ScriptBlock.ToString() -replace '%\w+%', '' -replace '\$_', '€_' # or show me how I can make it not execute the $_ thing
                [void]$sb.Append("#### Overview`n`n``````ps1`n$cleanedScriptBlock`n```````n`n")
                if (![string]::IsNullOrEmpty($test.ErrorRecord)) {
                    [void]$sb.Append("#### Reason for failure`n`n$($test.ErrorRecord)`n`n")
                }
            }

            if (![string]::IsNullOrEmpty($test.HelpUrl)) { [void]$sb.Append("**Learn more**: [$($test.HelpUrl)]($($test.HelpUrl))`n`n") }
            if (![string]::IsNullOrEmpty($test.Tag)) {
                $tags = '`{0}`' -f ($test.Tag -join '` `')
                [void]$sb.Append("**Tag**: $tags`n`n")
            }

            if (![string]::IsNullOrEmpty($test.Block)) {
                $category = '`{0}`' -f ($test.Block -join '` `')
                [void]$sb.Append("**Category**: $category`n`n")
            }

            if (![string]::IsNullOrEmpty($test.ScriptBlockFile)) { [void]$sb.Append("**Source**: ``$($test.ScriptBlockFile)```n`n") }

            [void]$sb.Append("---`n`n")
        }

        return $sb.ToString()
    }

    $markdownFilePath = Join-Path -Path $PSScriptRoot -ChildPath '../assets/ReportTemplate.md'
    $templateMarkdown = Get-Content -Path $markdownFilePath -Raw

    # Execute functions first so they don't mess with the markdown template
    $textSummary = GetTestSummary
    $textDetails = GetTestDetails

    $templateMarkdown = $templateMarkdown.Replace('%TenandId%', $M365AdvisorResults.TenantId)
    $templateMarkdown = $templateMarkdown.Replace('%TenantName%', $M365AdvisorResults.TenantName)
    $templateMarkdown = $templateMarkdown.Replace('%TenantName%', $M365AdvisorResults.TenantVersion)
    $templateMarkdown = $templateMarkdown.Replace('%ModuleVersion%', $M365AdvisorResults.CurrentVersion)
    $templateMarkdown = $templateMarkdown.Replace('%TestDate%', $M365AdvisorResults.ExecutedAt)
    $templateMarkdown = $templateMarkdown.Replace('%TotalCount%', $M365AdvisorResults.TotalCount)
    $templateMarkdown = $templateMarkdown.Replace('%PassedCount%', $M365AdvisorResults.PassedCount)
    $templateMarkdown = $templateMarkdown.Replace('%FailedCount%', $M365AdvisorResults.FailedCount)
    $templateMarkdown = $templateMarkdown.Replace('%InvestigateCount%', $M365AdvisorResults.InvestigateCount)
    $templateMarkdown = $templateMarkdown.Replace('%SkippedCount%', $M365AdvisorResults.SkippedCount)
    $templateMarkdown = $templateMarkdown.Replace('%NotRunCount%', $M365AdvisorResults.NotRunCount)

    $templateMarkdown = $templateMarkdown.Replace('%TestSummary%', $textSummary)
    $templateMarkdown = $templateMarkdown.Replace('%TestDetails%', $textDetails)

    return $templateMarkdown
}

