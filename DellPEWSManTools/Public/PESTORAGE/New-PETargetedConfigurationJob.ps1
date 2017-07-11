<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER iDRACSession
Parameter description

.PARAMETER InstanceID
Parameter description

.PARAMETER RebootType
Parameter description

.PARAMETER RebootRequired
Parameter description

.PARAMETER JobType
Parameter description

.PARAMETER StartTime
Parameter description

.PARAMETER UntilTime
Parameter description

.PARAMETER Wait
Parameter description

.PARAMETER Passthru
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function New-PETargetedConfigurationJob 
{
    [CmdletBinding(DefaultParameterSetName='General',
                    SupportsShouldProcess=$true,
                    ConfirmImpact='low')]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory, ParameterSetName='General')]
        [Parameter(Mandatory, ParameterSetName='Passthru')]
        [Parameter(Mandatory, ParameterSetName='Wait')]
        [Alias("s")]
        [ValidateNotNullOrEmpty()]
        $iDRACSession,

        [Parameter(Mandatory, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        $InstanceID,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('None','PowerCycle','Graceful','Forced')]
        $RebootType = 'None',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [Bool]$RebootRequired,

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [ValidateSet('Staged','Realtime')]
        [String] $JobType = 'Realtime',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $StartTime = 'TIME_NOW',

        [Parameter(ParameterSetName='General')]
        [Parameter(ParameterSetName='Passthru')]
        [Parameter(ParameterSetName='Wait')]
        [String] $UntilTime,

        [Parameter(ParameterSetName='Wait')]
        [Switch] $Wait,

        [Parameter(ParameterSetName='Passthru')]
        [Switch] $Passthru
    )

    Begin 
    {
        $properties= @{SystemCreationClassName="DCIM_ComputerSystem";SystemName="DCIM:ComputerSystem";CreationClassName="DCIM_RAIDService";Name="DCIM:RAIDService";}
        $instance = New-CimInstance -ClassName DCIM_RAIDService -Namespace root/dcim -ClientOnly -Key @($properties.keys) -Property $properties        
        $Parameters = @{
            Target = $InstanceID
            ScheduledStartTime = $StartTime
            Realtime = [Jobtype]$JobType -as [int]
        }

        if (-not ($RebootType -eq 'None')) 
        {
            $Parameters.Add('RebootJobType',([ConfigJobRebootType]$RebootType -as [int]))
        }

        if ($UntilTime) 
        {
            $Parameters.Add('UntilTime',$UntilTime)
        }
        $Parameters
    }

    Process 
    {
        if ($PSCmdlet.ShouldProcess($($iDRACSession.ComputerName),'create targeted configuration job'))
        {
            $Job = Invoke-CimMethod -InputObject $instance -MethodName CreateTargetedConfigJob -CimSession $idracsession -Arguments $Parameters
            if ($Job.ReturnValue -eq 4096) 
            {
                if ($PSCmdlet.ParameterSetName -eq 'Passthru') 
                {
                    $Job
                } 
                elseif ($PSCmdlet.ParameterSetName -eq 'Wait') 
                {
                    Write-Verbose 'Starting configuration job ...'
                    Wait-PEConfigurationJob -JobID $Job.Job.EndpointReference.InstanceID -Activity 'Performing RAID Configuration ..'                
                }
            } 
            else 
            {
                Write-Error $Job.Message
            }
        }
    }
}
