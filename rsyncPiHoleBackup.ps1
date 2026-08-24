
$LogFile="D:\Users\petra\log\rsyncPiHoleBackup.log"
$OldLogFile="D:\Users\petra\log\rsyncPiHoleBackup-old.log"
$BackupDirName="etc-pihole-backups"
$KeepNumDaysOfBackups=90
if ([System.IO.File]::Exists($LogFile)) 
{
    Move-Item -Path $LogFile -Destination $OldLogFile -Force
}

&{
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" rsync of PiHole backup dir started")
    $OLD_PWD=$PWD
    cd d:\Users\petra
    d:\cygwin64\bin\rsync.exe -paurve "d:\cygwin64\bin\ssh.exe -v -i d:\cygwin64\home\petra\.ssh\id_pihole_rsa " pihole@pi5:$BackupDirName .
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" rsync of PiHole backup dir ended")

    # now cleanup backups older than $KeepNumDaysOfBackups
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Will remove backups that are more than $KeepNumDaysOfBackups days old")
    cd $BackupDirName
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Listing of $PWD")
    Get-ChildItem -name | Format-Wide -AutoSize -Force
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Will remove the following backups:")
    D:\cygwin64\bin\find.exe . -name "\*.tgz" -mtime +$KeepNumDaysOfBackups -exec D:\cygwin64\bin\echo.exe "{}" ";"
    Write-Output ( "-$([Environment]::NewLine)" );

    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Running remove...")
    D:\cygwin64\bin\find.exe . -name "\*.tgz" -mtime +$KeepNumDaysOfBackups -exec rm "{}" ";"
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Running remove done. New listing of $PWD follows")
    Get-ChildItem -name | Format-Wide -AutoSize -Force
    Write-Output ((Get-Date -UFormat "%Y%M%d-%R:%S")+" Listing done.")
    cd $OLD_PWD
} *> $LogFile


    
