$ErrorActionPreference = "Stop"

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

Invoke-Expression -Command "$($env:SCRIPT_FOLDER)/setup-scope.ps1"
Start-Process powershell.exe -ArgumentList "-File $($env:SCRIPT_FOLDER)/setup-psprofile.ps1" -Verb RunAs -Wait
Start-Process powershell.exe -ArgumentList "-File $($env:SCRIPT_FOLDER)/setup-starship.ps1" -Verb RunAs -Wait
Start-Process powershell.exe -ArgumentList "-File $($env:SCRIPT_FOLDER)/setup-font.ps1" -Verb RunAs -Wait
