$REPOSITORY_NAME = "andy-5/wslgit"
$DOWNLOAD_TARGET_FILE = "wslgit.zip"
$DOWNLOAD_DIR = "C:\Program Files"

sudo .\download-latest-github-release.ps1 -repo $REPOSITORY_NAME -file $DOWNLOAD_TARGET_FILE -downloaddir $DOWNLOAD_DIR

sudo '&'"${DOWNLOAD_DIR}\wslgit\install.bat"
