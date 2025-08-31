# 適切なログメッセージを表示

$ErrorActionPreference = "Stop"

# ✅事前に開発者モードを有効にしておくこと(この手順は不要っぽい)

# インストール
winget install --id=Volta.Volta  -e

# 環境変数を再読み込み
# ※インストール時に環境変数にvoltaへのパスが設定されるが現在のセッションには反映されないため、明示的に再読み込みを行う
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

# インストール確認(powershellを開きなおす必要あり)
volta -v

# Node.jsの安定版をインストール
# ついでにnpmもインストールされる
# インストールしたバージョンがデフォルトして設定され、グローバルで適用される
volta install node

