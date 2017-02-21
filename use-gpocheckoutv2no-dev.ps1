<#
.Synopsis
   This is to assist with version control and multiple editors to GPO.  This relies heavily on the following global variables being set in the users profile.  
    Set-Variable -Option ReadOnly -Scope Global -Name DEVGPO -Value put the name of the GPO you are going to edit here
    Set-Variable -Option ReadOnly -Scope Global -Name BlankGPO -Value this is a blank GPO used to copy permissions.  This should have the global permissions you want on a gpo.  
    Set-Variable -Option ReadOnly -Scope Global -Name GPOADMIN -Value This is the group you are using to assign edit permissions to
    Set-Variable -Option ReadOnly -Scope Global -Name ADMIN -Value your administrative credentials
    Set-Variable -Option ReadOnly -Scope Global -Name USER -Value your standard credentials
    Set-Variable -Option ReadOnly -Scope Global -Name GPOPath -value path to wher you would like to save your gpobackups.  Recommend this be done on a network share only you have access to to avaoid multiple gpos being backed up to different places. 

.DESCRIPTION
   The idea here is that every admin will have one or multiple 'DEV' gpos to edit settings.  The process will be as follows
   This is for the check out function
   1. get the gpo name you are trying to edit from parameter
   2. Use global variable to make each user have their own dev GPO
   3. When a GPO is 'checked out' it will be set permissions so only the user currently editing the GPO has modify access. This makes it so another user cannot edit the GPO at the same time. 
   4. If a user attempts to 'check out' a gpo that does not have their username directly in the ACL or the Global variable GPO admin group they will get an error stating that the GPO is currently being edited and spit out the current ACL.
   5. If the gpo gets 'checked out' then the script will copy the full settings of the GPO to the users 'DEVGPO'else the script will return the GPO is in use and list the current ACL and end there
   6. The script will get the gpinheritance of the source OU and make sure that all the same policies are linked with your dev GPO in place of the GPO you are attempting to edit


.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function use-gpocheckout
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$true,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # this is the parameter to say if the gpo is being checked in or out. It wil be moved to the parent cmdlet
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateSet("CheckIn", "CheckOut")]
        $check,

       # This is the domain your source gpo is in
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-addomain -identity $_})]
        $SourceDomain,

                # This is the name of the gpo you are trying to edit.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-gpo -name $_ -domain $SourceDomain })]
        $SourceGPO,

        # The OU where you are copying the GPO from
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Get-ADOrganizationalUnit -Identity $_ -Server $SourceDomain  })]
        $SourceOU,

        #the domain where your editing gpo resides
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-addomain -identity $_})]
        $TargetDomain,

       # This is the name of the OU you will be testing in.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({Get-ADOrganizationalUnit -Identity $_ -Server $TargetDomain })]
        $TargetOU,

        # This is the name of the security group you are targeting the GPO to.  
        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({Get-ADOrganizationalUnit -Identity $_ -Server $TargetDomain })]
        $TargetingGroup,


        # This is the name of the gpo you are trying to edit.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-gpo -name $_ -domain $TargetDomain })]
        $TargetGPO
    )
  

    Begin
    {

        # Check for the ActiveDirectory module and try to load it if needed.  
        If (-Not (get-module | select -expand name).contains("ActiveDirectory")) {
            Try {Import-Module ActiveDirectory -ErrorAction Stop}
            Catch {Throw "Unable to load ActiveDirectory module"}
    }
    }
    Process
    {
        #set variables for use later
        $GPOS = Get-GPInheritance -Target $sourceOU -Domain $SourceDomain
        $InheritedGPOs = $gpos.InheritedGpoLinks.displayname
        $LocalGPOs = $gpos.GpoLinks.displayname

        if($check -eq "CheckOut"){
        #this section gets all the gpos applied to the OU you are editing in and links them to your DEV OU with the correct permissions
        backup-gpo -Name $SourceGPO -Path $GPOPath -Domain $SourceDomain 
        import-gpo -BackupGpoName $SourceGPO -Path $GPOPath -TargetName $TargetGPO -Domain $TargetDomain
        Set-GPPermissions -Name $TargetGPO -PermissionLevel GpoRead -TargetName 'Authenticated users' -TargetType Group

        Foreach($InheritedGPO in $InheritedGPOs){
            if( -not ( get-gpo -Name $inheritedGPO -Domain $TargetDomain)){
                Copy-GPO -SourceName $InheritedGPO + '-dev' -TargetName $inheritedGPO -SourceDomain $sourcedomain -TargetDomain $targetdomain -CopyAcl
                New-GPLink -Name $InheritedGPO + '-dev' -Target $TargetOU -Domain $TargetDomain
                }
            if( get-gpo -Name $inheritedGPO -Domain $TargetDomain){
                New-GPLink -Name $InheritedGPO -Target $TargetOU -Domain $TargetDomain
                }
            }

        Foreach($LocalGPO in $LocalGPOs){
            if( -not ( get-gpo -Name $localGPO -Domain $TargetDomain)){
                Copy-GPO -SourceName $localGPO -TargetName $localGPO -SourceDomain $sourcedomain -TargetDomain $targetdomain -CopyAcl
                New-GPLink -Name $localGPO -Target $TargetOU -Domain $TargetDomain
                }
            if(get-gpo -Name $localGPO -Domain $TargetDomain){
                New-GPLink -Name $localGPO -Target $TargetOU -Domain $TargetDomain
                }
            }
        if(Set-GPLink -Name $SourceGPO -Target $TargetOU -Domain $TargetDomain){
                Remove-GPLink -Name $SourceGPO -Target $TargetOU -Domain $TargetDomain
                }
        #this is where the GPO is checked out.  When you remove the GPO admin group it wont allow another user to edit the GPO
        Set-GPPermissions -Name $sourceGPO -TargetName $admin -TargetType User -PermissionLevel GpoEditDeleteModifySecurity -Server $SourceDomain
        Set-GPPermissions -Name $sourceGPO -TargetName $GPOADMIN -TargetType Group -PermissionLevel None -Server $SourceDomain
        if($TargetingGroup){
            Set-GPPermissions -Name $targetGPO -TargetName $TargetingGroup -PermissionLevel GpoApply -TargetType Group -DomainName $TargetDomain
            }
        }

        if($check -eq "CheckIn"){
        if($TargetDomain -eq $SourceDomain){
            Foreach($InheritedGPO in $InheritedGPOs){
                Remove-GPLink -Name $InheritedGPO -Target $TargetOU -Domain $TargetDomain
                }
            Foreach($LocalGPO in $LocalGPOs){
                Remove-GPLink -Name $LocalGPO -Target $TargetOU -Domain $TargetDomain
                }
            }
        if(-not ($TargetDomain -eq $SourceDomain{
            Foreach($InheritedGPO in $InheritedGPOs){
                Remove-GPO -Name $inheritedGPO -Domain $TargetDomain -
                Remove-GPO -Name $InheritedGPO -Target $TargetOU -Domain $TargetDomain
                }
            Foreach($LocalGPO in $LocalGPOs){
                Remove-GPLink -Name $LocalGPO -Target $TargetOU -Domain $TargetDomain
                }
            }
        }
    }
    End
    {
    }
}