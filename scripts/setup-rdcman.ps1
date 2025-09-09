# ------------------------------------------------------------------------------------
# ランチャー
# ------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# 共通設定を読み込み
. "$PSScriptRoot/common.ps1"

# ログファイルの設定
$logPath = "$env:LOG_DIR/setup-rdcman.log"

# ログ関数を読み込み
. "$PSScriptRoot/utils/logger.ps1"

WriteInfoLog -logPath $logPath -message "RDCMan セットアップを開始しました"

try {
    # ------------------------------------------------------------------------------------
    # RDCMan (Remote Desktop Connection Manager)をインストール
    # インストール後、rdcman というコマンドが使えるようになる（要ターミナル再起動）
    # rdcmanコマンドでRDCManを起動できる。
    # ------------------------------------------------------------------------------------
    WriteInfoLog -logPath $logPath -message "RDCMan をインストールしています"
    winget install -e --id=Microsoft.Sysinternals.RDCMan
    WriteInfoLog -logPath $logPath -message "RDCMan のインストールが完了しました"

    # ---------------------------------------------------------------------------------------
    # RDCMan のインストールディレクトリを取得
    # ---------------------------------------------------------------------------------------
    WriteInfoLog -logPath $logPath -message "RDCMan のインストールディレクトリを取得しています"
    
    # find-winget-package-pathスクリプトを実行してrdcmanパッケージのディレクトリを取得
    $findPackageScript = "$PSScriptRoot/utils/find-winget-package-path/find-winget-package-path.ps1"
    $rdcmanInstallDir = & $findPackageScript -PackageName "rdcman"
    
    # パッケージディレクトリが見つからない場合はエラー
    if ([string]::IsNullOrEmpty($rdcmanInstallDir)) {
        throw "RDCMan のインストールディレクトリが見つかりません"
    }
    
    WriteInfoLog -logPath $logPath -message "RDCMan インストールディレクトリ: $rdcmanInstallDir"
    
    # RDCMan.exeの存在確認
    $rdcmanExePath = Join-Path $rdcmanInstallDir "RDCMan.exe"
    if (-not (Test-Path $rdcmanExePath)) {
        throw "RDCMan.exe が見つかりません: $rdcmanExePath"
    }
    
    WriteInfoLog -logPath $logPath -message "RDCMan.exe のパス: $rdcmanExePath"

    # ---------------------------------------------------------------------------------------
    # スタートメニューにショートカットを作成（これにより、ランチャーから起動可能になる）
    # ---------------------------------------------------------------------------------------
    WriteInfoLog -logPath $logPath -message "スタートメニューにショートカットを作成しています"
    
    # add-startmenuユーティリティを使用してショートカットを作成
    $addStartMenuScript = "$PSScriptRoot/utils/add-startmenu/add-startmenu.ps1"
    & $addStartMenuScript -TargetPath $rdcmanExePath -ShortcutName "rdcman"
    
    WriteInfoLog -logPath $logPath -message "スタートメニューのショートカット作成が完了しました"
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
