# Detect if environment folders MyVideos and MyMusic are redirected to OneDrive
if (([Environment]::GetFolderPath("MyVideos") -like "$($env:onedrivecommercial)\Videos") -and ([Environment]::GetFolderPath("MyMusic") -like "$($env:onedrivecommercial)\Music")){
    # Looks good, nothing to do here.
    Exit 0
} else {
    # Something is wrong, remediation needed.
    Exit 1
}