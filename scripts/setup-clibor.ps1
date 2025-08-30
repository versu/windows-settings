# ---------------------------------------------------------------------------------------
# グローバル変数
# ダウンロードリンクは、公式サイト（https://chigusa-web.com/clibor/download/）を確認し、必要に応じて更新してください
# ---------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# 共通設定を読み込み
. "$PSScriptRoot/common.ps1"

# ログファイルの設定
$logPath = "$env:LOG_DIR/setup-clibor.log"

# ログ関数を読み込み
. "$PSScriptRoot/utils/logger.ps1"

WriteInfoLog -logPath $logPath -message "Clibor セットアップを開始しました"

$downloadUrl = "https://ftp.vector.co.jp/77/51/2750/clibor.zip"
$userHome = $env:USERPROFILE
$installDir = Join-Path $userHome "app\clibor"
$zipPath = Join-Path $installDir "clibor.zip"

# ---------------------------------------------------------------------------------------
# Clibor をインストール
# ---------------------------------------------------------------------------------------
WriteInfoLog -logPath $logPath -message "Clibor をダウンロード・インストール中..."

# インストールディレクトリを作成
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    WriteInfoLog -logPath $logPath -message "インストールディレクトリを作成しました: $installDir" 
}

# zipファイルをダウンロード
WriteInfoLog -logPath $logPath -message "ダウンロード中: $downloadUrl"
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
    WriteInfoLog -logPath $logPath -message "ダウンロード完了: $zipPath"
} catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message "ダウンロードに失敗しました: $errorMessage"
    exit 1
}

# zipファイルを解凍
WriteInfoLog -logPath $logPath -message "解凍中..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
    WriteInfoLog -logPath $logPath -message "解凍完了: $installDir"
} catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message "解凍に失敗しました: $errorMessage"
    exit 1
}

# zipファイルを削除
Remove-Item $zipPath -Force
WriteInfoLog -logPath $logPath -message "一時ファイルを削除しました"

WriteInfoLog -logPath $logPath -message "Clibor ダウンロードが完了しました"
WriteInfoLog -logPath $logPath -message "Clibor の保存先: $installDir"

# ---------------------------------------------------------------------------------------
# Clibor.exe を実行
# ---------------------------------------------------------------------------------------
WriteInfoLog -logPath $logPath -message "Clibor.exe を起動しています..."

# Clibor.exeのパスを検索
$cliborExePath = Get-ChildItem -Path $installDir -Name "Clibor.exe" -Recurse | Select-Object -First 1

if ($cliborExePath) {
    $fullCliborPath = Join-Path $installDir $cliborExePath
    WriteInfoLog -logPath $logPath -message "Clibor.exeを発見しました: $fullCliborPath"
    
    try {
        # Clibor.exeをバックグラウンドで起動
        Start-Process -FilePath $fullCliborPath -WindowStyle Hidden
        WriteInfoLog -logPath $logPath -message "Clibor.exeが正常に起動しました"
    } catch {
        $errorMessage = $_ | Out-String
        WriteErrorLog -logPath $logPath -message "Clibor.exeの起動に失敗しました: $errorMessage"
    }
} else {
    WriteErrorLog -logPath $logPath -message "Clibor.exeが見つかりませんでした"
    exit 1
}

# ---------------------------------------------------------------------------------------
# スタートアップアプリとして登録
# ---------------------------------------------------------------------------------------
if ($fullCliborPath) {
    WriteInfoLog -logPath $logPath -message "Clibor をスタートアップに登録しています"
    
    try {
        # スタートアップに登録する汎用スクリプト
        $startupUtilPath = "$PSScriptRoot/utils/app-startup/app-startup.ps1"
        
        # スタートアップに登録
        & $startupUtilPath -AppPath $fullCliborPath
        WriteInfoLog -logPath $logPath -message "Clibor のスタートアップ登録が完了しました"
    } 
    catch {
        $errorMessage = $_ | Out-String
        WriteErrorLog -logPath $logPath -message "スタートアップ登録に失敗しました: $errorMessage"
    }
}

WriteInfoLog -logPath $logPath -message "Clibor セットアップが正常に完了しました"
