# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$logPath = "$($env:LOG_DIR)\setup-qttabbar.log"

$ErrorActionPreference = "Stop"

try 
{
  # インストーラーのURLを指定
  $zipUrl = "http://qttabbar-ja.wdfiles.com/local--files/qttabbar/QTTabBar%202048%20Beta2.zip"

  # ダウンロード先のファイルパスを指定
  $downloadDir = "$PSScriptRoot\_download"
  $downloadPath = "$($downloadDir)\qttabbar.zip"
  if  (!(Test-Path $downloadDir)){
    New-Item -Path $downloadDir -ItemType Directory
  }

  # zipをダウンロード
  Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath

  # zipを解凍
  $extractPath = "$($downloadDir)\qttabbar"
  Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

  # exeファイルのパスを取得
  $exePath = Get-ChildItem -Path $extractPath -Recurse -Include "*.exe" | Select-Object -First 1 -ExpandProperty FullName

  # exeを実行
  Start-Process -FilePath $exePath -Wait

  # ダウンロードしたファイルを削除
  Remove-Item -Recurse -Force -Path $downloadDir
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -errorMessage $errorMessage
}
finally
{
  $Error.Clear()
}
