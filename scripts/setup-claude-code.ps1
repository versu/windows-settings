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

  # Notion MCP（複数ワークスペース）の登録
  # ※同じ URL のリモート MCP は Claude Code に重複登録できないため、mcp-remote 経由の stdio サーバーとして登録する
  #   認証情報は MCP_REMOTE_CONFIG_DIR でワークスペースごとに保存先を分け、混ざらないようにしている
  #   トークンを含むため %USERPROFILE%\.mcp-auth はリポジトリ管理外とする
  #   npx は Node.js(Volta) に依存するため、setup-volta.ps1 実行後であること
  $notionMcpUrl = "https://mcp.notion.com/mcp"
  foreach ($workspace in @("private", "work")) {
    $serverName = "notion-$workspace"
    $authDir = "$($env:USERPROFILE)\.mcp-auth\$serverName"

    WriteInfoLog -logPath $logPath -message "$serverName の登録確認"
    # ※Windows PowerShell では $ErrorActionPreference = "Stop" 下で native コマンドの stderr をリダイレクトすると例外になるため、cmd 経由で捨てる
    cmd /c "claude mcp get $serverName >nul 2>&1"
    if ($LASTEXITCODE -eq 0) {
      WriteInfoLog -logPath $logPath -message "$serverName は既に登録されています（スキップ）"
    }
    else {
      # ※Windows では npx を直接起動できないため cmd /c 経由で起動する
      #   '--' はクォートしないと PowerShell に解釈されて claude に渡らない場合があるためクォートしている
      claude mcp add --scope user $serverName -e "MCP_REMOTE_CONFIG_DIR=$authDir" '--' cmd /c npx -y mcp-remote $notionMcpUrl
      # ※native コマンドは失敗しても例外にならないため、終了コードで判定する
      if ($LASTEXITCODE -ne 0) { throw "$serverName の登録に失敗しました (exit code: $LASTEXITCODE)" }
      WriteInfoLog -logPath $logPath -message "$serverName を登録しました"
    }

    WriteInfoLog -logPath $logPath -message "$serverName の認証確認"
    if (Get-ChildItem -Path "$authDir\*\*_tokens.json" -ErrorAction SilentlyContinue) {
      WriteInfoLog -logPath $logPath -message "$serverName は既に認証されています（スキップ）"
    }
    else {
      WriteInfoLog -logPath $logPath -message "ブラウザで認証してください。Notion の許可画面では「$workspace」ワークスペースを選択してください"
      WriteInfoLog -logPath $logPath -message "ブラウザが開かない場合は、下に表示される URL を開いてください"
      $env:MCP_REMOTE_CONFIG_DIR = $authDir
      try {
        npx -y -p mcp-remote mcp-remote-client $notionMcpUrl
      }
      finally {
        Remove-Item Env:MCP_REMOTE_CONFIG_DIR -ErrorAction SilentlyContinue
      }
      if (-not (Get-ChildItem -Path "$authDir\*\*_tokens.json" -ErrorAction SilentlyContinue)) {
        throw "$serverName の認証に失敗しました。スクリプトを再実行してください"
      }
      WriteInfoLog -logPath $logPath -message "$serverName の認証が完了しました"
    }
  }
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
