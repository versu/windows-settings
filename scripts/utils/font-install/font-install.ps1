function InstallFontsFromUrl {
  param (
    [Parameter(Mandatory=$true)]
    [string]$fontUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$fontName = $null,
    
    [Parameter(Mandatory=$true)]
    [string]$logPath,
    
    [Parameter(Mandatory=$true)]
    [string]$scriptRoot
  )

  # logger.ps1を読み込む
  $loggerScriptPath = "$scriptRoot/utils/logger.ps1"
  . $loggerScriptPath

  try {
    # フォント名が指定されていない場合は、URLから推測
    if ([string]::IsNullOrEmpty($fontName)) {
      $fontName = [System.IO.Path]::GetFileName($fontUrl)
    }
    
    $fontNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($fontName)
    
    WriteInfoLog -logPath $logPath -message "フォントのダウンロードを開始します: $fontName"
    
    # ディレクトリ設定
    $downloadDir = "$scriptRoot\_download"
    $downloadFontPath = [System.IO.Path]::Combine($downloadDir, $fontName)
    
    $unzippedFontDir = "$scriptRoot\_unzipped"
    $unzippedFontPath = [System.IO.Path]::Combine($unzippedFontDir, $fontNameWithoutExtension)
    
    # ダウンロードディレクトリの作成
    if (!(Test-Path $downloadDir)) {
      New-Item -Path $downloadDir -ItemType Directory
      WriteInfoLog -logPath $logPath -message "ダウンロードディレクトリを作成しました: $downloadDir"
    }
    
    # フォントファイルのダウンロード
    WriteInfoLog -logPath $logPath -message "フォントをダウンロード中: $fontUrl"
    Invoke-WebRequest $fontUrl -OutFile $downloadFontPath
    WriteInfoLog -logPath $logPath -message "ダウンロード完了: $downloadFontPath"
    
    # zipファイルの解凍
    WriteInfoLog -logPath $logPath -message "フォントファイルを解凍中: $unzippedFontPath"
    Expand-Archive -Path $downloadFontPath -Destination $unzippedFontPath -Force
    WriteInfoLog -logPath $logPath -message "解凍完了"
    
    # フォントのインストール
    WriteInfoLog -logPath $logPath -message "フォントのインストールを開始します"
    
    # フォントファイルの検索
    WriteInfoLog -logPath $logPath -message "フォントファイルを検索中: $unzippedFontPath"
    $systemFontsPath = "C:\Windows\Fonts"
    $getFonts = Get-ChildItem $unzippedFontPath -Include '*.ttf','*.ttc','*.otf' -recurse
    
    if ($getFonts.Count -eq 0) {
      WriteInfoLog -logPath $logPath -message "インストール可能なフォントファイルが見つかりませんでした"
    } else {
      WriteInfoLog -logPath $logPath -message "見つかったフォントファイル数: $($getFonts.Count)"
      
      foreach($fontFile in $getFonts) {
        $targetPath = Join-Path $systemFontsPath $fontFile.Name
        if(Test-Path -Path $targetPath){
          WriteInfoLog -logPath $logPath -message "フォント '$($fontFile.Name)' は既にインストール済みです"
        }
        else {
          WriteInfoLog -logPath $logPath -message "フォント '$($fontFile.Name)' のインストールを開始します"
          WriteInfoLog -logPath $logPath -message "フォントファイルパス: $($fontFile.FullName)"
          WriteInfoLog -logPath $logPath -message "フォントディレクトリ: $($fontFile.Directory.FullName)"
          
          try {
            # Extract Font information for Registry - 各フォントファイルのディレクトリを参照
            $ShellFolder = (New-Object -COMObject Shell.Application).Namespace($fontFile.Directory.FullName)
            if ($null -eq $ShellFolder) {
              WriteInfoLog -logPath $logPath -message "警告: COMオブジェクトの作成に失敗しました。フォント '$($fontFile.Name)' をスキップします"
              continue
            }
            
            $ShellFile = $shellFolder.ParseName($fontFile.name)
            if ($null -eq $ShellFile) {
              WriteInfoLog -logPath $logPath -message "警告: フォントファイル情報の取得に失敗しました。フォント '$($fontFile.Name)' をスキップします"
              continue
            }
            
            $ShellFileType = $shellFolder.GetDetailsOf($shellFile, 2)
            WriteInfoLog -logPath $logPath -message "フォントタイプ: $ShellFileType"
            
            # Set the $FontType Variable
            $FontType = ''
            If ($ShellFileType -Like '*TrueType font file*') {$FontType = '(TrueType)'}
            ElseIf ($ShellFileType -Like '*OpenType font file*') {$FontType = '(OpenType)'}
            
            # Update Registry and copy font to font directory
            $FontDisplayName = $shellFolder.GetDetailsOf($shellFile, 21)
            if ([string]::IsNullOrEmpty($FontDisplayName)) {
              WriteInfoLog -logPath $logPath -message "警告: フォント表示名の取得に失敗しました。ファイル名を使用します"
              $FontDisplayName = [System.IO.Path]::GetFileNameWithoutExtension($fontFile.Name)
            }
            
            $RegName = $FontDisplayName + ' ' + $FontType
            WriteInfoLog -logPath $logPath -message "レジストリ名: $RegName"
            
            New-ItemProperty -Name $RegName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.name -Force | out-null
            Copy-item $fontFile.FullName -Destination $systemFontsPath
            
            WriteInfoLog -logPath $logPath -message "フォント '$($fontFile.Name)' のインストールが完了しました"
          }
          catch {
            $errorMessage = $_ | Out-String
            WriteInfoLog -logPath $logPath -message "エラー: フォント '$($fontFile.Name)' のインストール中にエラーが発生しました: $errorMessage"
            WriteInfoLog -logPath $logPath -message "このフォントをスキップして続行します"
          }
        }
      }
    }
    
    WriteInfoLog -logPath $logPath -message "フォントのインストール処理が完了しました"
    
    # クリーンアップ
    WriteInfoLog -logPath $logPath -message "一時ファイルのクリーンアップを開始します"
    Remove-Item -Recurse -Force -Path $downloadDir
    Remove-Item -Recurse -Force -Path $unzippedFontDir
    WriteInfoLog -logPath $logPath -message "クリーンアップ完了"
    
  }
  catch {
    $errorMessage = $_ | Out-String
    WriteErrorLog -logPath $logPath -message "フォントインストール中にエラーが発生しました: $errorMessage"
    throw
  }
}
