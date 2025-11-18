#--------------------------------------------------------------------------------------------------------------------------------------------------------
# Serena Setup Script
#--------------------------------------------------------------------------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-serena.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

try 
{
  # インストール
  # インストール後に uv/uvx コマンドへのパスを追加する旨が表示されるが、powershell_profile.ps1 に既にパスは追加済み。
  powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()
  WriteInfoLog -logPath $logPath -message "Serena セットアップスクリプトが完了しました"
}
