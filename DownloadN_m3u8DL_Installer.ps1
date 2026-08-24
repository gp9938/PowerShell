<#
.SYNOPSIS
Install utility script DownloadN_m3u8DL with supporting utilities that are easier to not package
with the utility: N_m3u8DL & ffmpeg.

.DESCRIPTION
Install utility script DownloadN_m3u8DL with supporting utilities N_m3u8DL & ffmpeg into the
specified installation folder.

.PARAMETER InstallationDir
The directory for installation.  This directly can already exist but must be empty.  If it does
not exist, it will be created.

.EXAMPLE
.\DownloadN_m3u8DL_Installer C:\PortableApps\DownloadN_m3u8DL

.LINK
https://github.com/gp9938/PowerShell

.LINK
https://github.com/nilaoda/N_m3u8DL-RE

.LINK
https://github.com//BtbN/FFmpeg-Builds

.NOTES
Created: 2026-08-24

License: GPL3

#>

#
# Original design notes
#
# usage: install_download_m3u8 installation_folder_path
# Result: n_ util and ffmpeg.exe in folder
#
# Pseuo-code
#  check installation folder existence
#      - if exists,make sure it is empty, if not, exit
#      - if not exist, try to create it, if it cannot be created, exit
#  create a temp folder name <temp-dir>
#  create folder C:\Windows\Temp\<temp-dir>
#  download & expand latest release n_m3u8DL-RE zip to temp folder
#  download & expand latest release ffmpeg zip to temp folder
#  copy N_m3u8DL-RE.exe from temp folder to installation folder
#  copy ffmpeg.exe from temp folder to installation folder.
#  remove installation folder
#
#
#

[CmdletBinding(DefaultParameterSetName = 'NoParameters')]
param ([Parameter(ParameterSetName='Standard',Mandatory=$true)][string]$InstallationDir)

$GithubApiReleaseUrl_N_m3u8DL = "https://api.github.com/repos/nilaoda/N_m3u8DL-RE/releases/latest"
$GithubApiReleaseUrl_ffmpeg = "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest"
$GithubApiReleaseUrl_PowerShell = "https://api.github.com/repos/gp9938/PowerShell/releases/latest"

if (!$InstallationDir) {
    write-output( "No arguments provided, usage below:`r`n" )
    Get-Help $MyInvocation.MyCommand.Path
    Exit(1)
}

function DownloadAndExpand-GithubRelease {
    param (
	[string]$GithubApiReleasesUrl,
	[string]$UrlFilter,
	[string]$DownloadDir
    )
    $SavedDir=(Get-Location).Path
    try {    
	# determine source url
	"DownloadAndExpand:" + $GithubApiReleasesUrl + "$UrlFilter" + "$DownloadDir" | Out-Host
	
	$UrlSearchResult = ((curl --silent -m 10 --connect-timeout 5 $GithubApiReleasesUrl |
	  ConvertFrom-Json).assets.browser_download_url)

	#    "######################## " + ($UrlSearchResult).GetType() + "`n" | Out-Host
	#    "######################## count is " + (($UrlSearchResult).count) + "`n" | Out-Host
	
	if (($UrlSearchResult).count -gt 1) {
	    $SourceUrl = $UrlSearchResult -match $UrlFilter
	}
	else {
	    $SourceUrl = $UrlSearchResult
	}
	if ($SourceUrl -is [array]) {
	    $SourceUrl = $SourceUrl[0]
	}
	
	#   "######################## cd $DownloadDir`n" | Out-Host
	#   "######################## " + ($DownloadDir).GetType() + "`n" | Out-Host
	#   "######################## " + ($SourceUrl) + " --- " + ($SourceUrl).GetType() + "`n" | Out-Host
	
	cd $DownloadDir
	curl --silent -L -O $SourceUrl
	$DownloadedFile = (([uri]($SourceUrl)).Segments[-1])
	Expand-Archive -Path $DownloadedFile
	$ExpandedDir = Join-Path -Path $DownloadDir -ChildPath (Split-Path $DownloadedFile -LeafBase)	
	return $ExpandedDir
    }
    finally {
	"Done.`n" | Out-Host
	Set-Location $SavedDir
    }
}

function CopyItem-FromArchive {
    param(
	[Parameter(Mandatory=$true)][string]$ArchiveFolder,
	[Parameter(Mandatory=$true)][string]$SourceFile,
	[Parameter(Mandatory=$true)][string]$Destination
    )
    "Copy-Item $SourceFile" | Out-Host
    
    $ArchiveFolderDirName=(Split-Path $ArchiveFolder -Leaf)
    if (Test-Path -Path "$ArchiveFolder\$SourceFile" -PathType Leaf) {
	Copy-Item "$ArchiveFolder\$SourceFile" -Destination $Destination
    }
    elseif (Test-Path -Path "$ArchiveFolder\$ArchiveFolderDirName\$SourceFile" -PathType Leaf)  {
#	"######################## " + "Source is $ArchiveFolder\$ArchiveFolderDirName\$SourceFile" | Out-Host
#	"######################## " + "Destination is $Destination " | Out-Host
	Copy-Item "$ArchiveFolder\$ArchiveFolderDirName\$SourceFile" -Destination $Destination	
    }
    else {
	write-error( "Failed to copy $SourceFile from archive $ArchiveFolder to destination " +
		     "$Destination.  Exiting..." )
	Exit(1)
    }
    
    "Done.`n" | Out-Host
}

function Perform-Installation {
    param([Parameter(Mandatory=$true)][string]$InstallationDir)
    "Begin installation..." | Out-Host
    
    # get temp folder name
    $TempFolderPath = $env:TEMP + "\" + (Generate-TempBasename($MyInvocation.MyCommand.Name))
    if (-Not (New-Item -Path $TempFolderPath -ItemType Directory)) {
	write-error( "Could not create temporary directory $TempFolderName. Exiting..." )
	Exit(1)
    }

    $ExpandedDir =(DownloadAndExpand-GithubRelease $GithubApiReleaseUrl_N_m3u8DL "win-x64" $TempFolderPath)
    CopyItem-FromArchive "$ExpandedDir" "N_m3u8DL-RE.exe" $InstallationDir
    
    $ExpandedDir = DownloadAndExpand-GithubRelease $GithubApiReleaseUrl_ffmpeg "win64-gpl.zip" $TempFolderPath
    CopyItem-FromArchive "$ExpandedDir" "bin\ffmpeg.exe"  $InstallationDir

    $ExpandedDir = DownloadAndExpand-GithubRelease $GithubApiReleaseUrl_PowerShell "PowerShell-scripts" $TempFolderPath
    CopyItem-FromArchive "$ExpandedDir" "DownloadN_m3u8DL.ps1"  $InstallationDir

    "Cleanup installation temp files..."
    # remove temp directory
    Remove-Item -Path $TempFolderPath -Recurse -Force
    "Done.`n" | Out-Host
    "Installation done."
}

function Generate-TempBasename {
    param([Parameter(Mandatory=$true)][string]$Prefix)
    return $Prefix +  ([DateTimeOffset](Get-Date)).ToUnixTimeSeconds()
}

####
#### BEGIN MAIN
####
Set-PSDebug -Trace 0
$SavedDir=(Get-Location).Path
#write-output( "SavedDir is " + $SavedDir )


# $ExpandedDir = DownloadAndExpand-GithubRelease $GithubApiReleaseUrl_ffmpeg "win64-gpl.zip" "C:\Windows\Temp\tt01"
# CopyItem-FromArchive "$ExpandedDir" "bin\ffmpeg.exe"  "C:\Windows\Temp\scratch\m3u8_dl\"
 

# Exit(1)

try {
    #
    # Installation dir check
    #
    if (Test-Path -Path $InstallationDir -PathType Container ) {
	if (Test-Path -Path $InstallationDir\*) {
	    write-output("`r`nInstallation directory `"$InstallationDir`" exists but is not empty. Exiting..." )
	    "`n" | Out-Host
	    Exit(1)
	}
    }
    elseif (-Not (New-Item -Path $InstallationDir -ItemType Directory)) {
	write-output( "Failed to create installation directory $InstallationDir. Exiting..." )
	"`n" | Out-Host
	Exit(1)
    }
    
    #
    # Perform installation
    #
    Perform-Installation $InstallationDir
}
finally {
    Set-Location $SavedDir
}

# https://github.com/nilaoda/N_m3u8DL-RE/releases/tag/v0.6.0-beta
#
# https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v0.6.0-beta/N_m3u8DL-RE_v0.6.0-beta_win-x64_20260629.zip
#
# curl --silent -m 10 --connect-timeout 5 "https://api.github.com/repos/nilaoda/N_m3u8DL-RE/releases/latest"
#
# (curl --silent -m 10 --connect-timeout 5 "https://api.github.com/repos/nilaoda/N_m3u8DL-RE/releases/latest" | ConvertFrom-Json).assets.name
#
# ((curl --silent -m 10 --connect-timeout 5 "https://api.github.com/repos/nilaoda/N_m3u8DL-RE/releases/latest" | ConvertFrom-Json).assets.browser_download_url) -match 'win-x64'
#
# curl -L -O https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
#
# ((curl --silent -m 10 --connect-timeout 5 "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest" | ConvertFrom-Json).assets.browser_download_url) -match 'win64-gpl.zip'
#
# ((curl -L --silent -m 10 --connect-timeout 5 "https://api.github.com/repos/gp9938/PowerShell/releases/latest"| ConvertFrom-Json).assets.browser_download_url )
#
# Test-Path -Path "C:\path\to\file.txt" -PathType Leaf
#
# $filePath = "C:\path\to\file.txt"
# Split-Path "$df" -LeafBase
# $full = Join-Path -Path $DownloadDir -ChildPath (Split-Path $df -LeafBase)
#
# if (Test-Path -Path $filePath -PathType Leaf) {
#     Write-Host "The file exists!"
# } else {
#     Write-Host "The file does not exist."
# }
#
# Expand-Archive -Path "C:\path\to\your\file.zip" -DestinationPath "C:\path\to\extracted_directory"
#
# ([DateTimeOffset]$ret).ToUnixTimeSeconds()
#
