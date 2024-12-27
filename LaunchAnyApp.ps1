param (
    [Parameter(Mandatory=$true)][string]$appname
 )
 write-output "Will launch app with name like $appname"
 Start-Process shell:$("AppsFolder\" + (get-appxpackage | ?{$_.PackageFamilyName -like "*$appname*"}).PackageFamilyName + "!App")