param(
    # 管理者権限への昇格で起動し直されたかどうか（スクリプト内部で使用）
    [switch]$Elevated
)

$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# 管理者権限がなければ、昇格して起動し直す
# ※ログオン時に起動するタスクの登録に管理者権限が必要なため
if (!$isAdmin) {
    $processArgs = @(
        "-ExecutionPolicy", "Bypass"
        "-NoProfile"
        "-File", "`"$PSCommandPath`""
        "-Elevated"
    )
    $process = Start-Process (Get-Process -Id $PID).Path -ArgumentList $processArgs -Verb RunAs -Wait -PassThru
    exit $process.ExitCode
}

$commonScriptPath = "$($PSScriptRoot)/../common.ps1"
. $commonScriptPath

$loggerScriptPath = "$($PSScriptRoot)/../utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-wsl-ssh.log"

# WSL の distro に Windows から SSH で接続できるようにする
# ※Orca は WSL 内のリポジトリを UNC パス（\\wsl.localhost\...）で開くと不具合が多いため、
#   SSH ホストとして登録して WSL 側で git・ターミナル・エージェントを動かす
# ※Windows 側で OpenSSH Server を有効にしても衝突しないよう、22 ではなく 2222 を使う
$sshPort = 2222
$hostAlias = "wsl"
$sshDir = "$($env:USERPROFILE)\.ssh"
$keyPath = "$sshDir\id_ed25519_wsl"
$sshConfigPath = "$sshDir\config"
$taskName = "Keep WSL Running"
$openSshDir = "$($env:SystemRoot)\System32\OpenSSH"

try
{
  # 既定の distro を対象にする
  $distro = (wsl.exe --exec printenv WSL_DISTRO_NAME | Out-String).Trim()
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($distro)) {
    throw "WSL の既定の distro を取得できませんでした。WSL がインストールされているか確認してください。"
  }
  $wslUser = (wsl.exe -d $distro --exec whoami | Out-String).Trim()
  WriteInfoLog -logPath $logPath -message "対象の distro: $distro（ユーザー: $wslUser）"

  # 接続用の鍵を作成
  # ※Orca から使うため、パスフレーズなしの専用鍵にする（sshd は 127.0.0.1 でしか待ち受けない）
  New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
  if (!(Test-Path $keyPath)) {
    WriteInfoLog -logPath $logPath -message "SSH 鍵を作成します: $keyPath"
    & "$openSshDir\ssh-keygen.exe" -t ed25519 -N '""' -C "wsl-$distro" -f $keyPath | Out-Null
  }
  $publicKey = (Get-Content "$keyPath.pub" -Raw).Trim()

  # WSL 側の sshd を設定
  # ※Windows PowerShell では $ErrorActionPreference = "Stop" 下で native コマンドの stderr を
  #   リダイレクトすると例外になるため、cmd 経由で実行する
  WriteInfoLog -logPath $logPath -message "WSL 側の sshd を設定します"
  $shPath = (wsl.exe -d $distro --exec wslpath -a "$($PSScriptRoot)\setup-sshd.sh" | Out-String).Trim()
  $sshdOutput = cmd /c "wsl.exe -d $distro -u root --exec bash `"$shPath`" $sshPort $wslUser `"$publicKey`" 2>&1" | Out-String
  if ($LASTEXITCODE -ne 0) {
    throw "WSL 側の sshd の設定に失敗しました: $sshdOutput"
  }
  WriteInfoLog -logPath $logPath -message $sshdOutput

  # ~/.ssh/config に接続先を追加（同名の Host があれば何もしない）
  # ※Orca は ~/.ssh/config の Host を取り込めるため、ここに定義しておく
  # ※Windows では localhost が ::1 に解決されることがあるため、127.0.0.1 を指定する
  if (!(Test-Path $sshConfigPath)) {
    New-Item -ItemType File -Path $sshConfigPath | Out-Null
  }
  if (Select-String -Path $sshConfigPath -Pattern "^\s*Host\s+$hostAlias\s*$" -Quiet) {
    WriteInfoLog -logPath $logPath -message "~/.ssh/config に Host $hostAlias は定義済みのため、追加しません"
  }
  else {
    WriteInfoLog -logPath $logPath -message "~/.ssh/config に Host $hostAlias を追加します"
    $hostEntry = @"

Host $hostAlias
    HostName 127.0.0.1
    Port $sshPort
    User $wslUser
    IdentityFile $keyPath
"@
    Add-Content -Path $sshConfigPath -Value $hostEntry -Encoding ascii
  }

  # ログオン時に WSL を起動し、起動したままにするタスクを登録
  # ※WSL は wsl.exe のクライアントがなくなるとしばらくして distro を停止し、sshd も止まってしまうため、
  #   sleep infinity を動かし続けて distro を維持する
  # ※wsl.exe を直接起動するとコンソールウィンドウが表示されるため、conhost --headless 経由で起動する
  # ※実行時間の上限（既定 72 時間）で停止しないよう、ExecutionTimeLimit を無制限にする
  WriteInfoLog -logPath $logPath -message "タスク '$taskName' を登録します"
  $wslPath = (Get-Command wsl.exe).Source
  $userId = "$($env:USERDOMAIN)\$($env:USERNAME)"
  $action = New-ScheduledTaskAction -Execute "$($env:SystemRoot)\System32\conhost.exe" -Argument "--headless `"$wslPath`" -d $distro --exec sleep infinity"
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
  $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
  $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::Zero) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
  Start-ScheduledTask -TaskName $taskName
  WriteInfoLog -logPath $logPath -message "タスクの登録が完了しました"

  # 接続確認
  # ※初回接続時にホスト鍵を known_hosts に登録する（Orca も known_hosts でホスト鍵を検証する）
  WriteInfoLog -logPath $logPath -message "SSH の接続を確認します"
  $sshOutput = cmd /c "`"$openSshDir\ssh.exe`" -o BatchMode=yes -o StrictHostKeyChecking=accept-new $hostAlias echo connected 2>&1" | Out-String
  if ($LASTEXITCODE -ne 0) {
    throw "SSH で接続できませんでした: $sshOutput"
  }
  WriteInfoLog -logPath $logPath -message "ssh $hostAlias で接続できました"
}
catch
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()

  # 昇格して起動したウィンドウはすぐに閉じてしまい結果を確認できないため、入力を待つ
  if ($Elevated) {
    Read-Host "Enter キーを押すと終了します"
  }
}
