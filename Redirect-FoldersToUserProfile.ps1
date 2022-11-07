Import-Module .\Set-KnownFolderPath.psm1
Set-KnownFolderPath -KnownFolder 'Videos' -Path $env:USERPROFILE/Videos
Set-KnownFolderPath -KnownFolder 'Music' -Path $env:USERPROFILE/Music