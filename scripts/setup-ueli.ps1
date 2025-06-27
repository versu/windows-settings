
# ------------------------------------------------------------------------------------
# ランチャー
# ------------------------------------------------------------------------------------
winget install --id=OliverSchwendener.ueli  -e

# ueli から設定ファイルをExportした時のデフォルト出力先
# ueli から設定ファイルを Import する時もこのパスが開くので、Importしやすいようにここにコピーする
$ueliPath = "$env:LOCALAPPDATA\Programs\ueli"

# ueliの設定ファイルのパス
$ueliConfigPath = Join-Path $PSScriptRoot '..\config\ueli\ueli9.settings.json'

# ueliの設定ファイルをコピー
Copy-Item $ueliConfigPath -Destination $ueliPath -Force
