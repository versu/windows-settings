function InstallFonts($fontsPath){
  # Expand-Archive -Path "$($tempPath)\fonts.zip" -Destination $($fontsPath) -Force
  $systemFontsPath = "C:\Windows\Fonts"
  $getFonts = Get-ChildItem $fontsPath -Include '*.ttf','*.ttc','*.otf' -recurse

  foreach($fontFile in $getFonts) {
  	$targetPath = Join-Path $systemFontsPath $fontFile.Name
  	if(Test-Path -Path $targetPath){
  		$FontFile.Name + " already installed"
  	}
  	else {
  		"Installing font " + $fontFile.Name
  		#Extract Font information for Reqistry
  		$ShellFolder = (New-Object -COMObject Shell.Application).Namespace($fontsPath)
  		$ShellFile = $shellFolder.ParseName($fontFile.name)
  		$ShellFileType = $shellFolder.GetDetailsOf($shellFile, 2)
  		#Set the $FontType Variable
  		If ($ShellFileType -Like '*TrueType font file*') {$FontType = '(TrueType)'}
  		#Update Registry and copy font to font directory
  		$RegName = $shellFolder.GetDetailsOf($shellFile, 21) + ' ' + $FontType
  		New-ItemProperty -Name $RegName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.name -Force | out-null
  		Copy-item $fontFile.FullName -Destination $systemFontsPath
  		"Done"
  	}
  }
}

$ErrorActionPreference = "Stop"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-font.log"

if (!$isAdmin) { 
    WriteErrorLog -logPath $logPath -message "このスクリプトは管理者権限で実行する必要があります。"
    WriteErrorLog -logPath $logPath -message "現在の実行権限が不足しています。"
    exit 1
}

$FONT_URL = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip"
$FONT_URL_NAME = [System.IO.Path]::GetFileName($FONT_URL)
$FONT_URL_NAME_WITHOUTEXTENSION = [System.IO.Path]::GetFileNameWithoutExtension($FONT_URL)

$DOWNLOAD_DIR = "$PSScriptRoot\_download"
$DOWNLOAD_NERD_FONT_PATH = [System.IO.Path]::Combine($DOWNLOAD_DIR, $FONT_URL_NAME)

$UNZIPPED_FONT_DIR = "$PSScriptRoot\_unzipped"
$UNZIPPED_NERD_FONT_DIR = [System.IO.Path]::Combine($UNZIPPED_FONT_DIR, $FONT_URL_NAME_WITHOUTEXTENSION)

try 
{
  if  (!(Test-Path $DOWNLOAD_DIR)){
    New-Item -Path $DOWNLOAD_DIR -ItemType Directory
  }
  Invoke-WebRequest $FONT_URL -OutFile $DOWNLOAD_NERD_FONT_PATH
  7z x -o"$UNZIPPED_NERD_FONT_DIR" $DOWNLOAD_NERD_FONT_PATH
  
  InstallFonts($UNZIPPED_NERD_FONT_DIR)

  Remove-Item -Recurse -Force -Path $DOWNLOAD_DIR
  Remove-Item -Recurse -Force -Path $UNZIPPED_FONT_DIR
}
catch 
{
  $errorMessage = $_ | Out-String
  WriteErrorLog -logPath $logPath -message $errorMessage
}
finally
{
  $Error.Clear()
}
