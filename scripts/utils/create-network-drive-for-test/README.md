# create-network-drive-for-test.ps1

## 概要

テスト用のネットワーク共有フォルダを作成するPowerShellスクリプトです。ローカルユーザーの作成、共有フォルダの設定、アクセス権限の設定を自動化します。

## 必要な権限

- 管理者権限での実行が必要です
- `#Requires -RunAsAdministrator` により自動的にチェックされます

## 使用方法

### 基本実行（デフォルトパラメータ使用）

```powershell
.\create-network-drive-for-test.ps1
```

### パラメータ指定実行

```powershell
.\create-network-drive-for-test.ps1 -ShareName "myshare" -FolderPath "C:\MyTestShare" -Username "myuser" -Password "MyPassword456!"
```

## パラメータ詳細

| パラメータ | デフォルト値 | 説明 |
|-----------|-------------|------|
| ShareName | "testshare" | 作成する共有フォルダ名 |
| FolderPath | "C:\TestShare" | 共有フォルダのローカルパス |
| Username | "testuser" | アクセス用ローカルユーザー名 |
| Password | "TestPassword123!" | ローカルユーザーのパスワード |

## 実行結果

スクリプト実行完了後、以下の情報が表示されます：

- 共有名
- アクセスパス（`\\localhost\共有名` または `\\コンピューター名\共有名`）
- ユーザー名
- パスワード

## 実行内容

1. 指定されたローカルユーザーを作成（既存の場合はスキップ）
2. 指定されたパスに共有フォルダを作成
3. SMB共有を設定
4. アクセス権限を設定（Everyoneアクセスを削除し、指定ユーザーにフルアクセス付与）
5. NTFSファイルシステム権限を設定