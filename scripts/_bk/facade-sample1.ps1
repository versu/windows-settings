# 通常権限で実行され、正常終了するサンプルスクリプト

$ErrorActionPreference = "Stop"

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\facade-sample1.log"

try {
    WriteInfoLog -logPath $logPath -message "通常権限サンプル開始"
    
    # シンプルな処理の例
    Write-Host "facade-sample1.ps1 実行中..." -ForegroundColor Green
    
    # 何らかの処理をシミュレート
    Start-Sleep -Seconds 2
    
    # 環境変数の確認
    WriteInfoLog -logPath $logPath -message "実行ユーザー: $($env:USERNAME)"
    WriteInfoLog -logPath $logPath -message "スクリプトフォルダ: $($env:SCRIPT_FOLDER)"
    
    Write-Host "facade-sample1.ps1 完了" -ForegroundColor Green
    WriteInfoLog -logPath $logPath -message "通常権限サンプル正常終了"
    
    # 正常終了
    exit 0
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    Write-Host $errorMessage -ForegroundColor Red
    exit 1
}
finally {
    $Error.Clear()
}
