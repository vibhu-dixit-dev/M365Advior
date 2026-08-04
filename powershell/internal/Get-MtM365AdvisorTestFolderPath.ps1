function Get-MtM365AdvisorTestFolderPath {
    $path1 = Join-Path -Path $PSScriptRoot -ChildPath "m365advisor-tests"
    if (Test-Path $path1) { return $path1 }
    $path2 = Join-Path -Path $PSScriptRoot -ChildPath "../m365advisor-tests"
    if (Test-Path $path2) { return $path2 }
    return $path1
}
