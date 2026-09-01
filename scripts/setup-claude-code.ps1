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
  # インストール
  # ※公式推奨のネイティブインストーラ。Node.js に依存せず、バックグラウンドで自動更新される。
  #   バイナリは %USERPROFILE%\.local\bin\claude.exe に配置される。
  #   (このパスは powershell_profile.ps1 で PATH に追加済みのため、ここでの PATH 設定は不要)
  WriteInfoLog -logPath $logPath -message "Claude Codeのインストールを開始します"
  powershell -ExecutionPolicy ByPass -c "irm https://claude.ai/install.ps1 | iex"
  WriteInfoLog -logPath $logPath -message "Claude Codeのインストールが完了しました"

  # 環境変数を再読み込み
  # ※インストール時に環境変数にclaudeへのパスが設定されるが現在のセッションには反映されないため、明示的に再読み込みを行う
  $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

  # インストール確認
  WriteInfoLog -logPath $logPath -message "インストールされたバージョン: $(claude --version)"

  WriteInfoLog -logPath $logPath -message "CLAUDE.mdのシンボリックリンクを作成します"
  New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)/CLAUDE.md" -Target "$($env:CONFIG_FOLDER)/claude/CLAUDE.md" -Force
  WriteInfoLog -logPath $logPath -message "シンボリックリンクの作成が完了しました"

  WriteInfoLog -logPath $logPath -message "settings.json のシンボリックリンクを作成します"
  # ※リンクを作成する親ディレクトリが存在しないと失敗するため、先に作成しておく
  New-Item -ItemType Directory -Path "$($env:USERPROFILE)/.claude" -Force | Out-Null
  New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)/.claude/settings.json" -Target "$($env:CONFIG_FOLDER)/claude/settings.json" -Force
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
