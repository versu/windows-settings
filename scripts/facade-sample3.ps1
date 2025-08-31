# 通常権限で実行され、異常終了するサンプルスクリプト

$ErrorActionPreference = "Stop"

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\facade-sample3.log"

try {
    WriteInfoLog -logPath $logPath -message "facade-sample3開始"
    
    # シンプルな処理の例
    Write-Host "facade-sample3.ps1 実行中..." -ForegroundColor Green

    # 何らかの処理をシミュレート
    Start-Sleep -Seconds 2

    throw "facade-sample3でエラーが発生しました"

    Write-Host "facade-sample3.ps1 完了" -ForegroundColor Green

    # 正常終了
    exit 0
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
finally {
    $Error.Clear()
}
