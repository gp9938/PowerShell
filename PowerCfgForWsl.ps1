#
#  WSL (Windows Subsystem for Linux)  gui programs run using the
#  Microsoft Remote Desktop Client (msrdc.exe)
#  When msrdc is running, it prevents most power saving modes
#  turning off the monitors or allowing the computer to sleep.
#
#  This powercfg command instructs Windows to ignore msrdc power
#  saving controls for DISPLAY and SYSTEM so that the system
#  can sleep.
#
#  Must run as admin
#
powercfg /REQUESTSOVERRIDE PROCESS "\Device\HarddiskVolume4\Program Files\WSL\msrdc.exe"  DISPLAY SYSTEM AWAYMODE
