# ------------------------------------------------------------------------------------
# ランチャー
# ------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# 共通設定を読み込み
. "$PSScriptRoot/common.ps1"

# ログファイルの設定
$logPath = "$env:LOG_DIR/setup-ueli.log"

# ログ関数を読み込み
. "$PSScriptRoot/utils/logger.ps1"

WriteInfoLog -logPath $logPath -message "Ueli セットアップを開始しました"

try {
    # Ueli をインストール
    WriteInfoLog -logPath $logPath -message "Ueli をインストールしています"
    winget install --id=OliverSchwendener.ueli  -e
    WriteInfoLog -logPath $logPath -message "Ueli のインストールが完了しました"

    # ueli から設定ファイルをExportした時のデフォルト出力先
    # ueli から設定ファイルを Import する時もこのパスが開くので、Importしやすいようにここにコピーする
    $ueliPath = "$env:LOCALAPPDATA\Programs\ueli"

    # ueliの設定ファイルのパス
    $ueliConfigPath = Join-Path $PSScriptRoot '..\config\ueli\ueli9.settings.json'

    # ueliの設定ファイルをコピー
    WriteInfoLog -logPath $logPath -message "Ueli 設定ファイルをコピーしています: $ueliConfigPath -> $ueliPath"
    Copy-Item $ueliConfigPath -Destination $ueliPath -Force
    WriteInfoLog -logPath $logPath -message "Ueli 設定ファイルのコピーが完了しました"

    # ---------------------------------------------------------------------------------------
    # スタートアップアプリとして登録
    # ---------------------------------------------------------------------------------------
    WriteInfoLog -logPath $logPath -message "Ueli をスタートアップに登録しています"

    # ueliの実行ファイルのパス
    $ueliExePath = Join-Path $ueliPath 'Ueli.exe'

    # スタートアップに登録する汎用スクリプト
    $statupUtilPath = "$($PSScriptRoot)/utils/app-startup/app-startup.ps1"

    # スタートアップに登録
    & $statupUtilPath -AppPath $ueliExePath
    WriteInfoLog -logPath $logPath -message "Ueli のスタートアップ登録が完了しました"

    WriteInfoLog -logPath $logPath -message "Ueli セットアップが正常に完了しました"
    WriteInfoLog -logPath $logPath -message "★Ueli を開き、設定のインポートを行ってください★"
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
