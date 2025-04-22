#
# Disable and re-enable dynamic lighting to force the proper state
# This will be triggered via Task Manager when the system resumes from sleep
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