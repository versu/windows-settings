$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-claude-code.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

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
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()
  WriteInfoLog -logPath $logPath -message "Claude Codeセットアップスクリプトが完了しました"
}
