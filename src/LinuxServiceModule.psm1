If ( -Not $IsLinux ) {
    Throw "This function should only be run on Linux systems"
}

$Public = Join-Path -Path $PSScriptRoot -ChildPath 'Public'
Get-ChildItem -Path $Public | Foreach-Object {
    . $_.FullName
}