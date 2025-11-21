Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


### Install Winget Packages ###
winget install -e --id Microsoft.WindowsTerminal

# git
# 最新バージョンだとcredential managerも含まれる。
winget install Git.Git

# git client
winget install Fork.Fork

# db client
winget install -e --id DBeaver.DBeaver.Community

# draw.io
winget install -e --id JGraph.Draw

# ------------------------------------------------------------------------------------
# vscode
# オプションなしだと、フォルダ/ファイルの右クリック「Codeで開く」が出ないので、参考サイトを参考にオプションを指定する。
# 参考サイト：https://proudust.github.io/20200726-winget-install-vscode/
# https://zenn.dev/nuits_jp/articles/winget-install-option
# ------------------------------------------------------------------------------------
winget install vscode --override "/silent /mergetasks=""addcontextmenufiles,addcontextmenufolders"""

winget install Postman.Postman
winget install -e --id 7zip.7zip
winget install --id=Learnpulse.Screenpresso  -e


winget install -e --id Google.JapaneseIME

# PowerShell Core(PowerShell 7)
winget install --id Microsoft.PowerShell

# 必要に応じて入れるもの
# winget install Sourcetree

# NoSQLを使う場合dbeaverは要課金。TablePlus推薦
# winget install TablePlus.TablePlus

# winget install Microsoft.SQLServerManagementStudio
# winget install Docker.DockerDesktop
# winget install -e --id Discord.Discord

# winget install WinMerge

# Azure
# winget install Microsoft.AzureStorageExplorer

# winget install -e --id=Microsoft.VisualStudio.2022.Community

# Node.js
# winget install -e --id=Volta.Volta 

# Slack
# winget install --id=SlackTechnologies.Slack  -e

# ------------------------------------------------------------------------------------
# Charles Proxy（ローカルプロキシツール）
# ------------------------------------------------------------------------------------
# winget install -e --id XK72.Charles


# ------------------------------------------------------------------------------------
# Temurin (Java JDK) 
# plantuml などJavaが必要なツールを使う場合は、インストールする。
# ------------------------------------------------------------------------------------
# winget install --id=EclipseAdoptium.Temurin.21.JDK  -e
# winget install -e --id Graphviz.Graphviz

winget install --id=Adobe.Acrobat.Reader.64-bit  -e --override "/msi EULA_ACCEPT=YES ENABLE_OPTIMIZATION=1 DISABLEDESKTOPSHORTCUT=1"


