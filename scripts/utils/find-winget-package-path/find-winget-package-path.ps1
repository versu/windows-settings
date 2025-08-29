param (
    [Parameter(Mandatory=$true, HelpMessage="検索するパッケージ名を指定してください")]
    [string]$PackageName,
    
    [Parameter(HelpMessage="詳細なログを出力するかどうか")]
    [switch]$DetailedLog
)

. "$PSScriptRoot\..\common.ps1"
. "$PSScriptRoot\logger.ps1"

$logPath = "$env:LOG_DIR\find-winget-package-path.log"

function Get-WingetPackageRoot {
    try {
        WriteInfoLog -logPath $logPath -message "wingetパッケージルートを取得中..."
        
        $wingetInfo = winget --info 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "winget --infoコマンドの実行に失敗しました: $wingetInfo"
        }
        
        $packageRoots = @()
        
        foreach ($line in $wingetInfo) {
            if ($line -match "ポータブル パッケージ ルート.*?%(.+)%" -or 
                $line -match "ポータブル パッケージ ルート.*?([A-Z]:.+)") {
                $packagePath = $matches[1].Trim()
                
                if ($packagePath -match "%(.+)%") {
                    $packagePath = [System.Environment]::ExpandEnvironmentVariables($packagePath)
                }
                
                if (Test-Path $packagePath) {
                    $packageRoots += $packagePath
                    WriteInfoLog -logPath $logPath -message "パッケージルートが見つかりました: $packagePath"
                }
            }
        }
        
        if ($packageRoots.Count -eq 0) {
            $defaultPath = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
            if (Test-Path $defaultPath) {
                $packageRoots += $defaultPath
                WriteInfoLog -logPath $logPath -message "デフォルトパッケージルートを使用: $defaultPath"
            } else {
                throw "wingetパッケージルートが見つかりません"
            }
        }
        
        return $packageRoots
    }
    catch {
        WriteErrorLog -logPath $logPath -message "パッケージルート取得エラー: $($_.Exception.Message)"
        throw
    }
}

function Find-PackageFolders {
    param (
        [string[]]$PackageRoots,
        [string]$SearchPattern
    )
    
    try {
        WriteInfoLog -logPath $logPath -message "パッケージフォルダを検索中: $SearchPattern"
        
        $allMatchingFolders = @()
        
        foreach ($packageRoot in $PackageRoots) {
            if (-not (Test-Path $packageRoot)) {
                WriteInfoLog -logPath $logPath -message "パッケージルートが存在しません: $packageRoot"
                continue
            }
            
            WriteInfoLog -logPath $logPath -message "検索中のパッケージルート: $packageRoot"
            
            $matchingFolders = Get-ChildItem -Path $packageRoot -Directory -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$SearchPattern*" }
            
            if ($matchingFolders) {
                $allMatchingFolders += $matchingFolders
                WriteInfoLog -logPath $logPath -message "$packageRoot で見つかったパッケージ数: $($matchingFolders.Count)"
            }
        }
        
        if ($allMatchingFolders.Count -eq 0) {
            WriteInfoLog -logPath $logPath -message "マッチするパッケージが見つかりませんでした"
            return @()
        }
        
        WriteInfoLog -logPath $logPath -message "合計で見つかったパッケージ数: $($allMatchingFolders.Count)"
        return $allMatchingFolders
    }
    catch {
        WriteErrorLog -logPath $logPath -message "パッケージ検索エラー: $($_.Exception.Message)"
        throw
    }
}

try {
    WriteInfoLog -logPath $logPath -message "=== wingetパッケージパス検索開始 ==="
    WriteInfoLog -logPath $logPath -message "検索パッケージ名: $PackageName"
    
    $packageRoots = Get-WingetPackageRoot
    $matchingPackages = Find-PackageFolders -PackageRoots $packageRoots -SearchPattern $PackageName
    
    if ($matchingPackages.Count -eq 0) {
        Write-Host "パッケージ '$PackageName' に一致するフォルダが見つかりませんでした。" -ForegroundColor Yellow
        WriteInfoLog -logPath $logPath -message "検索結果: マッチするパッケージなし"
    }
    else {
        Write-Host "`n見つかったパッケージ:" -ForegroundColor Green
        Write-Host "======================" -ForegroundColor Green
        
        foreach ($package in $matchingPackages) {
            Write-Host "パッケージ名: $($package.Name)" -ForegroundColor Cyan
            Write-Host "パス: $($package.FullName)" -ForegroundColor White
            Write-Host "最終更新: $($package.LastWriteTime)" -ForegroundColor Gray
            Write-Host "----------------------" -ForegroundColor Gray
            
            if ($DetailedLog) {
                WriteInfoLog -logPath $logPath -message "見つかったパッケージ: $($package.Name) at $($package.FullName)"
            }
        }
        
        WriteInfoLog -logPath $logPath -message "検索完了: $($matchingPackages.Count)個のパッケージが見つかりました"
    }
    
    WriteInfoLog -logPath $logPath -message "=== wingetパッケージパス検索完了 ==="
}
catch {
    Write-Host "エラーが発生しました: $($_.Exception.Message)" -ForegroundColor Red
    WriteErrorLog -logPath $logPath -message "スクリプト実行エラー: $($_.Exception.Message)"
    exit 1
}
