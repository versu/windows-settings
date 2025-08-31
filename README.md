# windows-settings

##  install 

iex ((iwr 'https://raw.githubusercontent.com/versu/windows-settings/main/install.ps1' -Headers @{"Cache-Control"="no-cache"}).Content -replace '^\uFEFF')

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
