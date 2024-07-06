<#  .SYNOPSIS
    Builds the next release of the pack.
    .DESCRIPTION
    Just a shorthand for zipping :D
    .NOTES
    The files and folders
    -   manifest.json
    -   icon.png
    -   README.md
    -   CHANGELOG.md
    -   config/
    MUST be in the working directory a.k.a. besides this script (I'm lazy asf).
    .OUTPUTS
    A zip archive in the 'releases' folder, named according to name and version.
#>

#   Check if we have all the things the modpack needs
$cdr = (Get-ChildItem .).Name
$c = $false
"manifest.json", "icon.png", "README.md", "CHANGELOG.md", "config" | ForEach-Object { $c = $c -or ($cdr -cnotcontains $_) }
if ($c) { throw "Not all requirements found in current working directory." }

#   Zip that mf up in the releases folder
$info = Get-Content -Raw -Path .\manifest.json | ConvertFrom-Json
$newname = "$($info.name)_v$($info.version_number).zip"

#   Compress
try {
    Compress-Archive -Path .\CHANGELOG.md, .\icon.png, .\manifest.json, .\README.md, .\config -DestinationPath ".\releases\$newname" -Verbose
}
catch { throw }
Write-Host "Build complete!"
Write-Host @"
New version: v$($info.version_number)
Path: $((Get-Item ".\releases\$newname").FullName)
"@
