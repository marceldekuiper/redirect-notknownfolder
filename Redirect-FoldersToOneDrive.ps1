# Check if OneDrive Business is finsihed provisioning and if so, proceed to redirect the Videos en Music folders to the OneDrive folder.
<#
$regkey = 'HKCU:\Software\Microsoft\OneDrive'
$name = 'SilentBusinessConfigCompleted'
$Notdone = $true

do {
    $exists = Get-ItemProperty -Path $regkey -Name $name -ErrorAction SilentlyContinue

    if (($null -ne $exists) -and ($exists.Lenght -ne 0) -and ($exists.SilentBusinessConfigCompleted -eq 1)) {
        # Start redirecting of folders
        
        Import-Module .\Set-KnownFolderPath.psm1
        Set-KnownFolderPath -KnownFolder 'Videos' -Path $env:onedrivecommercial/Videos
        Set-KnownFolderPath -KnownFolder 'Music' -Path $env:onedrivecommercial/Music
       
        # Exit loop
        $Notdone = $false
    }
    else {
        Start-Sleep -Seconds 5
    }
} while ($Notdone)
#>

# To Do: Replace Write-Host with logging to file
# To Do: If scheduled task always runs with AMSTERDAMUMC\%logonname% credentials remove the check, else create switch statement to support AMC and Vumc domains.

# Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Microsoft\OneDrive\' -Name SilentBusinessConfigCompleted

# Set the logfile location
$logFile = "$($env:ProgramData)\Amsterdam UMC\Logs\Redirect-FoldersToOneDrive.log"

# Start declaring functions
Function Start-Log {
[CmdletBinding()]
    param (
    #[ValidateScript({ Split-Path $_ -Parent | Test-Path })]
	[string]$FilePath
    )
	
    try
    {
        if (!(Test-Path $FilePath))
	{
	    ## Create the log file
	    New-Item $FilePath -Type File -Force | Out-Null
	}
		
	## Set the global variable to be used as the FilePath for all subsequent Write-Log
	## calls in this session
	$global:ScriptLogFilePath = $FilePath
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}

Function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
		
        [Parameter()]
        [ValidateSet(1, 2, 3)]
        [string]$LogLevel = 1
    )

    $TimeGenerated = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
    $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'
    $LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$($MyInvocation.ScriptName | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)", $LogLevel
    #$LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$($MyInvocation.ScriptName | Split-Path -Leaf)", $LogLevel
    $Line = $Line -f $LineFormat
    Add-Content -Value $Line -Path $ScriptLogFilePath

    if($writetoscreen -eq $true){
        switch ($LogLevel)
        {
            '1'{
                Write-Host $Message -ForegroundColor Gray
                }
            '2'{
                Write-Host $Message -ForegroundColor Yellow
                }
            '3'{
                Write-Host $Message -ForegroundColor Red
                }
            Default {}
        }
    }
}
# End declaring functions

# Start logging
Start-Log -FilePath $logFile

Write-Log -Message "Started the script."

# Variables for registry actions
$registryPath = "HKCU:\Software\Microsoft\OneDrive"
$registryKeyName = "SilentBusinessConfigCompleted"
$registryKeyValue = "1"


<#
Write-Log -Message "Check the registry if this Scheduled Task has already completed, if yes then exit."
Write-Log -Message "Changing ErrorActionPreference from $($ErrorActionPreference) to Stop for the Try, Catch, Finally block."
$ErrorActionPreference = "Stop"
Try {
    if ($(Get-ItemPropertyValue -Path $registryPath -Name $registryKeyName) -eq $registryKeyValue) {
            Write-Log -Message "KeyName $($registryKeyName) with KeyValue $($registryKeyValue) exists, exit script." -LogLevel 2
            #exit
    }
}
Catch [System.Management.Automation.ItemNotFoundException] {
    Write-Log -Message "KeyName $($registryKeyName) does not exist, continue script."
}
Catch [System.Management.Automation.PSArgumentException] {
    Write-Log -Message "Value $($registryKeyValue) for $($registryKeyName) does not exist, continue script."
}
Finally {
    Write-Log -Message "Changing ErrorActionPreference from $($ErrorActionPreference) to Continue."
    $ErrorActionPreference = "Continue"
}

Write-Log -Message "Check if the logged-in user is not from a legacy domain, if yes then exit."
if ($(([System.Security.Principal.WindowsIdentity]::GetCurrent()).Name) -like 'AMC*') {
    Write-Log -Message "User is from legacy domain AMC, exit script." -LogLevel 2
    exit
    }
#>

Write-Log -Message "Check the registry if the OneDrive sync app completed the Business config."

$Notdone = $true
do {
    $exists = Get-ItemProperty -Path $registryPath -Name $registryKeyName -ErrorAction SilentlyContinue

    if (($null -ne $exists) -and ($exists.Lenght -ne 0) -and ($exists.SilentBusinessConfigCompleted -eq $registryKeyValue)) {
        # Start redirecting of folders
        Write-Log -Message "KeyName SilentBusinessConfigCompleted is set to 1, continue to redirecting folders." -LogLevel 2
        
        # Check if module is present, if not, download from repo
        if(!(Get-Module -Name "Set-KnownFolderPath")) {
            Start-BitsTransfer "https://raw.githubusercontent.com/marceldekuiper/set-knownfolderpath.psm1/main/Set-KnownFolderPath.psm1"
            Import-Module .\Set-KnownFolderPath.psm1
        }
        Set-KnownFolderPath -KnownFolder 'Videos' -Path $env:onedrivecommercial/Videos
        Set-KnownFolderPath -KnownFolder 'Music' -Path $env:onedrivecommercial/Music
       
        # Exit loop
        $Notdone = $false
    }
    else {
        Write-Log -Message "KeyName SilentBusinessConfigCompleted does not exist or OneDrive is not ready, sleeping for 5 seconds." -LogLevel 2
        Start-Sleep -Seconds 5
    }
} while ($Notdone)

Write-Log -Message "KeyName SilentBusinessConfigCompleted  exist, continue script."
