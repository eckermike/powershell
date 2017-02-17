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
   1. get the gpo name you are trying to edit from parameter
   2. Use global variable to make each user have their own dev GPO
   3. When a GPO is 'checked out' it will be set permissions so only the user currently editing the GPO has modify access. This makes it so another user cannot edit the GPO at the same time. 
   4. If a user attempts to 'check out' a gpo that does not have their username directly in the ACL or the Global variable GPO admin group they will get an error stating that the GPO is currently being edited and spit out the current ACL.
   5. If the gpo gets 'checked out' then the script will copy the full settings of the GPO to the users 'DEVGPO'
   6. 

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

        # Param2 help description
        [Parameter(ParameterSetName='Parameter Set 1')]

        [ValidateScript({$true})]
        $DOMAIN,

        # Param3 help description
        [Parameter(ParameterSetName='Another Parameter Set')]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]
        $Param3
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