# forked from MarkTiedemann/download-latest-release.ps1
# Download latest releases from $repo/$file from github

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $repo,
    
    [Parameter()]
    [string]
    $file,

    [Parameter()]
    [string]
    $downloaddir
)

$ErrorActionPreference = "Stop"

if (!(Test-Path -Path $downloaddir)){
  New-Item -Path $downloaddir -ItemType Directory
}

$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name

$download = "https://github.com/$repo/releases/download/$tag/$file"
$name = $file.Split(".")[0]
$zip = [System.IO.Path]::Combine($downloaddir, "$name-$tag.zip")
$dir = "$name-$tag"

Write-Host Dowloading latest release
Invoke-WebRequest $download -Out $zip

Write-Host Extracting release files
Expand-Archive $zip -DestinationPath $downloaddir\$dir -Force

# Cleaning up target dir
# Remove-Item $name -Recurse -Force -ErrorAction SilentlyContinue 

# Moving from temp dir to target dir
Move-Item $downloaddir\$dir\$name -Destination $downloaddir\$name -Force

# Removing temp files
# Remove-Item $zip -Force
Remove-Item $downloaddir\$dir -Recurse -Force
