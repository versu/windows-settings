# common.ps1を読み込む
$commonScriptPath = "$($PSScriptRoot)/common.ps1"
. $commonScriptPath

$logPath = "$($env:LOG_DIR)\setup-scope.log"

$ErrorActionPreference = "Stop"

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
  WriteErrorLog -logPath $logPath -errorMessage $errorMessage
}
finally
{
  $Error.Clear()
}
