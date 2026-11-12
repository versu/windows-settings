# ------------------------------------------------------------------------------------
# Docker Desktop
# ------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# 共通設定を読み込み
. "$PSScriptRoot/common.ps1"

# ログファイルの設定
$logPath = "$env:LOG_DIR/setup-docker.log"

# ログ関数を読み込み
. "$PSScriptRoot/utils/logger.ps1"

WriteInfoLog -logPath $logPath -message "Docker Desktop セットアップを開始しました"

try {
    $dockerExePath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    if (-not (Test-Path $dockerExePath)) {
        throw "Docker Desktop が見つかりません。先にインストールしてください: $dockerExePath"
    }

    # 起動中だと終了時に設定ファイルが上書きされるため、先に終了してもらう
    if (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue) {
        throw "Docker Desktop が起動中です。終了してから再実行してください"
    }

    # ---------------------------------------------------------------------------------------
    # Docker Desktop の設定「Start Docker Desktop when you sign in」を有効化
    # ---------------------------------------------------------------------------------------
    $settingsPath = "$env:APPDATA\Docker\settings-store.json"
    if (Test-Path $settingsPath) {
        WriteInfoLog -logPath $logPath -message "AutoStart を有効化しています: $settingsPath"
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $settings | Add-Member -NotePropertyName "AutoStart" -NotePropertyValue $true -Force
        # BOM なし UTF-8 で書き戻す
        [System.IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 10))
    }
    else {
        WriteInfoLog -logPath $logPath -message "設定ファイルがありません（未起動）。スタートアップ登録のみ行います: $settingsPath"
    }

    # ---------------------------------------------------------------------------------------
    # スタートアップ（Run キー）に登録し、タスクマネージャー上の状態を「有効」にする
    # ---------------------------------------------------------------------------------------
    WriteInfoLog -logPath $logPath -message "Docker Desktop をスタートアップに登録しています"

    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    Set-ItemProperty -Path $runKey -Name "Docker Desktop" -Value $dockerExePath

    # 先頭バイトが 02 なら有効、03 なら無効（タスクマネージャーで無効化すると 03 になる）
    $approvedKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"
    if (-not (Test-Path $approvedKey)) {
        New-Item -Path $approvedKey -Force | Out-Null
    }
    $enabled = [byte[]](0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    Set-ItemProperty -Path $approvedKey -Name "Docker Desktop" -Value $enabled -Type Binary

    WriteInfoLog -logPath $logPath -message "Docker Desktop のスタートアップ登録が完了しました"

    WriteInfoLog -logPath $logPath -message "Docker Desktop セットアップが正常に完了しました"
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
