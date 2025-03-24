### Set ExecutionPolicy ### 
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


### Install Winget Packages ###
winget install -e --id Microsoft.WindowsTerminal

# git
# 最新バージョンだとcredential managerも含まれる。
winget install Git.Git

# git client
winget install Fork.Fork

# db client
winget install dbeaver.dbeaver

# draw.io
winget install -e --id JGraph.Draw

# vscode
# オプションなしだと、フォルダ/ファイルの右クリック「Codeで開く」が出ないので、参考サイトを参考にオプションを指定する。
# 参考サイト：https://proudust.github.io/20200726-winget-install-vscode/
# https://zenn.dev/nuits_jp/articles/winget-install-option
winget install vscode --override "/silent /mergetasks=""addcontextmenufiles,addcontextmenufolders"""

# RDCMan (Remote Desktop Connection Manager)
# インストール後、rdcman というコマンドが使えるようになる（要ターミナル再起動）
# rdcmanコマンドでRDCManを起動できる。
winget install -e --id=Microsoft.Sysinternals.RDCMan

winget install Postman.Postman
winget install -e --id 7zip.7zip
winget install --id=Learnpulse.Screenpresso  -e
winget install WinMerge
winget install -e --id Microsoft.PowerToys --source winget
winget install -e --id Google.JapaneseIME
winget install -e --id=Obsidian.Obsidian
winget install --id=OliverSchwendener.ueli  -e

# 必要に応じて入れるもの
# winget install Sourcetree

# NoSQLを使う場合dbeaverは要課金。TablePlus推薦
# winget install TablePlus.TablePlus

# winget install Microsoft.SQLServerManagementStudio
# winget install Docker.DockerDesktop
# winget install -e --id Discord.Discord

# Azure 
# winget install Microsoft.AzureStorageExplorer

# winget install -e --id=Microsoft.VisualStudio.2022.Community

# Node.js
# winget install -e --id=Volta.Volta 

# Charles Proxy（ローカルプロキシツール）
# winget install -e --id XK72.Charles

# Temurin (Java JDK)
# winget install --id=EclipseAdoptium.Temurin.21.JDK  -e
