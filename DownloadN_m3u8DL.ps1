<#
.SYNOPSIS
Download an m3u8 playlist file of optionally encrypted videos from certain websites using the N_m3u9DL open
source utility.

.DESCRIPTION
Using the utility "N_m3u8DL", download all the transport streams of an m3u8 video
playlist file and combines them into an mp4 file.  This is done by using the m3u8
url as provided by browser add-on Video Downloader.   The url can also be
extracted using a browser's developer tools window and searching for "m3u8" in
the Network tab.  Be sure the return code of entry is 200 and not some error.

This may not work on all websites hosting m3u8 videos.  This script relies
on N_m3u8DL argument --append-url-params which may prevent it from working on
other websites.`

.PARAMETER VideoUrl 
The url (in double quotes) of the video obtained by using VideoDownloader to obtain the proper url.
Note that VideoDownloader will not work for this kind of video but does identify
the correct url.  To do this using Video Downloader, it is best to first 'pin'
Video Downloader to your browser's toolbar and then click on that icon when
on the page with the video you want to download.  From there click on the arrows
right next to the button labeled 'Download' and select 'Copy URL'.

Alternatively, someone familiar with browser "developer tools"
can open the developer tools window search for m3u8 in the Network tab and copy
the url from there.

.PARAMETER DownloadFolder
The folder where the video file will be written.  This defaults to the user's Downloads
folder.

.Parameter VideoName
The name for the saved video file.  This defaults to an automatically created date-based filename.

.EXAMPLE
.\DownloadN_m3u8.ps1  "https://cloudfront.jove.com/CDNSource/hls/11571/11571_.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jbG91ZGZyb250LmpvdmUuY29tL0NETlNvdXJjZS9obHMvMTE1NzEqIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzg3MDM1NjY3fX19XX0_&Signature=o1HmQ2DDRGWyicerdbM2FQFn4UFnmq1lzznM8Dzu57MoGRWBkAIGMAcSryTopL308NK1vCBdG~22wmtkvPMzTJB7Idtg8cbCz5uVPSe2qi~c3voi~ZoQiPHHmsD-dl6jcrkdoBh8o2b3cfr9nd47zHXcx7fZifR5mo2kMWrdsy~yimM6NEd8sWOfhfD9WZz9XYh9yewCaSWFykoMiLtzrih6tb~6QvhZCyd6sWR7yuPNwaGIu35LYrSNoPJeHt7xjRd3v4M1rwmlNbr4ChFqg5gz-~PfKUBDLX-vysiez7fj2ByJk1qMtW41ovmNhOY8NGXqGXgq4GJrVVHIaDmpQg__&Key-Pair-Id=KJU2718WA7HCS" C:\temp myvideo.mp4

.LINK
https://github.com/nilaoda/N_m3u8DL-RE

.LINK
https://github.com//BtbN/FFmpeg-Builds

.LINK
https://github.com/gp9938/PowerShell

.NOTES
Created: 2026-08-19

License: GPL3

#>

[CmdletBinding(DefaultParameterSetName = 'NoParameters')]
param ([Parameter(ParameterSetName='Standard',Mandatory=$true,Position=0)][string]$VideoUrl,
       [Parameter(ParameterSetName='Standard',Position=1)][string]$DownloadFolder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path,
       [Parameter(ParameterSetName='Standard',Position=2)][string]$VideoName = $null )

$DownloadApp = "D:\Users\petra\Downloads\N_m3u8DL-RE_v0.6.0-beta_win-x64_20260629\N_m3u8DL-RE.exe"
$DownloadApp = (Split-Path $MyInvocation.MyCommand.Path) + "\N_m3u8DL-RE.exe"


if (!$VideoUrl) {
    write-output( "No arguments provided, usage below:`r`n" )
    Get-Help $MyInvocation.MyCommand.Path
    Exit(1)
}
else {
    if (![System.Uri]::IsWellFormedUriString($VideoUrl, [System.UriKind]::Absolute)) {
	write-output( "`r`nSupplied VideoUrl `"$VideoUrl`" is not valid. Exiting...`r`n" );
	Exit(1)
    }
}

if ($VideoName)
{
    $SaveNameParamString = "--save-name $VideoName"
}
else
{
    $SaveNameParamString = $null
}


$CmdLine = "$DownloadApp `"$VideoUrl`"" + `
  "--save-dir $DownloadFolder " + `
  "$SaveNameParamString " + `
  "--log-level INFO " + `
  "--append-url-params " +  `
  "--thread-count 6 " +  `
  "-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:153.0) Gecko/20100101 Firefox/153.0' " + `
  "-H 'Accept: */*' " + `
  "-H 'Accept-Language: en-US,en;q=0.9' " + `
  "-H 'Accept-Encoding: gzip, deflate, br, zstd' " + `
  "-H 'Referer: https://www.jove.com/' " + `
  "-H 'Origin: https://www.jove.com' " + `
  "-H 'Sec-GPC: 1' " + `
  "-H 'Connection: keep-alive' " + `
  "-H 'Sec-Fetch-Dest: empty' " + `
  "-H 'Sec-Fetch-Mode: cors' " + `
  "-H 'Sec-Fetch-Site: same-site' " + `
  "-H 'TE: trailers' "

$Cmd = "& $CmdLine"
write-output( "Will use command line:`n" )
write-output( $Cmd )

$process = Invoke-Expression( $Cmd )

write-output( "process type is " + $process.GetType() )

if ( -Not $process.HasExited )
{
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" ERROR: Process has not exited but should have.")
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" ERROR: Process returned: " )
    Write-Output ( $process | Format-Table | Out-String )
    Exit( 1 )
}
else
{
    if ( $process.ExitCode -eq 0 )
    {
	Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Download process completed successfully.")
	Exit( 0 )
    }
    else
    {
	Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" ERROR: Process exited with code $process.ExitCode" )
	Exit( $process.ExitCode )
    }
}

