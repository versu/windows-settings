# find-winget-package-path.ps1

wingetでインストールしたパッケージのパスを検索するPowerShellスクリプトです。

## 概要

wingetには、インストールしたパッケージのインストールパスを調べるコマンドが存在しません。
このスクリプトは、以下の処理を行ってパッケージのパスを特定します：

1. `winget --info` コマンドでユーザーのパッケージルートを取得
2. パッケージルートから、指定したパッケージ名に似たパッケージフォルダを検索（部分一致）
3. 見つかったパッケージのパス、更新日時を表示

## 使用方法

### 基本的な使用方法

```powershell
.\find-winget-package-path.ps1 -PackageName "検索したいパッケージ名"
```

### 詳細ログ付きで実行

```powershell
.\find-winget-package-path.ps1 -PackageName "検索したいパッケージ名" -DetailedLog
```

## パラメータ

| パラメータ | 必須 | 説明 |
|------------|------|------|
| PackageName | ✓ | 検索するパッケージ名（部分一致） |
| DetailedLog | | 詳細なログをファイルに出力する |

## 実行例

### RDCManパッケージを検索

```powershell
.\find-winget-package-path.ps1 -PackageName "rdcman"
```

#### 出力例
```
見つかったパッケージ:
======================
パッケージ名: Microsoft.Sysinternals.RDCMan_Microsoft.Winget.Source_8wekyb3d8bbwe
パス: C:\Users\username\AppData\Local\Microsoft\WinGet\Packages\Microsoft.Sysinternals.RDCMan_Microsoft.Winget.Source_8wekyb3d8bbwe
最終更新: 03/08/2024 16:59:28
----------------------
```

### Taskパッケージを検索

```powershell
.\find-winget-package-path.ps1 -PackageName "task"
```

#### 出力例
```
見つかったパッケージ:
======================
パッケージ名: Task.Task_Microsoft.Winget.Source_8wekyb3d8bbwe
パス: C:\Users\username\AppData\Local\Microsoft\WinGet\Packages\Task.Task_Microsoft.Winget.Source_8wekyb3d8bbwe
最終更新: 15/07/2024 10:30:45
----------------------
```

## 検索対象

このスクリプトは、以下のディレクトリからパッケージを検索します：

- `%LOCALAPPDATA%\Microsoft\WinGet\Packages` (ユーザー用ポータブルパッケージ)
- `C:\Program Files\WinGet\Packages` (マシン用ポータブルパッケージ)
- `C:\Program Files (x86)\WinGet\Packages` (x86用ポータブルパッケージ)

## ログファイル

スクリプトの実行ログは以下の場所に保存されます：
`scripts/_logs/find-winget-package-path.log`

## 注意事項

- このスクリプトは**ポータブルパッケージ**のみを対象とします
- 従来のインストーラー形式でインストールされたパッケージは検索対象外です
- パッケージ名は部分一致で検索されるため、類似した名前のパッケージも結果に含まれる場合があります
- 大文字小文字は区別しません

## 依存関係

- PowerShell 5.1以上
- `scripts/common.ps1`
- `scripts/utils/logger.ps1`
- wingetコマンドが利用可能であること