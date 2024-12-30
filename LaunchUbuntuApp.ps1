#
# Ubuntu is not a typical WindowsApp with an App.xbf file in its app folder:
# C:\Program Files\WindowsApps\<app-name-and-id>\
# It actually has ubuntu.exe there, which means instead of appending !App to the
# Ubuntu PackageFamilyName you must append "!ubuntu"
#
$appname="Ubuntu"
$appnameTarget="ubuntu"
write-output "Will launch Ubunutu"
Start-Process shell:$("AppsFolder\" + (get-appxpackage | ?{$_.PackageFamilyName -like "*$appname*"}).PackageFamilyName + "!"+$appnameTarget)
