# 管理者権限で実行していない場合は、管理者権限で再起動
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) { 
    Start-Process powershell.exe "-NoExit -File `"$PSCommandPath`"" -Verb RunAs
    exit 
}

# ---------------------------------------------------------------------------------------
# グローバル変数
# ダウンロードリンクは、公式サイト（https://tablacus.github.io/explorer.html）から必要に応じて更新してください
# ---------------------------------------------------------------------------------------
$downloadUrl = "https://github.com/tablacus/TablacusExplorer/releases/download/25.6.8/te250608.zip"
$userHome = $env:USERPROFILE
$installDir = Join-Path $userHome "app\tablacus-explorer"
$zipPath = Join-Path $installDir "te250608.zip"

# ---------------------------------------------------------------------------------------
# Tablacus Explorer をインストール
# ---------------------------------------------------------------------------------------
Write-Host "install Tablacus Explorer..."

# インストールディレクトリを作成
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Created directory: $installDir"
}

# zipファイルをダウンロード
Write-Host "Downloading: $downloadUrl"
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Download complete: $zipPath"
} catch {
    Write-Error "Download failed: $_"
    exit 1
}

# zipファイルを解凍
Write-Host "Extracting..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
    Write-Host "Extraction complete: $installDir"
} catch {
    Write-Error "Extraction failed: $_"
    exit 1
}

# zipファイルを削除
Remove-Item $zipPath -Force
Write-Host "Temporary files deleted"

Write-Host "Tablacus Explorer setup complete"
Write-Host "Installation location: $installDir"

# ---------------------------------------------------------------------------------------
# スタートメニューにショートカットを作成（これにより、ランチャーから起動可能になる）
# ---------------------------------------------------------------------------------------
$startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
# ショートカットのパス(ここで指定したファイル名がスタートメニューに表示される。この場合、ランチャーから「Filer」と検索すればヒットするようになる)
$shortcutPath = Join-Path $startMenuDir "Filer.lnk"
$targetPath = Join-Path $installDir "TE64.exe"

if (Test-Path $targetPath) {
    Write-Host "Creating shortcut in Start Menu..."
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Save()
    Write-Host "Shortcut created: $shortcutPath"
} else {
    Write-Warning "TE64.exe not found: $targetPath"
}

# ---------------------------------------------------------------------------------------
# スタートアップアプリとして登録
# ---------------------------------------------------------------------------------------

# スタートアップに登録する汎用スクリプト
$statupUtilPath = "$($PSScriptRoot)/utils/app-startup/app-startup.ps1"

# スタートアップに登録
& $statupUtilPath -AppPath $targetPath

# ---------------------------------------------------------------------------------------
# 設定ファイルのシンボリックリンクを設定
# ---------------------------------------------------------------------------------------

Write-Host "symbolic link setup..."

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-tablacus-explorer.log"

try 
{
  Write-Host "symbolic link setup..."

  # git管理している設定ファイルの親ディレクトリのパス（symbolic link from）
  $configDir = Join-Path $env:CONFIG_FOLDER "tablacus"

  # tablacus の設定ファイルがあるディレクトリのパス（symbolic link to)
  $tablacusConfigDir = Join-Path $installDir "config"

  # アドオンに関する設定ファイルのシンボリックリンクを追加
  New-Item -ItemType SymbolicLink -Path $tablacusConfigDir/addons.xml -Target "$($configDir)/addons.xml" -Force

  Write-Host "symbolic link created!: $tablacusConfigDir -> $($configDir)/addons.xml"
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()
  
  # キー入力を待つ
  Write-Host "Press any key to continue..."
  $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
  exit
}

