<#
.SYNOPSIS
    Detect a known folder's path.
.PARAMETER Folder
    The known folder whose path to set.
.PARAMETER Path
    The path.
.EXAMPLE
    Set-KnownFolderPath -KnownFolder 'Desktop'
#>

function Detect-KnownFolderPath {
    Param (
            [Parameter(Mandatory = $true)]
            [ValidateSet('MyVideos', 'MyMusic')]
            [string]$KnownFolder
    )

    foreach ($item in $KnownFolder){
        #return $item
        [Environment]::GetFolderPath($item)
    }

    <#
    if ([Environment]::GetFolderPath("MyVideos") -like "$($env:onedrivecommercial)\Videos") {
        if(Test-Path "$($env:onedrivecommercial)\Videos" -PathType Container) {
            Write-Output "Videos folder is moved to OneDrive"
        } else {
            Write-Error "Videos folder in OneDrive is missing, Videos folder is not moved to OneDrive"
        }
    } else {
        Write-Error "Videos folder is not moved to OneDrive"
    }
    
    if ([Environment]::GetFolderPath("MyMusic") -like "$($env:onedrivecommercial)\Music") {
        if(Test-Path "$($env:onedrivecommercial)\Videos" -PathType Container) {
            Write-Output "Music folder is moved to OneDrive"
        } else {
            Write-Error "Music folder in OneDrive is missing, Music folder is not moved to OneDrive"
        }
    } else {
        Write-Error "Music folder is not moved to OneDrive"
    }
    #>

}