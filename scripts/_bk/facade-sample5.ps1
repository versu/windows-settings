# 管理者権限で実行され、異常終了するサンプルスクリプト

$ErrorActionPreference = "Stop"

try {
  throw
}
catch {
  Write-Host "facade-sample5.ps1 エラー: $($_.Exception.Message)"
}
