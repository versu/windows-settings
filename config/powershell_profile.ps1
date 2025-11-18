### starship ###

$env:STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml"
$ENV:Path+=";C:\Program Files\7-Zip"

# uv/uvx のパス。Serena の起動に必要
$ENV:Path+=";$HOME\.local\bin"
Invoke-Expression (&starship init powershell)

### ghq-fzf ###
$env:FZF_DEFAULT_OPTS = "--reverse"

function gf {
  $repo = $(ghq list | fzf)
  # Set-Location ( Join-Path $(ghq root) $repo)
  if ($LastExitCode -eq 0) {
    Set-Location ( Join-Path $(ghq root) $repo)
    # cd "$(ghq root)\$repo"
  }
}

# ghq list
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -ScriptBlock { gf; [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }

### ZLocation ###
Import-Module ZLocation

### PSFzf ###
Import-Module PSFzf

$env:_PSFZF_FZF_DEFAULT_OPTS = "--height 40% --reverse"

# command history
Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'

# cd history
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -ScriptBlock { Invoke-FuzzyZLocation; [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }

# movable cd list from current dir
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -ScriptBlock { Invoke-FuzzySetLocation; [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() }

# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

### uutils ###

@"
  arch, base32, base64, basename, cat, cksum, comm, cp, cut, date, df, dircolors, dirname,
  echo, env, expand, expr, factor, false, fmt, fold, hashsum, head, hostname, join, link, ln,
  ls, md5sum, mkdir, mktemp, more, mv, nl, nproc, od, paste, printenv, printf, ptx, pwd,
  readlink, realpath, relpath, rm, rmdir, seq, sha1sum, sha224sum, sha256sum, sha3-224sum,
  sha3-256sum, sha3-384sum, sha3-512sum, sha384sum, sha3sum, sha512sum, shake128sum,
  shake256sum, shred, shuf, sleep, sort, split, sum, sync, tac, tail, tee, test, touch, tr,
  true, truncate, tsort, unexpand, uniq, wc, whoami, yes
"@ -split ',' |
ForEach-Object { $_.trim() } |
Where-Object { ! @('tee', 'sort', 'sleep').Contains($_) } |
ForEach-Object {
    $cmd = $_
    if (Test-Path Alias:$cmd) { Remove-Item -Path Alias:$cmd }
    $fn = '$input | uutils ' + $cmd + ' $args'
    Invoke-Expression "function global:$cmd { $fn }" 
}
