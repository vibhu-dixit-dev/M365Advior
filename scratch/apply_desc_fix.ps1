$psm1 = 'C:\Users\VibhuDixit\OneDrive - Meridian Solutions\Desktop\FINAL\M365-Audit\module\Audit365\Audit365.psm1'
$lines = [System.IO.File]::ReadAllLines($psm1, [System.Text.Encoding]::UTF8)

# Find target line: $Description = $mdDescription
$targetIdx = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s*\$Description = \$mdDescription') {
        $targetIdx = $i
        break
    }
}

if ($targetIdx -ge 0) {
    Write-Host "Found target line at index $targetIdx"
    
    $insertLines = @(
'                } elseif ($callerName) {',
'                    try {',
'                        $cmdObj = Get-Command $callerName -ErrorAction SilentlyContinue',
'                        if ($cmdObj) {',
'                            $helpInfo = Get-Help $cmdObj -ErrorAction SilentlyContinue',
'                            if ($helpInfo) {',
'                                $syn = if ($helpInfo.synopsis) { $helpInfo.synopsis.Trim() } else { "" }',
'                                $descText = ""',
'                                if ($helpInfo.description) {',
'                                    if ($helpInfo.description -is [array]) {',
'                                        $descText = ($helpInfo.description | ForEach-Object { $_.Text }) -join "`n`n"',
'                                    } elseif ($helpInfo.description.Text) {',
'                                        $descText = $helpInfo.description.Text',
'                                    } else {',
'                                        $descText = $helpInfo.description.ToString()',
'                                    }',
'                                }',
'                                $descText = $descText.Trim()',
'',
'                                if ($syn -and $descText) {',
'                                    $Description = "$syn`n`n$descText"',
'                                } elseif ($descText) {',
'                                    $Description = $descText',
'                                } elseif ($syn) {',
'                                    $Description = $syn',
'                                }',
'                            }',
'                        }',
'                    } catch {',
'                        Write-Warning "Failed to auto-populate description from command help: $($_.Exception.Message)"',
'                    }',
'                }'
    )

    # Insert after line ($targetIdx + 2) which is the closing brace of `if ($markdownPath...)`
    $insertAt = $targetIdx + 2
    Write-Host "Inserting block after line $($insertAt + 1): $($lines[$insertAt])"

    $newList = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($i -eq $insertAt) {
            # Replace the lone closing brace line with our elseif block
            foreach ($line in $insertLines) {
                $newList.Add($line)
            }
        } else {
            $newList.Add($lines[$i])
        }
    }

    [System.IO.File]::WriteAllLines($psm1, $newList, [System.Text.Encoding]::UTF8)
    Write-Host "SUCCESSFULLY INJECTED GET-HELP FALLBACK INTO Audit365.psm1!"
} else {
    Write-Host "Target line NOT found!"
}
