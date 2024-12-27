While (1) {
    Write-Output "--------------------------------------------------------"
    (date -DisplayHint DateTime).DateTime

    Write-Output "`nGet-Counter Process ------------------"
     
    Get-Counter -SampleInterval 2 '\Process(*)\% Processor Time' | Select-Object -ExpandProperty countersamples| 
        Select-Object -Property instancename, cookedvalue| ? {$_.instanceName -notmatch "^(idle|_total|system)$"} | Sort-Object -Property cookedvalue -Descending| 
        Select-Object -First 25| ft InstanceName,@{L='CPU';E={($_.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} -AutoSize
    Write-Output "`nGet-Process Thread"
     
    Get-Process | Select-Object Name, ID, @{Name='ThreadCount';Expression ={$_.Threads.Count}} | Sort-Object -Property ThreadCount -Descending
     
    Write-Output "`n`n"
     
    sleep 20
}
