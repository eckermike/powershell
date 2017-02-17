$stackGpos = New-Object System.Collections.Stack
$stacknogpo = New-Object System.Collections.Stack
#$domain = $pen, $Shared
foreach($domain in $domains){
$gpos = Get-GPO -All -Domain $domain
foreach($gpo in $gpos){
$gponame = $gpo.DisplayName
$stackGpos.Push($gponame)
}
}
foreach($domain in $domains){
foreach($gpo in $stackgpos){
if(-not (Get-GPPermissions -name $gpo -TargetName '#IOT GPO Admins' -TargetType Group -DomainName $domain)){
$stacknogpo.Push($gpo)
}
}

$stacknogpo.Push($domain)
}


# domain no exist $dnr