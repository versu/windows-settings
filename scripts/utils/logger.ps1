function WriteInfoLog {
  param (
    # 出力先のログファイルのパス
    [Parameter(Mandatory=$true)]
    [string]$logPath,

    # 出力するメッセージ
    [Parameter(Mandatory=$true)]
    [string]$message,

    # メッセージをコンソールにも出力するかどうか
    [bool]$isOutputMessageToConsole = $true
  )
  # ログディレクトリが存在しない場合は作成
  $logDirectory = Split-Path -Path $logPath -Parent
  if (-not (Test-Path -Path $logDirectory)) {
      New-Item -ItemType Directory -Path $logDirectory -Force
  }

  # INFOメッセージをログファイルに書き込む
  $infoDetails = [pscustomobject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Level = "INFO"
    Message = $message
  }
  $infoDetails | Export-Csv -Path $logPath -Append -NoTypeInformation -Encoding UTF8

  if ($isOutputMessageToConsole)
  {
    Write-Host $message -ForegroundColor Green
  }
}

