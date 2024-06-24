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
  $errorDetails = [pscustomobject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    ErrorMessage = $errorMessage
  }
  $errorDetails | Export-Csv -Path $logPath -Append -NoTypeInformation -Encoding UTF8

  if ($isOutputErrorToConsole)
  {
    Write-Host $errorMessage -ForegroundColor Red
  }
}
