# 管理者権限で実行していない場合は、管理者権限で再起動
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { Start-Process powershell.exe "-NoExit -File `"$PSCommandPath`"" -Verb RunAs; exit }

$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-claude-code.log"

$ErrorActionPreference = "Stop"

try 
{
  WriteInfoLog -logPath $logPath -message "Claude Codeのインストールを開始します"
  npm install -g @anthropic-ai/claude-code@latest
  WriteInfoLog -logPath $logPath -message "Claude Codeのインストールが完了しました"

  WriteInfoLog -logPath $logPath -message "CLAUDE.mdのシンボリックリンクを作成します"
  New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)/CLAUDE.md" -Target "$($env:CONFIG_FOLDER)/claude/CLAUDE.md" -Force
  WriteInfoLog -logPath $logPath -message "シンボリックリンクの作成が完了しました"
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -errorMessage $errorMessage
}
finally
{
  $Error.Clear()
  WriteInfoLog -logPath $logPath -message "Claude Codeセットアップスクリプトが完了しました"
}
