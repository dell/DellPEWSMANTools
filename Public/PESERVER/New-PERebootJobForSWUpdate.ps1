<#
.Synopsis
   Creates a specific reboot job to power cycle the host system.
.DESCRIPTION
   The New-PERebootJobForSWUpdate cmdlet creates a specific reboot job to power cycle the host system. This cmdlet requires the iDRACSession parameter obtained from New-PEDRACSession cmdlet. 
   The cmdlet will Throw an error if it fails.
.PARAMETER iDRACSession
The session object created by New-PEDRACSession.

.PARAMETER RebootType
This specifies the type of reboot required. Possible values Forced, Graceful, PowerCycle.

.PARAMETER Wait
Waits for the job to complete.

.PARAMETER Passthru
Returns the Job object without waiting.

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType Forced

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType Graceful

.EXAMPLE
PS C:\Windows\system32> New-PERebootJobForSWUpdate -iDRACSession $session -RebootType PowerCycle

.INPUTS
   iDRACSession, Reboot Job Type
#>
function New-PERebootJobForSWUpdate
{
    [CmdletBinding(DefaultParameterSetName='General',  
                  PositionalBinding=$false,
                  SupportsShouldProcess=$true,
                  ConfirmImpact='low')]
    [OutputType([String])]
    Param
    (
        # iDRAC Session Object
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='General')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Wait')]
        [Parameter(Mandatory,
                   Position=0,
                   ParameterSetName='Passthru')]
        [ValidateNotNullOrEmpty()]
        [Alias("s")] 
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Wait')]
        [Parameter(ParameterSetName='Passthru')]
        [ValidateSet('PowerCycle','Graceful','Forced')]
        $RebootType = 'PowerCycle',

        [Parameter(ParameterSetName='Wait')]
		[Switch]
        $Wait,

        [Parameter(ParameterSetName='Passthru')]
		[Switch]
        $Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="IDRAC:ID";CreationClassName="DCIM_SoftwareInstallationService";Name="SoftwareUpdate";}
        $instance = New-CimInstance -ClassName DCIM_SoftwareInstallationService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties
        
        $params=@{}
        $params.Add('RebootJobType',([ConfigJobRebootType]$RebootType -as [int]))
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Create new reboot job for software update'))
        {
            $responseData = Invoke-CimMethod -InputObject $instance -MethodName CreateRebootJob -CimSession $iDRACSession -Arguments $params 2>&1
            if ($responseData.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $responseData
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -iDRACSession $iDRACSession -JobID $responseData.RebootJobID.EndpointReference.InstanceID -Activity "Rebooting for Software Update for $($iDRACSession.ComputerName)"
                    Write-Verbose "Reboot for Software Update done seccessfully"
                }
            } 
            else 
            {
                Throw "Job Creation failed with error: $($responseData.Message)"
            }
        }
    }
}