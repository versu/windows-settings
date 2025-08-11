# $env:SCRIPT_FOLDER = Get-Item $MyInvocation.MyCommand.Path | Split-Path
$env:SCRIPT_FOLDER = $PSScriptRoot
$env:CONFIG_FOLDER = "$($env:SCRIPT_FOLDER)/../config"
$env:LOG_DIR = "$($env:SCRIPT_FOLDER)/_logs"

