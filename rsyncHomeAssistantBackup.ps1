
$LogFile="D:\HomeAssistantBackup\log\rsyncHomeAssistantBackup.log"
$OldLogFile="D:\HomeAssistantBackup\log\rsyncHomeAssistantBackup-old.log"
if ([System.IO.File]::Exists($LogFile)) 
{
    Move-Item -Path $LogFile -Destination $OldLogFile -Force
}

&{
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" rsync of HomeAssistant backup dir started")
    cd d:\HomeAssistantBackup\data
    d:\cygwin64\bin\rsync.exe -paurve "d:\cygwin64\bin\ssh.exe -v " homeassistant@homeassistant.local:/backup .
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" rsync of Home Assistant backup dir ended")
 
} *> $LogFile