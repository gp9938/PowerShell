$Counter = "\Process(*)\% Processor Time"
$Interval = 2 # Number of seconds between loops

while ($true) {
    $Procs = Get-Counter -Counter $Counter
    $Procs.Timestamp
    $Procs.CounterSamples |
        Where-Object -Property CookedValue -GT 0 |
        Sort-Object -Property CookedValue -Descending |
        Format-Table -Property InstanceName, @{ Label='CPU'; Expression={$_.CookedValue/100}; FormatString='P' } -AutoSize

    Start-Sleep $Interval
}
