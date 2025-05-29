#
# Robocopy from a directory to another with specific options
#
# Sample yaml for this script:
#
# - DirectoryEntries:
#   - SrcDir: D:\Records
#     SrcExcludedDirs:
#     - D:\Records\Temp
#     - D:\Records\Old
#     DstDir: I:\Records
#   - SrcDir: D:\Users
#     SrcExcludedDirs:
#     - D:\Users\Foo Bar
#     DstDir: I:\Users
#   - SrcDir: D:\AmazonPhotosDownload
#     SrcExcludedDirs: []
#     DstDir: I:\AmazonPhotosDownload
#
#
param (
    [Parameter(Mandatory=$true)][string]$ConfigFile
)
Import-Module powershell-yaml

$CONSTS = @{
    DirectoryEntries = "DirectoryEntries"
    SrcDir = "SrcDir"
    SrcExcludedDirs = "SrcExcludedDirs"
    DstDir = "DstDir"
}


class RobocopyEntryInfo
{
    # Optionally, add attributes to prevent invalid values
    [ValidateNotNullOrEmpty()][string]$SrcDir
    [string[]]$SrcExcludedDirs
    [ValidateNotNullOrEmpty()][string]$DstDir

    # optionally, have a constructor to 
    # force properties to be set:
    RobocopyEntryInfo([string]$SrcDir, [string[]]$SrcExcludedDirs, [string]$DstDir) {
       $this.SrcDir = $SrcDir
       $this.SrcExcludedDirs = $SrcExcludedDirs
       $this.DstDir = $DstDir
    }
}

function Log-Output {
    param( [string]$Msg )
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S") + " " + $Msg )
}
			    
$ROBOCOPY_PARAMS="/MIR", "/FFT", "/R:3", "/W:10", "/Z", "/NP", "/NDL", "/MT:8"
$LogFile="C:\Users\petra\logs\robocopyToBackupDrive.log"
$OldLogFile="C:\Users\petra\logs\robocopyToBackupDrive-old.log"

# Exists call needs full path
if ( -not ($ConfigFile.StartsWith( "\" ) -or
	   $ConfigFile.StartsWith( "/" ) -or
	   $ConfigFile[1] -eq ':' )) {
    $ConfigFile = "$PWD" + "\" + "$ConfigFile"
}

if ( -not [System.IO.File]::Exists($ConfigFile) ) {
    Write-Output( "Could not find config file '", $ConfigFile, "' Exiting..." )
    Exit(1)
}

if ([System.IO.File]::Exists($LogFile)) 
{
    Move-Item -Path $LogFile -Destination $OldLogFile -Force
}

&{
    Log-Output( "Reading from configuration file", $ConfigFile )
    $CfgData = ( Get-Content -Path $ConfigFile | ConvertFrom-Yaml )
    Log-Output( "Reading from onfiguration file", $ConfigFile, "done." )
    Log-Output( "robocopy of data to backup drive started" )
    foreach ($Entry in $CfgData.DirectoryEntries ) {
        Log-Output( "robocopy of $($Entry.SrcDir) to $($Entry.DstDir) started" )

	if ( $Entry.SrcExcludedDirs.Length -gt 0  ) {
	    robocopy $Entry.SrcDir $Entry.DstDir /XD @($Entry.SrcExcludedDirs) @ROBOCOPY_PARAMS	    
	}
	else {
	    robocopy $Entry.SrcDir $Entry.DstDir @ROBOCOPY_PARAMS
	}
        Log-Output( "robocopy of $($Entry.SrcDir) to $($Entry.DstDir) done" )
    }

    Log-Output("robocopy of data to backup drive ended")
} *> $LogFile

