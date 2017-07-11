<#
.Synopsis
   Update Server health report for tech support report
.DESCRIPTION
   This cmdlet updates the server health report
.EXAMPLE
   The following example gets the PE Server System information from iDRAC(s) available in the -iDRACSession default parameter value.
   The IPAddress and ShareName parameters are mandatory.
   Update-PEOSAppHealthData
.EXAMPLE
   The following example creates an iDRAC session and uses that to update Tech Support Report
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Update-PEOSAppHealthData -iDRACSession $iDRACSession
.EXAMPLE
   The following example creates an iDRAC session, uses that to create a update Tech Support Report job. The -UpdateType parameter is used to specify if a manual update should be performed.
   $iDRACSession = New-PEDRACSession -IPAddress 10.10.10.101 -Credential (Get-Credential)

   Update-PEOSAppHealthData -iDRACSession $iDRACSession -UpdateType Manual
.EXAMPLE
   The -Passthru parameter can be used to retrieve the job object
   $ExportJob = Update-PEOSAppHealthData -iDRACSession $iDRACSession -UpdateType Manual -Passthru
.INPUTS
    iDRACSession - CIM session with an iDRAC
    UpdateType - Manual or AgentLiteOSPlugin based update
    Passthru - Returns the export job object
    Wait - Waits till the export job is complete
#>
function Update-PEOSAppHealthData
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    Param
    (
        [Parameter(Mandatory,
                   ParameterSetName='General')]
        [Alias("s")]
        [Parameter(Mandatory,
                   ParameterSetName='Passthru')]
        [Parameter(Mandatory,
                   ParameterSetName='Wait')]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('AgentLiteOSPlugin','Manual')]
        [String]$UpdateType = 'AgentLiteOSPlugin',
        
        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Wait')]
        [switch]$Wait,

        [Parameter()]
        [Parameter(Mandatory,ParameterSetName='Passthru')]
        [switch]$Passthru
    )

    Begin
    {
        $properties=@{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_LCService";Name="DCIM:LCService";}
        $instance = New-CimInstance -ClassName DCIM_LCService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties

        $Parameters = @{
            UpdateType = [OSAPPUpdateType]$UpdateType -as [int]
        }
    }
    Process
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'Update OS App health data'))
        {
            $job = Invoke-CimMethod -InputObject $instance -MethodName UpdateOSAppHealthData -CimSession $iDRACSession -Arguments $Parameters
            if ($job.ReturnValue -eq 4096) 
            {
                if ($Passthru) 
                {
                    $job
                } 
                elseif ($Wait) 
                {
                    Wait-PEConfigurationJob -JobID $job.Job.EndpointReference.InstanceID -iDRACSession $iDRACSession -Activity 'Updating OS APP Health Data'
                }
            } 
            else 
            {
                Throw "Job creation failed with an error: $($job.Message)"
            }
        }
    }
}
