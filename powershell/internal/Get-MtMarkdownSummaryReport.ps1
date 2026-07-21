function Get-MtMarkdownSummaryReport {
    <#
    .Synopsis
    Generates a compact markdown summary report with only result counters.

    .Description
    This markdown report is intended for quick sharing in pull requests, tickets,
    and workflow summaries where only the top-level result counts are needed.
    #>
    [CmdletBinding()]
    param(
        # The M365Advisor test results returned from Invoke-M365Advisor -PassThru
        [Parameter(Mandatory = $true, Position = 0)]
        [psobject] $M365AdvisorResults
    )

    $tenantDisplay = if (![string]::IsNullOrEmpty($M365AdvisorResults.TenantName)) {
        "$($M365AdvisorResults.TenantName) ($($M365AdvisorResults.TenantId))"
    } else {
        "Tenant ID: $($M365AdvisorResults.TenantId)"
    }

    $executedAt = $M365AdvisorResults.ExecutedAt

    $lines = @(
        '# M365Advisor Test Results Summary'
        ''
        "**Tenant:** $tenantDisplay"
        "**Date:** $executedAt"
        ''
        '| Metric | Count |'
        '| - | -: |'
        "| Passed ✅ | $($M365AdvisorResults.PassedCount) |"
        "| Failed ❌ | $($M365AdvisorResults.FailedCount) |"
        "| Investigate 🕵️ | $($M365AdvisorResults.InvestigateCount) |"
        "| Skipped ⏭️ | $($M365AdvisorResults.SkippedCount) |"
        "| Error ⚠️ | $($M365AdvisorResults.ErrorCount) |"
        "| Not Run 🛑 | $($M365AdvisorResults.NotRunCount) |"
        "| Total 📊 | $($M365AdvisorResults.TotalCount) |"
    )

    return ($lines -join "`n")
}

