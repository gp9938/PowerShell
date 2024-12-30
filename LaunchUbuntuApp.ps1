
$appname="Ubuntu"
$appnameTarget="ubuntu"
write-output "Will launch Ubunutu"
Start-Process shell:$("AppsFolder\" + (get-appxpackage | ?{$_.PackageFamilyName -like "*$appname*"}).PackageFamilyName + "!"+$appnameTarget)
