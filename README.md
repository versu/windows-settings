# windows-settings

## install Nard Font

※以下の手順を実行する前に、wingetで各種パッケージをインストールしておくこと。（7zipのインストールが必要なため。）
※run by Administrator

```
setup.ps1
```

## install

1. install scope and scope packages

```
setup-scope.ps1
```

2. ghq setting

```
setup-ghq.ps1
```

3. set psprofile

```
// get psprofile set folder path
echo $PROFILE.CurrentUserCurrentHost

// put psprofile into above folder path
config/powershell_profile.ps1
```

4. set starship setting file

config/starship.tomlを、~/.config/starship.tomlに配置する。
※~はHOMEディレクトリ。以下のように確認できる。
```
echo $HOME
```

## Windows Terminal

```windowsterminal
// open settings.json
code %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### set default font

```json
"profiles": 
    {
        // SETTINGS TO APPLY TO ALL PROFILES
        "defaults": {
          "font": {
            "face":"Hack Nerd Font Mono"
          }
        },
        ...
    }
```