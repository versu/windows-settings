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
