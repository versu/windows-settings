#Requires -RunAsAdministrator

param(
    [string]$ShareName = "testshare",
    [string]$FolderPath = "C:\TestShare",
    [string]$Username = "testuser",
    [string]$Password = "TestPassword123!"
)

Write-Host "テスト用共有フォルダを作成しています..." -ForegroundColor Green

try {
    # ユーザーの作成
    Write-Host "ユーザー '$Username' を作成中..." -ForegroundColor Yellow
    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    
    # ユーザーが既に存在するかチェック
    if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
        Write-Host "ユーザー '$Username' は既に存在します。" -ForegroundColor Yellow
    } else {
        New-LocalUser -Name $Username -Password $securePassword -Description "Test user for shared folder" -PasswordNeverExpires
        Write-Host "ユーザー '$Username' を作成しました。" -ForegroundColor Green
    }

    # フォルダの作成
    Write-Host "フォルダ '$FolderPath' を作成中..." -ForegroundColor Yellow
    if (!(Test-Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath -Force
        "This is a test file for shared folder" | Out-File -FilePath "$FolderPath\test.txt"
    }

    # 共有の作成
    Write-Host "共有 '$ShareName' を作成中..." -ForegroundColor Yellow
    
    # 既存の共有を削除（存在する場合）
    if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
        Remove-SmbShare -Name $ShareName -Force
    }
    
    # 新しい共有を作成
    New-SmbShare -Name $ShareName -Path $FolderPath -Description "Test shared folder with password protection"
    
    # アクセス権限の設定
    Write-Host "アクセス権限を設定中..." -ForegroundColor Yellow
    
    # Everyoneのアクセスを削除
    Revoke-SmbShareAccess -Name $ShareName -AccountName "Everyone" -Force -ErrorAction SilentlyContinue
    
    # テストユーザーにフルアクセスを付与
    Grant-SmbShareAccess -Name $ShareName -AccountName $Username -AccessRight Full -Force
    
    # NTFSアクセス権限も設定
    $acl = Get-Acl $FolderPath
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl -Path $FolderPath -AclObject $acl

    Write-Host ""
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host "テスト用共有フォルダの作成が完了しました！" -ForegroundColor Green
    Write-Host ""
    Write-Host "共有名: $ShareName" -ForegroundColor Cyan
    Write-Host "パス: \\localhost\$ShareName または \\$env:COMPUTERNAME\$ShareName" -ForegroundColor Cyan
    Write-Host "ユーザー名: $Username" -ForegroundColor Cyan
    Write-Host "パスワード: $Password" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host "エラーが発生しました: $($_.Exception.Message)" -ForegroundColor Red
}
