param(
    [Parameter(Mandatory=$true, HelpMessage="追加するパスを指定してください")]
    [string]$PathToAdd
)

# 引数で渡されたパスが存在するかチェック
if (-not (Test-Path $PathToAdd)) {
    Write-Warning "指定されたパス '$PathToAdd' が存在しません。"
    exit 1
}

# 現在のPATHを取得
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")

# パスが既に存在するかチェック
$pathArray = $currentPath -split ";"
if ($pathArray -contains $PathToAdd) {
    Write-Host "パス '$PathToAdd' は既にPATHに登録されています。" -ForegroundColor Yellow
    exit 0
}

# 既存のPATHに新しいパスを追加
$newPath = $currentPath + ";" + $PathToAdd

Write-Host "新しいPATH: $newPath" -ForegroundColor Green

# 更新したPATHを設定
[System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
Write-Host "パス '$PathToAdd' をユーザー環境変数PATHに追加しました。" -ForegroundColor Green
