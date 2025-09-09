# Font Install Utility

Windowsシステムにフォントをインストールするためのユーティリティ関数です。

## 機能

- URLからフォントファイルのダウンロード
- zipファイルの自動解凍
- システムフォントフォルダへのインストール
- レジストリへの登録
- 一時ファイルの自動クリーンアップ
- ログ出力機能

## 関数

### `InstallFontsFromUrl`

指定されたURLからフォントファイルをダウンロードしてインストールします。

#### パラメータ

- `fontUrl` (必須): フォントファイルのダウンロードURL
- `fontName` (オプション): フォントファイル名（未指定の場合はURLから自動推測）
- `logPath` (必須): ログファイルのパス
- `scriptRoot` (必須): スクリプトのルートディレクトリ

#### 使用例

```powershell
# font-install.ps1を読み込む
. "$PSScriptRoot/utils/font-install/font-install.ps1"

# フォントのインストール
InstallFontsFromUrl -fontUrl "https://example.com/font.zip" -logPath "C:\logs\font-install.log" -scriptRoot $PSScriptRoot

# フォント名を指定する場合
InstallFontsFromUrl -fontUrl "https://example.com/font.zip" -fontName "MyFont.zip" -logPath "C:\logs\font-install.log" -scriptRoot $PSScriptRoot
```

### `InstallFonts`

指定されたフォルダ内のフォントファイルをシステムにインストールします。

#### パラメータ

- `fontsPath` (必須): フォントファイルが格納されているフォルダのパス

#### 使用例

```powershell
# フォルダ内のフォントをインストール
InstallFonts("C:\temp\fonts")
```

## 前提条件

- 管理者権限で実行する必要があります
- logger.ps1とcommon.ps1が適切に配置されている必要があります
- PowerShell 5.0以上（Expand-Archiveコマンドレット使用のため）

## サポートされるフォント形式

- .ttf (TrueType Font)
- .ttc (TrueType Collection)
- .otf (OpenType Font)

## エラーハンドリング

関数実行中にエラーが発生した場合、詳細なエラーメッセージがログファイルに記録されます。一時ファイルのクリーンアップも自動的に実行されます。