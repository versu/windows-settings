$ErrorActionPreference = "Stop"

# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

# logger.ps1を読み込む
$loggerScriptPath = "$($PSScriptRoot)/utils/logger.ps1"
. $loggerScriptPath

$logPath = "$($env:LOG_DIR)\setup-scope.log"

try 
{
  ### Install Scoop ###
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  irm get.scoop.sh | iex

  ### Install Pacages ###
  $pkgs=@(
      "ghq"
      "fzf"
      "starship"
      "sudo"
      "uutils-coreutils"
  )

  scoop install $pkgs

  Install-Module ZLocation -Scope CurrentUser -Force
  Install-Module PSFzf -Scope CurrentUser -Force
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
