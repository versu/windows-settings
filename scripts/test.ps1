# common.ps1のフルパスを取得
$commonScriptPath = Join-Path (Get-Item $MyInvocation.MyCommand.Path | Split-Path) "common.ps1"

# common.ps1を読み込む
. $commonScriptPath


Write-Host "test.ps1 called!!"
Write-Host $env:CURRENT_FOLDER

Invoke-Expression -Command "$($env:CURRENT_FOLDER)/test2.ps1"
