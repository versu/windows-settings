# ---------------------------------------------------------------------------
# Public functions
# ---------------------------------------------------------------------------

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
  _WriteLog -logPath $logPath -level "INFO" -message $message

  if ($isOutputMessageToConsole)
  {
    Write-Host $message -ForegroundColor Green
  }
}

function WriteErrorLog {
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
  _WriteLog -logPath $logPath -level "ERROR" -message $message

  if ($isOutputMessageToConsole)
  {
    Write-Host $message -ForegroundColor Red
  }
}

# ---------------------------------------------------------------------------
# Private functions
# ---------------------------------------------------------------------------

function _WriteLog {
  param (
    # 出力先のログファイルのパス
    [Parameter(Mandatory=$true)]
    [string]$logPath,

    # ログレベル
    [Parameter(Mandatory=$true)]
    [string]$level,

    # 出力するメッセージ
    [Parameter(Mandatory=$true)]
    [string]$message
  )
  # ログディレクトリが存在しない場合は作成
  $logDirectory = Split-Path -Path $logPath -Parent
  if (-not (Test-Path -Path $logDirectory)) {
      New-Item -ItemType Directory -Path $logDirectory -Force
  }

  # ログメッセージをログファイルに書き込む
  $logDetails = [pscustomobject]@{
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Level = $level
    Message = $message
  }
  $logDetails | Export-Csv -Path $logPath -Append -NoTypeInformation -Encoding UTF8
}
