param (
    [Parameter(Mandatory=$true)][string]$appname
 )
 write-output "Will launch Xbox Game with name like $appname"
 Start-Process shell:$("AppsFolder\" + (get-appxpackage | ?{$_.PackageFamilyName -like "*$appname*"}).PackageFamilyName + "!Game")