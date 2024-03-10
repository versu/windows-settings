### このファイルは$env:STARSHIP_CONFIGをsetup-psprofile.ps1内で設定しているため、setup-psprofile.ps1の実行後に実行する必要がある。

# 管理者権限で実行していない場合は、管理者権限で再起動
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$logPath = "$($env:LOG_DIR)\setup-links.log"

$ErrorActionPreference = "Stop"

try 
{
  # starship
  New-Item -ItemType SymbolicLink -Path $env:STARSHIP_CONFIG -Target "$($env:CONFIG_FOLDER)/starship.toml" -Force

  # git
  New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)/.gitconfig" -Target "$($env:CONFIG_FOLDER)/.gitconfig" -Force
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -errorMessage $errorMessage
}
finally
{
  $Error.Clear()
}
