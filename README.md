# windows-settings

## 1. install winget packages

Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/versu/windows-settings/main/scripts/setup-winget.ps1').Content

## 2. install other

Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/versu/windows-settings/main/install.ps1').Content

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

## TODO

- windows用のdotfilesを作成
  - git
    - git config --global core.autocrlf false
- setup-font.ps1実行後にゴミフォルダを削除（_downloaded, _unzipped）
