function Get-MtM365AdvisorTestFolderPath {
    return Join-Path -Path $PSScriptRoot -ChildPath "../m365advisor-tests"
}
