
# ✅事前に開発者モードを有効にしておくこと

# インストール
winget install --id=Volta.Volta  -e

# インストール確認(powershellを開きなおす必要あり)
volta -v

# Node.jsの安定版をインストール
# ついでにnpmもインストールされる
# インストールしたバージョンがデフォルトして設定され、グローバルで適用される
volta install node

# Node.jsをバージョンを指定してインストール
# ついでにnpmもインストールされる
# インストールしたバージョンがデフォルトして設定され、グローバルで適用される
volta install node@10.16.3
