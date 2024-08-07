<#  .SYNOPSIS
    Updates the manifest with ONLY version and dependencyString
    .DESCRIPTION
    A niche script to help revise my modpack's properties.

    Requires one input:
    *   ManifestPath:   The path of the manifest.json file

    Optional inputs:
    *   Version:    The new version in string SemVer format
    *   Deps:       The path of the plaintext dependency strings, copied from r2modman
    .INPUTS
    Accepts manifest.json path from pipeline.
    .OUTPUTS
    None.
    .EXAMPLE
    .\update.manifest.ps1 -ManifestPath manifest.json -Version "1.2.3" -Deps .\deps.txt
    Got dependecies from '.\deps.txt'
    Set new version to: 1.2.3
    Successfully applied changes to '.\manifest.json'!
#>
param (
    # Specifies a path to the manifest.json.
    [Parameter(Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Path to manifest.json")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
        {
            try {
                $temp = ConvertFrom-Json (Get-Content -Raw -Path $_)
            }
            catch {
                return $false
            }
            return ($null -ne $temp.name) -and 
                   ($null -ne $temp.version_number) -and
                   ($null -ne $temp.website_url) -and
                   ($null -ne $temp.description) -and
                   ($null -ne $temp.dependencies)
        },
        ErrorMessage = "Not a valid r2modman manifest.json"
    )]
    [string]
    $ManifestPath,
    # Specifies the new version number.
    [Parameter(Mandatory = $false,
        HelpMessage = "New version number in SemVer format (e.g. 1.1.5)")]
    [ValidatePattern("^([0-9]+\.[0-9]+\.[0-9]+)$")]
    [String]
    $Version,
    # Specifies a path to the plaintext dependency string file.
    [Parameter(Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = "Path to the plaintext dependency string file")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Deps
)

# If IDs change, go to _common.ps1
. .\_common.ps1

# Read the manifest
$mf = ConvertFrom-Json (Get-Content -Raw -Path $ManifestPath)

# If deps are present:
if ($null -ne $Deps -and "" -ne $Deps) {
    $inDeps = Get-Content -Path $Deps

    # Check if our own plugin depString is inside
    if (($inDeps -match $depID).Length -gt 0)
    {
        $inDeps = ($inDeps -replace ($depID),"") -notmatch "^\s*$"
        Write-Host "Found own dependency string, skipping"
    }

    # Check if every string is a valid depString
    $depMatch = "(\w+)\-(\w+)\-(\d+\.\d+\.\d+)$"
    if ($err = $inDeps -notmatch $depMatch)
    {
        throw @"
One or more dependency strings are not valid.
List of invalid strings:
$($err -join "`n")
"@ 
    }

    # Finally write to the object

    $mf.dependencies = $inDeps
    Write-Host "Got dependencies from '$Deps'"
}

# If version is present:
if ($null -ne $Version -and "" -ne $Version) {
    $mf.version_number = $Version
    Write-Host "Set new version to: $Version"
}

# Finally: save
ConvertTo-Json $mf | Set-Content $ManifestPath
Write-Host "Successfully applied changes to '$ManifestPath'!"
