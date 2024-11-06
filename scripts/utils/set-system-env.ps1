# 現在のPATHを取得
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

# 追加するパス
$newPath = "C:\Program Files\Hoge"

# 既存のPATHに新しいパスを追加
$newPath = $currentPath + ";" + $newPath

Write-Host $newPath

# 更新したPATHを設定
# [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
