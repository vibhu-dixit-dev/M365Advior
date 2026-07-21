function Merge-MtM365AdvisorResult {
    <#
     .Synopsis
      Merges multiple M365AdvisorResults objects into a single multi-tenant result for combined HTML reporting.

     .Description
        Takes an array of M365AdvisorResults objects (each from a separate Invoke-M365Advisor run against
        a different tenant) and combines them into a single object with a "Tenants" array.
        The resulting object can be passed to Get-MtHtmlReport to generate a multi-tenant report
        with a tenant selector in the sidebar.

        Accepts either in-memory M365AdvisorResults objects (from Invoke-M365Advisor -PassThru or pipeline)
        or file paths/directories that are loaded automatically via Import-MtM365AdvisorResult.

        All results are included as-is - no deduplication is performed when the same TenantId
        appears multiple times. This is by design to support future scenarios such as historical
        trend reports where multiple runs from the same tenant are intentional.

     .Parameter M365AdvisorResults
        An array of M365AdvisorResults objects, each representing test results from a different tenant.
        Accepts pipeline input from Import-MtM365AdvisorResult.

     .Parameter Path
        One or more paths to JSON result files, glob patterns, or directories.
        Files are loaded via Import-MtM365AdvisorResult internally.
        - File path:  ./production.json
        - Glob:       ./results/*.json
        - Directory:  ./results/  (discovers TestResults-*.json inside)

     .Example
        # Merge from file paths (one-liner)
        Merge-MtM365AdvisorResult -Path ./production.json, ./development.json | Get-MtHtmlReport | Out-File report.html

     .Example
        # Merge from a directory of JSON files
        Merge-MtM365AdvisorResult -Path ./results/ | Get-MtHtmlReport | Out-File report.html

     .Example
        # Merge from a glob pattern
        Merge-MtM365AdvisorResult -Path *.json | Get-MtHtmlReport | Out-File report.html

     .Example
        # Pipeline: Import then merge
        Import-MtM365AdvisorResult -Path *.json | Merge-MtM365AdvisorResult | Get-MtHtmlReport | Out-File report.html

     .Example
        # In-memory: run against two tenants and merge
        $result1 = Invoke-M365Advisor -PassThru
        # ... reconnect to second tenant ...
        $result2 = Invoke-M365Advisor -PassThru

        $merged = Merge-MtM365AdvisorResult -M365AdvisorResults @($result1, $result2)
        $html = Get-MtHtmlReport -M365AdvisorResults $merged
        $html | Out-File -FilePath "MultiTenantReport.html" -Encoding UTF8

    .LINK
        https://m365advisor.dev/docs/commands/Merge-MtM365AdvisorResult

    .NOTES
        ## Design notes for future development

        ### Multi-tenant reports (current)
        This command wraps all results into a Tenants[] array. The HTML report frontend
        detects the Tenants property and renders a tenant selector in the sidebar.
        No deduplication is performed - if the same TenantId appears multiple times,
        all instances are included.

        ### Historical / trend reports (planned)
        A future command (e.g. New-MtTrendReport) can reuse Import-MtM365AdvisorResult to
        load results, then group by TenantId and sort by ExecutedAt within each group.
        Each result already carries TenantId and ExecutedAt, so the intelligence is:

          - Different TenantIds, similar dates  -> multi-tenant (use Merge-MtM365AdvisorResult)
          - Same TenantId, different dates      -> historical trend (use future trend command)
          - Mixed                               -> group by TenantId, each group has a timeline

        Import-MtM365AdvisorResult is intentionally a "dumb loader" that returns everything.
        The consuming command (Merge, Compare, Trend) decides how to interpret the data.

        ### Pipeline architecture
        The intended pipeline pattern is:

          Import-MtM365AdvisorResult -> [Merge | Compare | Trend] -> Get-MtHtmlReport -> Out-File

        Merge-MtM365AdvisorResult also accepts -Path directly for convenience (calls Import
        internally), so the user can skip the Import step for simple scenarios:

          Merge-MtM365AdvisorResult -Path *.json | Get-MtHtmlReport | Out-File report.html
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromObjects')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'FromObjects', ValueFromPipeline = $true)]
        [psobject[]] $M365AdvisorResults,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'FromPath')]
        [string[]] $Path
    )

    begin {
        $collectedResults = [System.Collections.Generic.List[psobject]]::new()
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FromObjects') {
            # Collect pipeline input - may arrive one object at a time
            foreach ($result in $M365AdvisorResults) {
                $collectedResults.Add($result)
            }
        }
    }

    end {
        # If -Path was used, load files via Import-MtM365AdvisorResult
        if ($PSCmdlet.ParameterSetName -eq 'FromPath') {
            $imported = Import-MtM365AdvisorResult -Path $Path
            if ($null -eq $imported -or $imported.Count -eq 0) {
                throw "No valid M365Advisor results found at the specified path(s): $($Path -join ', ')"
            }
            foreach ($result in $imported) {
                $collectedResults.Add($result)
            }
        }

        if ($collectedResults.Count -eq 0) {
            throw "At least one M365AdvisorResults object is required."
        }

        # Validate each result has the expected structure
        foreach ($result in $collectedResults) {
            if (-not ($result.PSObject.Properties.Name -contains 'Tests')) {
                throw "M365AdvisorResults object is missing the 'Tests' property. TenantId: $($result.TenantId)"
            }
        }

        Write-Verbose "Merging $($collectedResults.Count) tenant results into a multi-tenant report."

        $firstResult = $collectedResults[0]

        # Always wrap in Tenants array, even for a single tenant
        $merged = [PSCustomObject]@{
            Tenants        = @($collectedResults)
            CurrentVersion = $firstResult.CurrentVersion
            LatestVersion  = $firstResult.LatestVersion
            EndOfJson      = "EndOfJson"
        }

        return $merged
    }
}

