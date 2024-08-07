<#  .SYNOPSIS
    Common variables to use with make.build and update.manifest
    .NOTES
    Sources
        - $groupID
        - $packID
        - $depID
    .OUTPUTS
    None
#>

$groupID = "undefin3d"
$packID = "undefin3dCompany"
$depID = "$groupID-$packID-\d+\.\d+\.\d+$"

Write-Debug @"
    Loaded common variables.
    Dependency String: $depID
"@