# 管理者権限で実行していない場合は、管理者権限で再起動
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$logPath = "$($env:LOG_DIR)\setup-starship.log"

$ErrorActionPreference = "Stop"

try 
{
  # シンボリックリンクの作成
  New-Item -ItemType SymbolicLink -Path $env:STARSHIP_CONFIG -Target "$($env:CONFIG_FOLDER)/starship.toml" -Force
}
catch 
{
  WriteErrorLog -logPath $logPath -errorMessage $_
}
finally
{
  $Error.Clear()
}
