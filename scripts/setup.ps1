$ErrorActionPreference = "Stop"

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup.log"

function Invoke-ScriptSequentially {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$false)]
        [bool]$RequireAdmin = $false,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = ""
    )
    
    $scriptName = Split-Path $ScriptPath -Leaf
    $displayName = if ($Description) { "$Description ($scriptName)" } else { $scriptName }
    
    try {
        if (-not (Test-Path $ScriptPath)) {
            throw "スクリプトファイルが見つかりません: $ScriptPath"
        }

        WriteInfoLog -logPath $logPath -message "--------------------------------------------------------------"
        WriteInfoLog -logPath $logPath -message "開始: $displayName"
        WriteInfoLog -logPath $logPath -message "--------------------------------------------------------------"

        if ($RequireAdmin) {
            # 一時的な出力ファイル
            $tempOutput = [System.IO.Path]::GetTempFileName()
            
            try {
                $processArgs = @(
                    "-ExecutionPolicy", "Bypass"
                    "-NoProfile"
                    "-Command", "& `"$ScriptPath`" *> `"$tempOutput`""
                )
                
                $process = Start-Process powershell.exe -ArgumentList $processArgs -Verb RunAs -Wait -PassThru
                
                # 別プロセスで実行したスクリプトの出力を読み取り
                $processOutput = Get-Content $tempOutput -Raw -ErrorAction SilentlyContinue
                if ($process.ExitCode -eq 0) {
                    # 正常終了の場合
                    WriteInfoLog -logPath $logPath -message $processOutput
                }
                else {
                    # エラー終了の場合
                    WriteErrorLog -logPath $logPath -message $processOutput
                    throw "スクリプト実行が失敗しました (終了コード: $($process.ExitCode))"
                }
            }
            finally {
                # 一時ファイルのクリーンアップ
                if (Test-Path $tempOutput) { Remove-Item $tempOutput -Force -ErrorAction SilentlyContinue }
            }
        } else {
            # 通常権限で実行
            & $ScriptPath
            $exitCode = $LASTEXITCODE
            if ($exitCode -ne 0 -and $exitCode -ne $null) {
                throw "スクリプト実行が失敗しました (終了コード: $exitCode)"
            }
        }
        
        WriteInfoLog -logPath $logPath -message "--------------------------------------------------------------"
        WriteInfoLog -logPath $logPath -message "完了: $displayName"
        WriteInfoLog -logPath $logPath -message "--------------------------------------------------------------"
    }
    catch {
        $errorMessage = "エラー ($displayName): $($_.Exception.Message)"
        WriteErrorLog -logPath $logPath -message $errorMessage
        throw $errorMessage
    }
}

try {
    # 実行するスクリプトを順番に定義
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-winget.ps1" -RequireAdmin $false

    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-scope.ps1" -RequireAdmin $false
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-psprofile.ps1" -RequireAdmin $true
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-links.ps1" -RequireAdmin $true
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-font.ps1" -RequireAdmin $true

    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-volta.ps1" -RequireAdmin $false
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-claude-code.ps1" -RequireAdmin $true

    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-clibor.ps1" -RequireAdmin $false
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-obsidian.ps1" -RequireAdmin $false
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-ueli.ps1" -RequireAdmin $false
    Invoke-ScriptSequentially -ScriptPath "$($env:SCRIPT_FOLDER)\setup-windows.ps1" -RequireAdmin $false

}
catch {
    $errorMessage = "ファサード実行エラー: $($_.Exception.Message)"
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
finally {
    $Error.Clear()
}
