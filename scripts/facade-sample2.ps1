# 管理者権限で実行され、正常終了するサンプルスクリプト

$ErrorActionPreference = "Stop"

# 管理者権限チェック（facade.ps1から呼ばれる場合は既に管理者権限で実行される）
$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\facade-sample2.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

try {
    WriteInfoLog -logPath $logPath -message "管理者権限サンプル開始"
    WriteInfoLog -logPath $logPath -message "=== facade-sample2.ps1 デバッグ開始 ==="
    
    # シンプルな処理の例
    WriteInfoLog -logPath $logPath -message "facade-sample2.ps1 実行中（管理者権限）..."
    
    # 何らかの管理者権限が必要な処理をシミュレート
    Start-Sleep -Seconds 2
    
    # 管理者権限の確認（重複削除）
    WriteInfoLog -logPath $logPath -message "管理者権限: $isAdmin"
    WriteInfoLog -logPath $logPath -message "実行ユーザー: $($currentUser.Name)"
    WriteInfoLog -logPath $logPath -message "環境変数ユーザー: $($env:USERNAME)"
    
    WriteInfoLog -logPath $logPath -message "facade-sample2.ps1 完了"
    WriteInfoLog -logPath $logPath -message "管理者権限サンプル正常終了"
    WriteInfoLog -logPath $logPath -message "=== facade-sample2.ps1 デバッグ終了（正常） ==="
    
    # 正常終了
    exit 0
}
catch {
    $errorMessage = "facade-sample2.ps1 エラー: $($_.Exception.Message)"
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
finally {
    $Error.Clear()
}
