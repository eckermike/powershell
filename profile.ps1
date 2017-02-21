###############  Constants   ###############
Set-Variable -option ReadOnly -scope Global -name UserHome -value #place your powershell repo location here
Set-Variable -option ReadOnly -scope Global -name <#make a variable for you domains.#> -value #put your domain here. If you have multiple domains create a variable for each.
Set-Variable -Option ReadOnly -Scope Global -Name DEVGPO -Value #make this the name of a GPO that you will use when making edits.  You can create multiple of these.  
Set-Variable -Option ReadOnly -Scope Global -Name BlankGPO -Value #create a gpo with the base persmissions you want an place the name here
Set-Variable -Option ReadOnly -Scope Global -Name GPOADMIN -Value #put the name of the group you are using to  assign GPO permissions.  I recommend making multiple values like this for different admin tasks.  I.E. GPO, File Share, Printer groups
Set-Variable -Option ReadOnly -Scope Global -Name ADMIN -Value #your admin account
Set-Variable -Option ReadOnly -Scope Global -Name USER -Value #your regular credetials.  Depending on your environment you may need to make more of this variable
Set-variable -Option ReadOnly -Scope Global -Name DOMAINS -Value #if you have multiple domains you can use this to create a variable that has all of the varialbes you created above for your seperate domains.  Just seperate each predefined variable with a comma.  I.E. $domain1, $domain2, $domain3

###############  Functions   ###############

$u = [System.Environment]::ExpandEnvironmentVariables("%USERNAME%")




############## Profile Things ###################

$ComputerName = Get-Content env:computername


#ignore everything below this line for now


<#

Function Get-CodeSigningCerts {

    Return ls Cert: -Recurse -CodeSigningCert

}


Function Get-MyCodeSigningCert {

    $Cert = ls cert: -recurse -CodeSigningCert | where {$_.Thumbprint -eq "‎‎a3448d87e2e6272b4680818fa8ac40281a93ebef"}

    If ($Cert -eq $null) {
        
        Write-Host -ForegroundColor Red "Code signing cert not found."
    
    }

    If ($Cert.Count -gt 1) {
    
        $Cert = $Cert[0]
        
    }

    Return $Cert

}


Function Sign ($file) {

    If ($Cert -eq $null) {
        
        Write-Host -ForegroundColor Red "Can't sign, `$Cert variable is null"

    }
    Else {
        
        Set-AuthenticodeSignature $file $Cert
    
    }  

}

Function Home { cd $UserHome }
Function DMOT { cd $DMOT }
Function Server { cd $Server }
Function GPOScripts { cd $GPOScripts }
Function Downloads { cd $UserHome\Downloads }
Function Backups { cd \\iu-iusm-bbackup.ads.iu.edu\j$ }
Function ADUC { & 'C:\Windows\System32\dsa.msc' }
Function GPMC { & 'C:\Windows\System32\gpmc.msc' }
Function SSMS { & 'C:\Program Files\Microsoft SQL Server\110\Tools\Binn\ManagementStudio\Ssms.exe' }
Function NP++ { & "C:\Program Files (x86)\Notepad++\notepad++.exe" -multiInst }
Function Explorer++ { & 'C:\Program Files\explorer++\Explorer++.exe' }
Function vSphere { & "C:\Program Files (x86)\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe" }


###############  Global Variables   ###############
$Global:Cert = Get-MyCodeSigningCert

If (-Not $env:PSModulePath.Contains(';\\iu-iusm-vg.ads.iu.edu\groups$\DMOT\Server\Coding\Powershell\Modules')) {
    $env:PSModulePath = $env:PSModulePath + ';\\iu-iusm-vg.ads.iu.edu\groups$\DMOT\Server\Coding\Powershell\Modules'
}

#>