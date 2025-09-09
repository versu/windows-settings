param (
    [Parameter(Mandatory=$true, HelpMessage="ショートカットのターゲットEXEファイルのフルパスを指定してください")]
    [string]$TargetPath,
    
    [Parameter(Mandatory=$true, HelpMessage="スタートメニューに表示するショートカット名を指定してください")]
    [string]$ShortcutName,
    
    [Parameter(HelpMessage="詳細なログを出力するかどうか")]
    [switch]$DetailedLog
)

. "$PSScriptRoot\..\..\common.ps1"
. "$PSScriptRoot\..\logger.ps1"

$logPath = "$env:LOG_DIR\add-startmenu.log"

try {
    WriteInfoLog -logPath $logPath -message "=== スタートメニューショートカット作成開始 ==="
    WriteInfoLog -logPath $logPath -message "ターゲットパス: $TargetPath"
    WriteInfoLog -logPath $logPath -message "ショートカット名: $ShortcutName"
    
    # ターゲットファイルの存在確認
    if (-not (Test-Path $TargetPath)) {
        $errorMsg = "ターゲットファイルが見つかりません: $TargetPath"
        Write-Host $errorMsg -ForegroundColor Red
        WriteErrorLog -logPath $logPath -message $errorMsg
        exit 1
    }
    
    # スタートメニューのディレクトリパス
    $startMenuDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    WriteInfoLog -logPath $logPath -message "スタートメニューディレクトリ: $startMenuDir"
    
    # ショートカットファイルのパス（拡張子.lnkを自動追加）
    $shortcutFileName = if ($ShortcutName.EndsWith(".lnk")) { $ShortcutName } else { "$ShortcutName.lnk" }
    $shortcutPath = Join-Path $startMenuDir $shortcutFileName
    WriteInfoLog -logPath $logPath -message "ショートカットパス: $shortcutPath"
    
    # ターゲットファイルの作業ディレクトリを取得
    $workingDirectory = Split-Path $TargetPath -Parent
    WriteInfoLog -logPath $logPath -message "作業ディレクトリ: $workingDirectory"
    
    # ショートカットを作成
    Write-Host "スタートメニューにショートカットを作成中..." -ForegroundColor Green
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $TargetPath
    $shortcut.WorkingDirectory = $workingDirectory
    $shortcut.Save()
    
    Write-Host "ショートカットが作成されました: $shortcutPath" -ForegroundColor Green
    WriteInfoLog -logPath $logPath -message "ショートカット作成完了: $shortcutPath"
    WriteInfoLog -logPath $logPath -message "=== スタートメニューショートカット作成完了 ==="
}
catch {
    $errorMessage = "ショートカット作成エラー: $($_.Exception.Message)"
    Write-Host $errorMessage -ForegroundColor Red
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}