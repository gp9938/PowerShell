#
# Asrock has a motherboard RGB driver that supports Windows 11 Dynamic Lighting.
# It basically works except when the computer wakes from sleep, the motherboard
# lighting isn't on even  though the Dynamic Lighting shows as being on.
# This script just disables and re-enables the registry entry for Dynamic Lighting
# 
# Using Task Scheduler and add a task trigger "On an event", Basic, Log: "System",
# Source: "Kernel-Power", Event ID: "566"
# A task delay of 1 minute might be good, but may not be necessary. 
# The task "Action" should be "Start a program".  To reduce the window "flash" that
# occurs when running a PowerShell script you can set "Program/script:" to
# "cmd" and "Add arguments (optional):" to:
#  '/c start /min "" pwsh.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File <Path-To>\FixDynamicLighting.ps1'
#
#
# Registry disable dynamic lighting
#
$DISABLE_DYNAMIC_TEMP_FILE="C:\Windows\Temp\tmp_disable_$($PID).reg"
$DISABLE_DYNAMIC=@'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000
'@
#
# Registry enable dynamic lighting
#
$ENABLE_DYNAMIC_TEMP_FILE="C:\Windows\Temp\tmp_enable_$($PID).reg"
$ENABLE_DYNAMIC=@'
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000001
'@

# create temp .reg files
Write-Output $DISABLE_DYNAMIC | Out-File -FilePath $DISABLE_DYNAMIC_TEMP_FILE
Write-Output $ENABLE_DYNAMIC | Out-File -FilePath $ENABLE_DYNAMIC_TEMP_FILE

reg IMPORT $DISABLE_DYNAMIC_TEMP_FILE
Start-Sleep -Seconds 1.0
reg IMPORT $ENABLE_DYNAMIC_TEMP_FILE


# remove temp .reg files
Remove-Item -Path $DISABLE_DYNAMIC_TEMP_FILE
Remove-Item -Path $ENABLE_DYNAMIC_TEMP_FILE
