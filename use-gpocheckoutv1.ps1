<#
.Synopsis
   This is to assist with version control and multiple editors to GPO.  This relies heavily on the following global variables being set in the users profile.  
    Set-Variable -Option ReadOnly -Scope Global -Name DEVGPO -Value put the name of the GPO you are going to edit here
    Set-Variable -Option ReadOnly -Scope Global -Name BlankGPO -Value this is a blank GPO used to copy permissions.  This should have the global permissions you want on a gpo.  
    Set-Variable -Option ReadOnly -Scope Global -Name GPOADMIN -Value This is the group you are using to assign edit permissions to
    Set-Variable -Option ReadOnly -Scope Global -Name ADMIN -Value your administrative credentials
    Set-Variable -Option ReadOnly -Scope Global -Name USER -Value your standard credentials

.DESCRIPTION
   The idea here is that every admin will have one or multiple 'DEV' gpos to edit settings.  The process will be as follows
   This is for the check out function
   1. get the gpo name you are trying to edit from parameter
   2. Use global variable to make each user have their own dev GPO
   3. When a GPO is 'checked out' it will be set permissions so only the user currently editing the GPO has modify access. This makes it so another user cannot edit the GPO at the same time. 
   4. If a user attempts to 'check out' a gpo that does not have their username directly in the ACL or the Global variable GPO admin group they will get an error stating that the GPO is currently being edited and spit out the current ACL.
   5. If the gpo gets 'checked out' then the script will copy the full settings of the GPO to the users 'DEVGPO'else the script will return the GPO is in use and list the current ACL and end there
   6. The script will get the gpinheritance of the source OU and make sure that all the same policies are linked with your dev GPO in place of the GPO you are attempting to edit
   
    This is for the check in function
    1. backup the dev gpo and import to GPO you are editing.  starting this idea over.  Going to change it so there are two sepearte functions called by one cmdlet.  This helps with parameter management.

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
function Verb-Noun
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # this is the parameter to say if the gpo is being checked in or out
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateSet("CheckIn", "CheckOut")]
        [Alias("check")] 
        $check,

        # This is the domain you are trying to edit the gpo in. THis is only necessary in environments with multiple domains
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-addomain -identity $_})]
        $DOMAIN,

        # This is the name of the gpo you are trying to edit.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({get-gpo -name $_ -domain $domain })]
        $EditGPO,

        # The OU where you are copying the GPO from
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({Get-ADOrganizationalUnit -Identity $_ -Server $domain })]
        $SourceOU,

        # This is the name of the OU you will be testing in.  
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateScript({Get-ADOrganizationalUnit -Identity $_ -Server $domain }})]
        $TargetOU


    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
    }
    End
    {
    }
}