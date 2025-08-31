### このファイルは$env:STARSHIP_CONFIGをsetup-psprofile.ps1内で設定しているため、setup-psprofile.ps1の実行後に実行する必要がある。

$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-links.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

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
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()
}
