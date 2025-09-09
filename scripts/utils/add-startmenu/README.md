# add-startmenu.ps1

スタートメニューにアプリケーションのショートカットを作成するための汎用PowerShellスクリプトです。

## 概要

このスクリプトは、任意のアプリケーションのEXEファイルを指定して、Windowsのスタートメニューにショートカットを自動作成します。作成されたショートカットにより、ランチャーアプリ（Ueli等）からアプリケーションを検索・起動できるようになります。

主な機能：
- 指定されたEXEファイルのスタートメニューショートカット作成
- ターゲットファイルの存在確認
- 作業ディレクトリの自動設定
- 拡張子.lnkの自動付与
- 詳細なログ出力とエラーハンドリング

## 使用方法

### 基本的な使用方法

```powershell
.\add-startmenu.ps1 -TargetPath "C:\Path\To\Application.exe" -ShortcutName "アプリ名"
```

### 詳細ログ付きで実行

```powershell
.\add-startmenu.ps1 -TargetPath "C:\Path\To\Application.exe" -ShortcutName "アプリ名" -DetailedLog
```

## パラメータ

| パラメータ | 必須 | 型 | 説明 |
|------------|------|-----|------|
| TargetPath | ✓ | string | ショートカットのターゲットとなるEXEファイルのフルパス |
| ShortcutName | ✓ | string | スタートメニューに表示するショートカット名 |
| DetailedLog | | switch | 詳細なログをファイルに出力する |

## 実行例

### RDCManのショートカット作成

```powershell
$rdcmanPath = "C:\Users\username\AppData\Local\Microsoft\WinGet\Packages\Microsoft.Sysinternals.RDCMan_Microsoft.Winget.Source_8wekyb3d8bbwe\RDCMan.exe"
.\add-startmenu.ps1 -TargetPath $rdcmanPath -ShortcutName "rdcman"
```

#### 出力例
```
スタートメニューにショートカットを作成中...
ショートカットが作成されました: C:\Users\username\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\rdcman.lnk
```

### Tablacus Explorerのショートカット作成

```powershell
.\add-startmenu.ps1 -TargetPath "C:\Users\username\app\tablacus-explorer\TE64.exe" -ShortcutName "Filer"
```

### 他のセットアップスクリプトからの呼び出し

```powershell
# setup-xxxx.ps1内での使用例
$addStartMenuScript = "$PSScriptRoot/utils/add-startmenu/add-startmenu.ps1"
& $addStartMenuScript -TargetPath $appExePath -ShortcutName "AppName"
```

## 機能詳細

### 1. ターゲットファイルの検証
- 指定されたEXEファイルの存在確認
- 存在しない場合はエラーメッセージを表示して終了

### 2. ショートカット作成処理
- スタートメニューディレクトリ: `%APPDATA%\Microsoft\Windows\Start Menu\Programs`
- 拡張子.lnkの自動付与（指定されていない場合）
- 作業ディレクトリの自動設定（EXEファイルの親ディレクトリ）

### 3. WScript.Shell COMオブジェクトの使用
- Windowsの標準機能を使用してショートカットを作成
- TargetPath、WorkingDirectoryを適切に設定

## ログファイル

スクリプトの実行ログは以下の場所に保存されます：
`scripts/_logs/add-startmenu.log`

ログには以下の情報が記録されます：
- 処理開始・完了時刻
- 指定されたパラメータ
- ショートカット作成先パス
- エラー情報（発生した場合）

## 使用場面

### セットアップスクリプトからの利用
このスクリプトは主に各種アプリケーションのセットアップスクリプト（setup-*.ps1）から呼び出されることを想定しています：

- `setup-rdcman.ps1` - RDCManのセットアップ時
- `setup-tablacus-explorer.ps1` - Tablacus Explorerのセットアップ時
- 他のアプリケーションセットアップスクリプト

### 手動実行
必要に応じて手動でアプリケーションのショートカットを作成する場合にも使用可能です。

## 注意事項

### ファイルパスについて
- TargetPathには実在するEXEファイルのフルパスを指定してください
- 相対パスは使用できません
- スペースを含むパスは引用符で囲んで指定してください

### ショートカット名について
- スタートメニューでの表示名となります
- 拡張子.lnkは自動で付与されるため、指定する必要はありません
- 既存のショートカットがある場合は上書きされます

### ランチャーアプリとの連携
- 作成されたショートカットは、Ueli等のランチャーアプリから検索可能になります
- ショートカット名で検索することでアプリケーションを起動できます

## エラーハンドリング

### よくあるエラーとその対処法

1. **ターゲットファイルが見つかりません**
   - EXEファイルのパスが正しいか確認してください
   - ファイルが実際に存在するか確認してください

2. **ショートカット作成エラー**
   - スタートメニューディレクトリへの書き込み権限があるか確認してください
   - ディスク容量不足でないか確認してください

## 依存関係

- PowerShell 5.1以上
- `scripts/common.ps1` - 共通設定ファイル
- `scripts/utils/logger.ps1` - ログ出力機能
- WScript.Shell COMオブジェクト（Windows標準）

## 互換性

- Windows 10/11対応
- PowerShell 5.1以上で動作確認済み
- 管理者権限は不要（現在のユーザーのスタートメニューに作成）