# ------------------------------------------------------------------------------------
# Obsidian Vault セットアップ
# ------------------------------------------------------------------------------------

$ErrorActionPreference = "Stop"

# 共通設定を読み込み
. "$PSScriptRoot/common.ps1"

# ログファイルの設定
$logPath = "$env:LOG_DIR/setup-obsidian.log"

# ログ関数を読み込み
. "$PSScriptRoot/utils/logger.ps1"

WriteInfoLog -logPath $logPath -message "Obsidian vault セットアップを開始しました"

# クローン先のディレクトリパス
$vaultPath = "$HOME/repo/github.com/versu/obsidian-vault"

# Obsidian をインストール
winget install -e --id=Obsidian.Obsidian

try {
    # Obsidian Vault をクローン
    if (Test-Path $vaultPath) {
        # 既にディレクトリが存在する場合はスキップ
        WriteInfoLog -logPath $logPath -message "ディレクトリは既に存在します: $vaultPath. インストールをスキップします"

    }
    else {
        WriteInfoLog -logPath $logPath -message "Obsidian vault をクローンしています: $vaultPath"

        # リポジトリをクローン
        git clone https://github.com/versu/obsidian-vault.git $vaultPath
        WriteInfoLog -logPath $logPath -message "Obsidian vault セットアップが正常に完了しました"
    }
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
