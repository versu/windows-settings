# 管理者権限で実行され、異常終了するサンプルスクリプト

$ErrorActionPreference = "Stop"

# 管理者権限チェック（facade.ps1から呼ばれる場合は既に管理者権限で実行される）
$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\facade-sample4.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

try {
    WriteInfoLog -logPath $logPath -message "facade-sample4 開始"

    # 何らかの管理者権限が必要な処理をシミュレート
    Start-Sleep -Seconds 2

    throw "facade-sample4でエラーが発生しました"

    WriteInfoLog -logPath $logPath -message "facade-sample4.ps1 完了"
    
    # 正常終了
    exit 0
}
catch {
    $errorMessage = "facade-sample4.ps1 エラー: $($_.Exception.Message)"
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
finally {
    $Error.Clear()
}
