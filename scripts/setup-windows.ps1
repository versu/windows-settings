$ErrorActionPreference = "Stop"

# 共通ライブラリの読み込み
$commonScriptPath = "$PSScriptRoot/common.ps1"
. $commonScriptPath

$loggerScriptPath = "$PSScriptRoot/utils/logger.ps1"
. $loggerScriptPath

# ログファイルのパス
$logPath = "$($env:LOG_DIR)/setup-windows.log"

function Enable-DarkMode {
    try {
        WriteInfoLog -logPath $logPath -message "ダークモード設定を開始します"
        
        # 現在のテーマ設定を取得
        $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $currentTheme = Get-ItemPropertyValue -Path $registryPath -Name "AppsUseLightTheme"
        
        $currentThemeName = if ($currentTheme -eq 1) { "ライトモード" } else { "ダークモード" }
        
        WriteInfoLog -logPath $logPath -message "現在のテーマ: $currentThemeName"
        
        # 既にダークモードな場合は何もしない
        if ($currentTheme -eq 0) {
            $message = "ダークモードは既に有効です"
            WriteInfoLog -logPath $logPath -message $message
            return
        }
        
        WriteInfoLog -logPath $logPath -message "ダークモードに変更します"
        
        # テーマ設定をダークモードに変更（0でダークモード）
        WriteInfoLog -logPath $logPath -message "アプリケーションテーマを変更中..."
        Set-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
        
        WriteInfoLog -logPath $logPath -message "システムテーマを変更中..."
        Set-ItemProperty -Path $registryPath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
        
        # エクスプローラーを再起動して設定を反映
        WriteInfoLog -logPath $logPath -message "エクスプローラーを再起動して設定を反映します..."
        Stop-Process -Name "explorer" -Force
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe"
        
        # 成功メッセージ
        $successMessage = "ダークモードに切り替えました（タスクバーの色も更新されました）"
        WriteInfoLog -logPath $logPath -message $successMessage
    }
    catch {
        $errorMessage = "ダークモード設定中にエラーが発生しました: $($_.Exception.Message)"
        WriteErrorLog -logPath $logPath -message $errorMessage
        throw $_
    }
}

function Enable-TaskbarAutoHide {
    try {
        WriteInfoLog -logPath $logPath -message "タスクバー自動隠し設定を開始します"
        
        # レジストリパス
        $registryPath = "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
        
        # 現在の設定値を取得
        $currentSettings = (Get-ItemProperty -Path $registryPath).Settings
        
        # 現在の自動隠し状態を確認（バイト[8]が3なら自動隠し有効）
        $isCurrentlyAutoHide = $currentSettings[8] -eq 3
        $currentStatus = if ($isCurrentlyAutoHide) { "有効" } else { "無効" }
        
        WriteInfoLog -logPath $logPath -message "現在の自動隠し設定: $currentStatus"
        
        # 既に有効な場合は何もしない
        if ($isCurrentlyAutoHide) {
            $message = "タスクバー自動隠し設定は既に有効です"
            WriteInfoLog -logPath $logPath -message $message
            return
        }
        
        WriteInfoLog -logPath $logPath -message "自動隠し設定を有効に変更します"
        
        # 設定値を有効に変更（3で有効）
        $currentSettings[8] = 3
        
        WriteInfoLog -logPath $logPath -message "レジストリ設定を更新中..."
        Set-ItemProperty -Path $registryPath -Name Settings -Value $currentSettings
        
        # エクスプローラーを再起動して設定を反映
        WriteInfoLog -logPath $logPath -message "エクスプローラーを再起動して設定を反映します..."
        Stop-Process -Name "explorer" -Force
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe"
        
        # 成功メッセージ
        $successMessage = "タスクバー自動隠し設定を有効にしました"
        WriteInfoLog -logPath $logPath -message $successMessage
    }
    catch {
        $errorMessage = "タスクバー自動隠し設定中にエラーが発生しました: $($_.Exception.Message)"
        WriteErrorLog -logPath $logPath -message $errorMessage
        throw $_
    }
}

# ダークモード設定を実行
Enable-DarkMode

# タスクバー自動隠し設定を実行
Enable-TaskbarAutoHide
