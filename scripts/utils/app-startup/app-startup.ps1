param(
    [Parameter(Mandatory=$true)]
    [string]$AppPath,
    
    [Parameter(Mandatory=$false)]
    [string]$ShortcutName,
    
    [Parameter(Mandatory=$false)]
    [string]$Arguments = "",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkingDirectory = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$AllUsers
)

function Add-StartupShortcut {
    param(
        [string]$TargetPath,
        [string]$Name,
        [string]$Args,
        [string]$WorkDir,
        [bool]$ForAllUsers
    )
    
    try {
        # アプリケーションのパスが存在するかチェック
        if (-not (Test-Path $TargetPath)) {
            Write-Error "指定されたアプリケーションが見つかりません: $TargetPath"
            return $false
        }
        
        # ショートカット名が指定されていない場合、実行ファイル名を使用
        if ([string]::IsNullOrEmpty($Name)) {
            $Name = [System.IO.Path]::GetFileNameWithoutExtension($TargetPath)
        }
        
        # 作業ディレクトリが指定されていない場合、実行ファイルのディレクトリを使用
        if ([string]::IsNullOrEmpty($WorkDir)) {
            $WorkDir = [System.IO.Path]::GetDirectoryName($TargetPath)
        }
        
        # スタートアップフォルダのパスを決定
        if ($ForAllUsers) {
            $StartupFolder = [Environment]::GetFolderPath('CommonStartup')
            Write-Host "全ユーザー用スタートアップフォルダを使用: $StartupFolder" -ForegroundColor Yellow
        } else {
            $StartupFolder = [Environment]::GetFolderPath('Startup')
            Write-Host "現在のユーザー用スタートアップフォルダを使用: $StartupFolder" -ForegroundColor Green
        }
        
        # ショートカットファイルのフルパス
        $ShortcutPath = Join-Path $StartupFolder "$Name.lnk"
        
        # 既存のショートカットがある場合の確認
        if (Test-Path $ShortcutPath) {
            $choice = Read-Host "ショートカット '$Name.lnk' は既に存在します。上書きしますか？ (Y/N)"
            if ($choice -notmatch '^[Yy]') {
                Write-Host "操作がキャンセルされました。" -ForegroundColor Yellow
                return $false
            }
        }
        
        # WScriptShellオブジェクトを作成
        $WShell = New-Object -ComObject WScript.Shell
        
        # ショートカットオブジェクトを作成
        $Shortcut = $WShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Arguments = $Args
        $Shortcut.WorkingDirectory = $WorkDir
        $Shortcut.WindowStyle = 1  # 通常ウィンドウ
        
        # アイコンを設定（実行ファイルから抽出）
        if ([System.IO.Path]::GetExtension($TargetPath) -eq ".exe") {
            $Shortcut.IconLocation = "$TargetPath,0"
        }
        
        # ショートカットを保存
        $Shortcut.Save()
        
        Write-Host "✓ スタートアップショートカットが正常に作成されました:" -ForegroundColor Green
        Write-Host "  ファイル: $ShortcutPath" -ForegroundColor Cyan
        Write-Host "  対象: $TargetPath" -ForegroundColor Cyan
        if (-not [string]::IsNullOrEmpty($Args)) {
            Write-Host "  引数: $Args" -ForegroundColor Cyan
        }
        
        return $true
        
    } catch {
        Write-Error "ショートカットの作成中にエラーが発生しました: $($_.Exception.Message)"
        return $false
    }
}

function Remove-StartupShortcut {
    param(
        [string]$Name,
        [bool]$ForAllUsers
    )
    
    try {
        # スタートアップフォルダのパスを決定
        if ($ForAllUsers) {
            $StartupFolder = [Environment]::GetFolderPath('CommonStartup')
        } else {
            $StartupFolder = [Environment]::GetFolderPath('Startup')
        }
        
        $ShortcutPath = Join-Path $StartupFolder "$Name.lnk"
        
        if (Test-Path $ShortcutPath) {
            Remove-Item $ShortcutPath -Force
            Write-Host "✓ ショートカット '$Name.lnk' を削除しました。" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ショートカット '$Name.lnk' が見つかりません。" -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Error "ショートカットの削除中にエラーが発生しました: $($_.Exception.Message)"
        return $false
    }
}

function Show-StartupShortcuts {
    param([bool]$ForAllUsers)
    
    if ($ForAllUsers) {
        $StartupFolder = [Environment]::GetFolderPath('CommonStartup')
        Write-Host "`n=== 全ユーザー用スタートアップショートカット ===" -ForegroundColor Yellow
    } else {
        $StartupFolder = [Environment]::GetFolderPath('Startup')
        Write-Host "`n=== 現在のユーザー用スタートアップショートカット ===" -ForegroundColor Green
    }
    
    Write-Host "フォルダ: $StartupFolder`n" -ForegroundColor Cyan
    
    $shortcuts = Get-ChildItem -Path $StartupFolder -Filter "*.lnk" -ErrorAction SilentlyContinue
    
    if ($shortcuts.Count -eq 0) {
        Write-Host "ショートカットが見つかりません。" -ForegroundColor Gray
    } else {
        foreach ($shortcut in $shortcuts) {
            Write-Host "• $($shortcut.Name)" -ForegroundColor White
        }
    }
}

# メイン処理
Write-Host "=== スタートアップアプリ登録スクリプト ===" -ForegroundColor Magenta
Write-Host ""

# 対話モードかパラメータモードかを判定
if ($PSBoundParameters.Count -eq 0) {
    # 対話モード
    Write-Host "対話モードで実行します。" -ForegroundColor Cyan
    Write-Host ""
    
    # 現在のスタートアップショートカットを表示
    Show-StartupShortcuts -ForAllUsers $false
    Show-StartupShortcuts -ForAllUsers $true
    
    Write-Host "`n操作を選択してください:" -ForegroundColor Yellow
    Write-Host "1. ショートカットを追加"
    Write-Host "2. ショートカットを削除"
    Write-Host "3. 終了"
    
    $choice = Read-Host "`n選択 (1-3)"
    
    switch ($choice) {
        "1" {
            $AppPath = Read-Host "アプリケーションのフルパスを入力してください"
            $ShortcutName = Read-Host "ショートカット名を入力してください（空白の場合は自動設定）"
            $Arguments = Read-Host "起動引数を入力してください（不要な場合は空白）"
            $allUsersChoice = Read-Host "全ユーザー用に設定しますか？ (Y/N)"
            $AllUsers = $allUsersChoice -match '^[Yy]'
            
            Add-StartupShortcut -TargetPath $AppPath -Name $ShortcutName -Args $Arguments -ForAllUsers $AllUsers
        }
        "2" {
            $ShortcutName = Read-Host "削除するショートカット名を入力してください（.lnk拡張子は不要）"
            $allUsersChoice = Read-Host "全ユーザー用から削除しますか？ (Y/N)"
            $AllUsers = $allUsersChoice -match '^[Yy]'
            
            Remove-StartupShortcut -Name $ShortcutName -ForAllUsers $AllUsers
        }
        "3" {
            Write-Host "終了します。" -ForegroundColor Gray
            exit 0
        }
        default {
            Write-Host "無効な選択です。" -ForegroundColor Red
            exit 1
        }
    }
} else {
    # パラメータモード
    Write-Host "パラメータモードで実行します。" -ForegroundColor Cyan
    $result = Add-StartupShortcut -TargetPath $AppPath -Name $ShortcutName -Args $Arguments -WorkDir $WorkingDirectory -ForAllUsers $AllUsers.IsPresent
    
    if (-not $result) {
        exit 1
    }
}

Write-Host "`n処理が完了しました。" -ForegroundColor Green
