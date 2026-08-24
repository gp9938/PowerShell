
$ActionScript = "C:\Users\petra\src\PowerShell\usb_inserted_action.ps1;";

# Define a WMI event query, that looks for new instances of Win32_LogicalDisk where DriveType is "2"
# http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx
$Query = "select * from __InstanceCreationEvent within 5 where TargetInstance ISA 'Win32_LogicalDisk' and TargetInstance.DriveType = 2";

# Define a PowerShell ScriptBlock that will be executed when an event occurs
$Action = { 
    Write-Host "usb drive inserted" $event.SourceEventArgs.NewEvent.TargetInstance.Name;
    Write-Host ($event | Format-List | Out-String);
    Write-Host ($event.SourceEventArgs.NewEvent.TargetInstance | Format-Table | Out-String );
};
#      & C:\Users\petra\src\PowerShell\usb_inserted_action.ps1;
# }


$eventSubscriberInfo = Get-EventSubscriber -SourceIdentifier USBFlashDrive
if ($eventSubscriberInfo) {
    Unregister-Event -SourceIdentifier USBFlashDrive -Verbose
}

# Create the event registration
Register-CimIndicationEvent  -Query $Query  -SourceIdentifier USBFlashDrive -Action $Action

