# $env:SCRIPT_FOLDER = Get-Item $MyInvocation.MyCommand.Path | Split-Path
$env:SCRIPT_FOLDER = $PSScriptRoot
$env:CONFIG_FOLDER = "$($env:SCRIPT_FOLDER)/../config"
$env:LOG_DIR = "$($env:SCRIPT_FOLDER)/_logs"

function WriteErrorLog($logPath, $errorMessage, $isOutputErrorToConsole = $True) {
  # ログディレクトリが存在しない場合は作成
  $logDirectory = Split-Path -Path $logPath -Parent
  if (-not (Test-Path -Path $logDirectory)) {
      New-Item -ItemType Directory -Path $logDirectory -Force
  }

  # エラーメッセージをログファイルに書き込む
  Add-Content -Path $logPath -Value $errorMessage

  if ($isOutputErrorToConsole)
  {
    Write-Host $errorMessage -ForegroundColor Red
  }
}
