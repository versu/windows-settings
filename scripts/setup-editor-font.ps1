$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# font-install.ps1を読み込む
$fontInstallScriptPath = "$($PSScriptRoot)/utils/font-install/font-install.ps1"
. $fontInstallScriptPath

$logPath = "$($env:LOG_DIR)\setup-editor-font.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

# SoremonoフォントのURL
$FONT_URL = "https://github.com/qrac/soroemono/releases/download/1.0.0/SOROEMONO_v1.0.0.zip"

try {
    InstallFontsFromUrl -fontUrl $FONT_URL -logPath $logPath -scriptRoot $PSScriptRoot
}
catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message $errorMessage
    exit 1
}
finally {
    $Error.Clear()
}
