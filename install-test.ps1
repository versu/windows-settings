$installDir = "$($env:USERPROFILE)/repo/github.com/versu/windows-settings-test"

if (Test-Path -Path $installDir -PathType Container) {
  Write-Host "Updating windows-settings..."
  & git -C $installDir pull
} else {
  Write-Host "Installing windows-settings..."
  & git clone https://github.com/versu/windows-settings.git $installDir
}

& "$installDir/scripts/facade.ps1"
