$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-mise.log"

if (!$isAdmin) {
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

try
{
  # インストール
  # ※他の方法（公式スクリプト・Scoop 等）と混在させると古いバイナリが使われることがあるため、winget に統一する
  #   winget 版は mise self-update が使えないので、更新は winget upgrade jdx.mise で行う
  WriteInfoLog -logPath $logPath -message "miseのインストールを開始します"
  winget install -e --id jdx.mise
  WriteInfoLog -logPath $logPath -message "miseのインストールが完了しました"

  # shims をユーザー PATH に追加
  # ※PowerShell プロファイルでの mise activate だと、Git Bash（Claude Code の Bash ツール）や VS Code 拡張から
  #   mise で入れたツールが見えないため、shims 方式にする
  #   参考: https://zenn.dev/tetradice/articles/e963950998f2db
  $shimsPath = "$($env:LOCALAPPDATA)\mise\shims"
  # ※winget が末尾に ";" を残すことがあるため、空要素ができないよう除去してから追加する
  $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User").TrimEnd(';')
  if (($userPath -split ';') -notcontains $shimsPath) {
    WriteInfoLog -logPath $logPath -message "shims をユーザー PATH に追加します: $shimsPath"
    [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$shimsPath", "User")
  }

  # 環境変数を再読み込み
  # ※インストール時に設定された PATH が現在のセッションには反映されないため、明示的に再読み込みを行う
  $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

  # インストール確認
  # ※mise は新バージョンの通知などを stderr に出す。Windows PowerShell では $ErrorActionPreference = "Stop" 下で
  #   native コマンドの stderr をリダイレクトすると例外になるため、以降の mise は cmd 経由で実行する
  WriteInfoLog -logPath $logPath -message "インストールされたバージョン: $(cmd /c "mise --version 2>nul")"

  WriteInfoLog -logPath $logPath -message "config.toml のシンボリックリンクを作成します"
  # ※リンクを作成する親ディレクトリが存在しないと失敗するため、先に作成しておく
  New-Item -ItemType Directory -Path "$($env:USERPROFILE)/.config/mise" -Force | Out-Null
  New-Item -ItemType SymbolicLink -Path "$($env:USERPROFILE)/.config/mise/config.toml" -Target "$($env:CONFIG_FOLDER)/mise/config.toml" -Force
  WriteInfoLog -logPath $logPath -message "シンボリックリンクの作成が完了しました"

  # config.toml に定義されたツールをインストール
  WriteInfoLog -logPath $logPath -message "config.toml のツールをインストールします"
  $installOutput = cmd /c "mise install 2>&1" | Out-String
  if ($LASTEXITCODE -ne 0) {
    throw "mise install に失敗しました: $installOutput"
  }
  WriteInfoLog -logPath $logPath -message $installOutput
  WriteInfoLog -logPath $logPath -message "ツールのインストールが完了しました"
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
