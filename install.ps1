$installDir = "$($env:USERPROFILE)/repos/github.com/windows-settings-test"

if (Test-Path -Path $installDir -PathType Container) {
  Write-Host "Updating dotfiles..."
  & git -C $installDir pull
} else {
  Write-Host "Installing dotfiles..."
  & git clone https://github.com/versu/windows-settings.git $installDir
}

& "$installDir/scripts/test.ps1"
